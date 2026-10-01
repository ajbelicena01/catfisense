# CatFiSense single-pond data model

CatFiSense currently has one pond (`pond1`) and one sensor device. Keep the pond ID stable, while keeping each person's Firebase Auth UID separate so the owner and caretaker can sign in on their own phones.

## Sign-in and pond codes (current)

`AuthGate` picks the root screen: not logged in → welcome (LOGIN / SIGN UP); logged in but `users/{uid}/pondId` unset → pond code entry; linked → dashboard. Sign-up runs phone + password → OTP (placeholder) → pond code → onboarding → dashboard. Login goes straight to the dashboard for a linked account.

Each pond has a code stored as `pondCodes/{CODE}: pondId` (8 characters, shown as `XXXX-XXXX`, stored without the dash), with the current one also at `ponds/{pondId}/code`. The code stays the same until the owner changes it. Joining is done by the client in one multi-path update, and `database.rules.json` enforces it without Cloud Functions:

- a signed-in user can read one code they already know, never list codes;
- `ponds/{pondId}/ownerUid` and `caretakerUid` can each be set once, to the caller's own UID, and only when `users/{uid}/pondCode` is a valid code for that pond. The caretaker slot needs an owner first;
- `ponds/{pondId}/members/{uid}` can only be added by that user, and only matching the slot they hold;
- `ponds/{pondId}/memberPhones/{uid}` is written by each member at join time so the owner can see who the caretaker is;
- `users/{uid}/pondId` is only accepted when the user is a member of that pond;
- `readings/pond1` is readable by `pond1` members only. Device writes and `smsQueue` are unchanged.

A code can therefore never add more than one owner and one caretaker.

The owner manages the pond from Settings → Pond members:

- **Invite:** share the pond code; the caretaker signs up and enters it.
- **Remove caretaker:** clears `caretakerUid`, `members/{uid}` and `memberPhones/{uid}` together (the rules refuse a partial removal). The caretaker's app loses read access at once and returns to the pond code screen.
- **Change code:** adds the new `pondCodes` entry, deletes the old one and updates `ponds/{pondId}/code` in one update. A removed caretaker can rejoin with the old code until it is changed; current members are unaffected.
- **Rename pond:** Settings shows every member the pond name (`ponds/{pondId}/name`); the owner can tap it to rename. Names are 1–40 characters with no spaces at either end, can't be deleted, and each rename is added to the audit log.

The owner can't free their own slot; an admin can (see below). In Git Bash, prefix `firebase database:*` commands with `MSYS_NO_PATHCONV=1` so `/…` paths are not rewritten. Changing a phone number creates a new Firebase account (see `AuthService.updatePhoneNumber`), so that account must be linked again and needs a free slot.

## Pond logbook

`ponds/{pondId}/logs/{pushId}` holds what was done at the pond: `{type, at, byUid, byRole, byPhone?, note?}`. `type` is one of `feeding`, `waterChange`, `aerator`, `treatment`, `other` (matching `LogType` in `logbook_service.dart`). The rules let any member add an entry under their own UID and actual role, with `at` no later than now and no earlier than 30 days back, and a note of at most 200 characters. Entries can't be edited. Members can delete their own entries and the owner can delete any. `.indexOn: ["at"]` backs the time-range queries used by the Logbook page, the History chart markers and the PDF report.

## Adding ponds

A pond's ID is its device's ID: readings are at `readings/{pondId}` and the pond at `ponds/{pondId}` (with `deviceId` equal to the ID). The first ESP32 writes to `readings/pond1`; any other device may only write under its own Firebase login UID (`readings/{auth.uid}`), and only members of the pond with that ID (and admins) can read it.

An admin adds a pond on the Ponds tab with the device ID and a name. The app and the rules refuse an ID with no readings, one that is already a pond, or one that is not 3–40 letters, digits, `-` or `_`. The pond is created with a new join code in one update, and the first person to join with it becomes the owner. `name` and `code` can only be written for a pond that has a `deviceId`, so no half-made ponds. The farmer screens follow the signed-in member's pond (`SensorRepository.deviceId`, set by `AuthGate`), and the admin Health tab has a pond picker. The SMS gateway still serves `pond1` only.

## Maintenance

