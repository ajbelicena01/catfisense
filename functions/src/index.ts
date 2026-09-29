import {initializeApp} from "firebase-admin/app";
import {getDatabase} from "firebase-admin/database";
import {getMessaging} from "firebase-admin/messaging";
import {createHash, createHmac, timingSafeEqual} from "node:crypto";
import {logger} from "firebase-functions";
import {onValueCreated} from "firebase-functions/v2/database";
import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

initializeApp();

const deviceHmacSecret = defineSecret("DEVICE_HMAC_SECRET");
const POND_ID = "pond1";
const DEVICE_ID = "pond1";
const MAX_REQUEST_AGE_MS = 60_000;
const NONCE_WINDOW_MS = 3 * 60_000;

type SensorPayload = {
  ph: number;
  temperature: number;
  dissolvedOxygen: number;
  ammonia: number;
  batteryPercent?: number;
};

function validSensorPayload(value: unknown): value is SensorPayload {
  if (!value || typeof value !== "object" || Array.isArray(value)) return false;
  const reading = value as Record<string, unknown>;
  const inRange = (key: string, min: number, max: number) =>
    typeof reading[key] === "number" && Number.isFinite(reading[key]) &&
    (reading[key] as number) >= min && (reading[key] as number) <= max;
  return inRange("ph", 0, 14) &&
    inRange("temperature", -10, 60) &&
    inRange("dissolvedOxygen", -5, 30) &&
    inRange("ammonia", -0.5, 20) &&
    (reading.batteryPercent === undefined || inRange("batteryPercent", 0, 100));
}

// The device secret is held in Secret Manager and on the ESP32. The device
// signs the exact request bytes plus a short-lived timestamp and random nonce.
// No Firebase Admin credential or database write token is placed in firmware.
export const ingestSensorReading = onRequest(
  {
    region: "asia-southeast1",
    secrets: [deviceHmacSecret],
    maxInstances: 2,
    invoker: "public",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.set("Allow", "POST").status(405).send("Method not allowed");
      return;
    }

    const deviceId = req.get("x-device-id") ?? "";
    const timestamp = req.get("x-device-timestamp") ?? "";
    const nonce = req.get("x-device-nonce") ?? "";
    const signature = req.get("x-device-signature") ?? "";
    const rawBody = req.rawBody;
    if (deviceId !== DEVICE_ID || !/^\d{10}$/.test(timestamp) ||
        !/^[a-f0-9]{32,64}$/i.test(nonce) || !/^[a-f0-9]{64}$/i.test(signature) ||
        rawBody.length === 0 || rawBody.length > 2048) {
      res.status(401).send("Invalid device request");
      return;
    }

    const now = Date.now();
    if (Math.abs(now - Number(timestamp) * 1000) > MAX_REQUEST_AGE_MS) {
      res.status(401).send("Expired device request");
      return;
    }

    const message = `${timestamp}\n${nonce}\n${rawBody.toString("utf8")}`;
    const expected = createHmac("sha256", deviceHmacSecret.value()).update(message).digest();
    const supplied = Buffer.from(signature, "hex");
    if (supplied.length !== expected.length || !timingSafeEqual(supplied, expected)) {
      res.status(401).send("Invalid device signature");
      return;
    }

    let payload: unknown;
    try {
      payload = JSON.parse(rawBody.toString("utf8"));
    } catch {
      res.status(400).send("Invalid JSON");
      return;
    }
    if (!validSensorPayload(payload)) {
      res.status(400).send("Sensor values are missing or out of range");
      return;
    }

    // Store only a digest of the random nonce. A transaction makes concurrent
    // replays fail; old nonce entries are pruned on every accepted request.
    const nonceHash = createHash("sha256").update(nonce).digest("hex");
    const nonceRef = getDatabase().ref(`deviceAuth/${DEVICE_ID}/requestState`);
    let replayed = false;
    let throttled = false;
    const nonceResult = await nonceRef.transaction((current: {
      recentNonces?: Record<string, number>;
      lastAcceptedAt?: number;
    } | null) => {
      replayed = false;
      throttled = false;
      const recent = Object.fromEntries(Object.entries(current?.recentNonces ?? {})
        .filter(([, seenAt]) => typeof seenAt === "number" && now - seenAt < NONCE_WINDOW_MS));
      if (typeof recent[nonceHash] === "number") {
        replayed = true;
        return;
      }
      if (typeof current?.lastAcceptedAt === "number" && now - current.lastAcceptedAt < 2000) {
        throttled = true;
        return;
      }
      recent[nonceHash] = now;
      return {recentNonces: recent, lastAcceptedAt: now};
    });
    if (replayed) {
      res.status(409).send("Request already used");
      return;
    }
    if (throttled) {
      res.status(429).send("Device request rate exceeded");
      return;
    }
    if (!nonceResult.committed) {
      res.status(503).send("Could not authorize device request");
      return;
    }

    // A monotonic, millisecond timestamp key keeps history range queries in
    // chronological order even if requests arrive in the same millisecond.
    const keyRef = getDatabase().ref(`ponds/${POND_ID}/lastReadingKey`);
    const keyResult = await keyRef.transaction((lastKey: number | null) =>
      Math.max(now, (lastKey ?? 0) + 1));
    if (!keyResult.committed || typeof keyResult.snapshot.val() !== "number") {
      res.status(503).send("Could not allocate reading timestamp");
      return;
    }
    const recordedAt = keyResult.snapshot.val() as number;
    const reading = {...payload, recordedAt};
    await getDatabase().ref(`ponds/${POND_ID}/readings/${recordedAt}`).set(reading);
    // Transactions avoid an older in-flight request replacing a newer latest.
    await getDatabase().ref(`ponds/${POND_ID}/latestReading`).transaction((current) => {
      if (typeof current?.recordedAt === "number" && current.recordedAt >= recordedAt) return;
      return reading;
    });
    res.status(201).json({accepted: true, recordedAt});
  },
);

