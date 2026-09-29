# CatFiSense single-pond data model

CatFiSense currently has one pond (`pond1`) and one sensor device. Keep the pond ID stable, while keeping each person's Firebase Auth UID separate so the owner and caretaker can sign in on their own phones.

## Proposed Realtime Database shape

```text
users/{uid}
  name: string
  phone: normalized phone number
  createdAt: server timestamp
  fcmTokens/{tokenKey}: ...

ponds/pond1
  name: string
  ownerUid: {ownerUid}
  deviceId: "pond1"
  members/{uid}: "owner" | "caretaker"
  latestReading: { same reading fields as a history item }
  readings/{epochMillis}: { ph, temperature, dissolvedOxygen, ammonia, recordedAt, ... }
  alerts/{alertId}: ...
  settings: ...

pondInvites/{inviteId}
  pondId: "pond1"
  phone: normalized invitee phone number
  role: "caretaker"
  createdBy: {ownerUid}
  createdAt: server timestamp
  expiresAt: server timestamp
  status: "pending" | "accepted" | "revoked" | "expired"
```

The `members` map is the access list. A person can read pond data only when their signed-in UID is a member. Membership, owner assignment, and invitations are server-managed; clients cannot edit those records directly. The invite backend must allow no more than one caretaker in addition to the owner, and must check the limit again when an invite is accepted. That check belongs in trusted code so simultaneous invites cannot exceed the cap.

## Rules and migration notes

`database.rules.json` now includes member-gated reads for the proposed `ponds/{pondId}` branch, owner-only client writes under `settings`, and no direct client writes to memberships, readings, latest reading, alerts, or invites. The legacy readings path is also read-only for clients in these local rules, with reads limited to pond members. Admin SDK functions can maintain the protected records.

The ESP32 code has now been confirmed: it creates a Firebase anonymous-auth session with `Firebase.signUp(&config, &auth, "", "")` and appends readings to `/readings/pond1/{epochMillis}`. The existing deployed rule allows writes to new reading keys without checking the authenticated UID, so it is not a device-only permission; anyone who can reach that path can attempt to append readings. The local target rules close client writes to this old path, so deploy them only after the updated firmware is installed and verified.

The local Cloud Functions source now includes `ingestSensorReading`: an HTTPS endpoint that checks a device HMAC signature, a 60-second timestamp window, a single-use nonce, a 2-second minimum interval, and sensor-value ranges. It writes validated history and updates `latestReading` via Admin SDK. The risk-alert trigger now listens under the pond and sends alerts to the registered devices of pond members. Do not grant signed-in app users write access to pond readings.

The ESP32 source uses the signing contract: POST compact JSON containing numeric `ph`, `temperature`, `dissolvedOxygen`, and `ammonia` (plus optional `batteryPercent`); include `x-device-id: pond1`, `x-device-timestamp` (Unix seconds), `x-device-nonce` (32 random hex characters), and `x-device-signature` (lowercase hex HMAC-SHA256). Sign the exact UTF-8 request body prefixed by `${timestamp}\n${nonce}\n`. Add the same randomly generated 32-byte secret to Firebase Secret Manager as `DEVICE_HMAC_SECRET` and to the device-only `secrets.h`; define `INGEST_URL` there too. The firmware uses the ESP32 trusted certificate bundle for HTTPS verification, so it does not need a pinned CA string in `secrets.h`. Never disable TLS verification. The firmware is not ready to compile or send until the URL and secret are configured.

## Configure the device secrets

After setting `DEVICE_HMAC_SECRET` in Firebase Secret Manager and deploying the function, Firebase CLI prints the exact URL. For this project and region, it should follow `https://asia-southeast1-catfisense-db-4cda7.cloudfunctions.net/ingestSensorReading`; use the CLI output as the source of truth. Generate a 32-byte random value (64 hex characters), enter that same value when `firebase functions:secrets:set DEVICE_HMAC_SECRET` prompts, and copy it to the `DEVICE_HMAC_SECRET` line in `secrets.h`. `INGEST_ROOT_CA` is intentionally not used: firmware now validates the server with the ESP32 certificate bundle rather than pinning one root certificate. Espressif documents its root bundle as a bundled trust store, and Google Trust Services advises clients not to hard-code CA certificates. [Espressif certificate bundle](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/protocols/esp_crt_bundle.html) · [Google Trust Services FAQ](https://pki.goog/faq/)

Migration order: create the initial pond/member records with Admin SDK; set the function secret and deploy the ingestion function; add device settings to `secrets.h`; backfill old history and switch the Flutter repository; flash the ESP32; confirm new history, latest values, and member alerts work; then deploy the read-only legacy rules.

The rules file is a local project artifact. This change does not deploy rules or create database records in Firebase. Seed the initial `ownerUid` and `members/{ownerUid}: "owner"` through Admin SDK after confirming which existing account is the owner.