`ponds/{pondId}/maintenance/{task}: {lastDone, intervalDays, byUid, updatedAt, note?}` for four tasks: `doElectrolyte` and `phBuffer` (default every 90 days), `modemLoad` and `gsmLoad` (default every 30 days; see `utils/maintenance.dart`). Any member can set one up or mark it done on the Maintenance page; admins can set up or edit a pond's schedule from the Ponds tab. Setting up or editing a schedule (not marking it done) is recorded in the audit log for admins and owners, and changing one that is already set up asks for confirmation first. The rules allow only these task names, a `lastDone` within the past year, a whole-number interval of 1–365 days, `byUid` = the caller and `updatedAt` = the server time, and tasks can't be deleted.

Marking a task done also adds a logbook entry of type `maintenance` with `task` set, in the same update (skipped when the date is older than the logbook's 30-day window), so it shows in the logbook, on the History chart and in reports. A task is due soon from 7 days before the due date for intervals of 60 days or more, otherwise 3 days before. `MaintenanceController` shows a Dashboard banner for tasks due soon or overdue and, while push alerts are on, schedules phone reminders at 9 AM when the due-soon window opens, on the due day, and 3 days after.

## Admins

Admin accounts log in with a username (`admin_<name>`), which maps to `admin_<name>@catfisense.app` in Firebase Auth. An account is an admin only if `admins/{uid}: {username}` exists; that list can't be written from the app, so admins are added with the Firebase CLI. All admins have the same access. `AuthGate` opens the admin area (`pages/admin/`) for them instead of the farmer screens.

What the rules give admins on top of a normal account:

- read `users`, `ponds`, `admins`, `readings/pond1`, `auditLog` and `gatewayStatus`;
- remove any member, including freeing the owner slot, and clear that user's `pondId` (slot, `members` and `memberPhones` entries must be removed together);
- create and delete `pondCodes`, change `ponds/{id}/code` and rename any pond;
- name members (`ponds/{id}/memberNames/{uid}`, 1–40 characters, members only), shown instead of their phone numbers in the admin area and the owner's Settings. Only admins can set a name; removing a member clears it in the same update; delete any logbook entry;
- write `config/thresholds` and `smsRecipients`.

## Thresholds

`config/thresholds` holds `{ph, temperature: {healthyMin, healthyMax, warningMin, warningMax}, dissolvedOxygen: {healthyMin, warningMin}, ammonia: {healthyMax, warningMax}}`. Any signed-in user can read it; only admins can write it. `ThresholdController` keeps `Thresholds.current` in sync (with a copy on the phone for offline starts), and every status check, the pond health index, alerts, advice and reports use it. Missing or out-of-order values fall back to the defaults in `utils/thresholds.dart`. The ESP32 still uses its own built-in ranges for deciding when to queue SMS alerts.

## SMS alert numbers

`smsRecipients/{pondId}/{639XXXXXXXXX}: "+639XXXXXXXXX"`. Pond owners and admins edit it in the app. The gateway app sends every queued alert to all of these numbers, ignoring the `to` the ESP32 wrote, so no firmware change is needed; while the list is empty it falls back to its built-in `allowedRecipients`. Any signed-in account can read the list (the gateway signs in anonymously), the same exposure `smsQueue` already has. The gateway also writes `gatewayStatus/{device}/lastSeen` every minute.

## Audit log

`auditLog/{pushId}: {at, byUid, byName, action, pondId?, target?, details?}`, written by admins and pond owners (owners only about their own pond) when they change thresholds, remove members, change a pond code, rename a pond, add or remove SMS numbers, or delete someone else's logbook entry. Only admins can read it. Entries can't be edited or deleted, and `at` must be the current time.

## Derived views (no stored data)

- **Alert history** (`utils/alert_history.dart`) is worked out on the phone from the readings of the chosen period: an alert starts when any parameter leaves its healthy band and ends when all are healthy again, or when readings stop for more than 10 minutes.
- **Sensor offline / no internet** banners on the Dashboard use the newest reading's time (offline after 2 minutes without one) and `.info/connected`.
- **Reports** (`services/report_service.dart`) build a PDF or CSV from the same readings, alerts and logbook entries and hand the file to the phone's share sheet.
- **Device health** (`utils/device_health.dart`, admin Health tab) uses the last 24 hours of readings: a reading's key is the ESP32's send time and `recordedAt` is when Firebase stored it, so the difference is the upload delay.

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