type PondStatus = "healthy" | "warning" | "critical";

function worstStatus(reading: Record<string, unknown>): PondStatus {
  const ph = Number(reading.ph);
  const temperature = Number(reading.temperature);
  const dissolvedOxygen = Number(reading.dissolvedOxygen);
  const ammonia = Number(reading.ammonia);
  if (ph < 6 || ph > 9 || temperature < 20 || temperature > 33 || dissolvedOxygen < 3 || ammonia > 0.05) {
    return "critical";
  }
  if (ph < 6.5 || ph > 8.5 || temperature < 25 || temperature > 30 || dissolvedOxygen < 5 || ammonia > 0.02) {
    return "warning";
  }
  return "healthy";
}

const alertCopy: Record<Exclude<PondStatus, "healthy">, {title: string; body: string}> = {
  warning: {
    title: "Pond health warning",
    body: "A reading has drifted out of the healthy range. Tap to see what to do.",
  },
  critical: {
    title: "Pond health is critical",
    body: "One or more readings are critical — check the app and act now.",
  },
};

// The instance name comes from your existing Realtime Database URL. Keep this
// function in asia-southeast1 with the database to minimise latency.
export const notifyOnRiskyReading = onValueCreated(
  {
    ref: "/ponds/{pondId}/readings/{readingId}",
    instance: "catfisense-db-4cda7-default-rtdb",
    region: "asia-southeast1",
  },
  async (event) => {
    const {pondId, readingId} = event.params;
    const reading = event.data.val() as Record<string, unknown> | null;
    if (reading === null) return;

    const status = worstStatus(reading);
    const stateRef = getDatabase().ref(`_system/pondNotificationState/${pondId}`);
    let sendAlert = false;

    // Cloud Functions events may be retried. The transaction makes a single
    // reading id idempotent and only sends on a status transition.
    const result = await stateRef.transaction((current: {lastReadingId?: string; lastStatus?: PondStatus} | null) => {
      if (current?.lastReadingId === readingId) return;
      sendAlert = status !== "healthy" && current?.lastStatus !== status;
      return {lastReadingId: readingId, lastStatus: status, updatedAt: Date.now()};
    });
    if (!result.committed || !sendAlert) return;

    const membersSnapshot = await getDatabase().ref(`ponds/${pondId}/members`).get();
    const memberUids = Object.entries(membersSnapshot.val() ?? {})
      .filter(([, role]) => role === "owner" || role === "caretaker")
      .map(([uid]) => uid);
    const memberTokens = await Promise.all(memberUids.map(async (uid) => ({
      uid,
      snapshot: await getDatabase().ref(`users/${uid}/fcmTokens`).get(),
    })));
    const tokenOwners = memberTokens.flatMap(({uid, snapshot}) =>
      Object.entries(snapshot.val() ?? {}).flatMap(([key, entry]) => {
        const token = (entry as {token?: unknown}).token;
        return typeof token === "string" ? [{uid, key, token}] : [];
      }));
    const tokens = tokenOwners.map((entry) => entry.token);
    if (tokens.length === 0) return;

    const copy = alertCopy[status as Exclude<PondStatus, "healthy">];
    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: copy,
      data: {status, readingId},
      android: {
        priority: "high",
        notification: {channelId: "pond_alerts", sound: "default"},
      },
    });
    logger.info("Pond alert sent", {pondId, readingId, status, successCount: response.successCount});

    // Remove stale registrations so future alerts do not repeatedly target
    // devices where the app was uninstalled or the token expired.
    const updates: Record<string, null> = {};
    response.responses.forEach((item, index) => {
      if (item.error?.code === "messaging/registration-token-not-registered") {
        const stale = tokenOwners[index];
        updates[`users/${stale.uid}/fcmTokens/${stale.key}`] = null;
      }
    });
    if (Object.keys(updates).length > 0) await getDatabase().ref().update(updates);
  },
);
