import {initializeApp} from "firebase-admin/app";
import {getDatabase} from "firebase-admin/database";
import {getMessaging} from "firebase-admin/messaging";
import {logger} from "firebase-functions";
import {onValueCreated} from "firebase-functions/v2/database";

initializeApp();

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
    ref: "/readings/{uid}/{readingId}",
    instance: "catfisense-db-4cda7-default-rtdb",
    region: "asia-southeast1",
  },
  async (event) => {
    const {uid, readingId} = event.params;
    const reading = event.data.val() as Record<string, unknown> | null;
    if (reading === null) return;

    const status = worstStatus(reading);
    const stateRef = getDatabase().ref(`users/${uid}/notificationState`);
    let sendAlert = false;

    // Cloud Functions events may be retried. The transaction makes a single
    // reading id idempotent and only sends on a status transition.
    const result = await stateRef.transaction((current: {lastReadingId?: string; lastStatus?: PondStatus} | null) => {
      if (current?.lastReadingId === readingId) return;
      sendAlert = status !== "healthy" && current?.lastStatus !== status;
      return {lastReadingId: readingId, lastStatus: status, updatedAt: Date.now()};
    });
    if (!result.committed || !sendAlert) return;

    const tokensSnapshot = await getDatabase().ref(`users/${uid}/fcmTokens`).get();
    const tokens = Object.values(tokensSnapshot.val() ?? {})
      .map((entry) => (entry as {token?: unknown}).token)
      .filter((token): token is string => typeof token === "string");
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
    logger.info("Pond alert sent", {uid, readingId, status, successCount: response.successCount});

    // Remove stale registrations so future alerts do not repeatedly target
    // devices where the app was uninstalled or the token expired.
    const staleTokens = response.responses
      .map((item, index) => ({item, token: tokens[index]}))
      .filter(({item}) => item.error?.code === "messaging/registration-token-not-registered")
      .map(({token}) => token);
    if (staleTokens.length > 0) {
      const allEntries = tokensSnapshot.val() as Record<string, {token?: string}>;
      const updates: Record<string, null> = {};
      for (const [key, value] of Object.entries(allEntries)) {
        if (value.token && staleTokens.includes(value.token)) updates[`users/${uid}/fcmTokens/${key}`] = null;
      }
      await getDatabase().ref().update(updates);
    }
  },
);
