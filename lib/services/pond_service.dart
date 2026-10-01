import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_options.dart';
import '../l10n/app_localizations.dart';
import 'audit_service.dart';

enum PondRole {
  owner,
  caretaker;

  static PondRole? fromName(Object? name) =>
      PondRole.values.where((role) => role.name == name).firstOrNull;
}

class PondMembership {
  const PondMembership({required this.pondId, required this.role});

  final String pondId;
  final PondRole role;
}

/// What the owner's Settings shows: the current code and the caretaker slot.
class PondDetails {
  const PondDetails({this.code, this.caretakerUid, this.caretakerPhone, this.caretakerName});

  final String? code;
  final String? caretakerUid;
  final String? caretakerPhone;

  /// Set by an admin; shown instead of the phone number.
  final String? caretakerName;
}

enum PondJoinError {
  notLoggedIn,
  notFound,
  network,
  full;

  String message(AppLocalizations l10n) => switch (this) {
    PondJoinError.notLoggedIn => l10n.authNotSignedIn,
    PondJoinError.notFound => l10n.pondJoinNotFound,
    PondJoinError.network => l10n.pondJoinNetwork,
    PondJoinError.full => l10n.pondJoinFull,
  };
}

class PondJoinResult {
  const PondJoinResult.success(PondRole this.role) : error = null;
  const PondJoinResult.failure(PondJoinError this.error) : role = null;

  final PondRole? role;
  final PondJoinError? error;
  bool get success => error == null;
}

enum PondCreateError {
  invalidId,
  noReadings,
  exists,
  network;

  String message(AppLocalizations l10n) => switch (this) {
    PondCreateError.invalidId => l10n.addPondInvalidId,
    PondCreateError.noReadings => l10n.addPondNoReadings,
    PondCreateError.exists => l10n.addPondExists,
    PondCreateError.network => l10n.addPondError,
  };
}

class PondCreateResult {
  const PondCreateResult.success(String this.code) : error = null;
  const PondCreateResult.failure(PondCreateError this.error) : code = null;

  /// The new pond's join code.
  final String? code;
  final PondCreateError? error;
}

/// Links a signed-in account to a pond using the pond's permanent code, and
/// lets the pond's owner manage the caretaker and the code.
///
/// Codes live at `pondCodes/<CODE>: <pondId>`, with the current one also at
/// `ponds/<pondId>/code`. The database rules only let a signed-in user read
/// one code they already know (never list them), and only let them add
/// themselves to a pond when `users/<uid>/pondCode` holds a valid code for
/// it. Each pond has one owner slot and one caretaker slot (`ownerUid` /
/// `caretakerUid`), so a leaked code can never add more than those two
/// people. Only the owner can free the caretaker slot or change the code.
class PondService {
  PondService({FirebaseAuth? auth, FirebaseDatabase? database})
    : _authOverride = auth,
      _databaseOverride = database;

  final FirebaseAuth? _authOverride;
  final FirebaseDatabase? _databaseOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  // See SensorRepository: point at the RTDB URL explicitly on Android.
  FirebaseDatabase get _database =>
      _databaseOverride ??
      FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
      );

  // No 0/O, 1/I/L, so a code read aloud or off a screen can't be misread.
  static const _codeAlphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  /// Codes are shown as `ABCD-2345` but stored without the dash, uppercase.
  static String normalizeCode(String input) =>
      input.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static String formatCode(String code) =>
      code.length == 8 ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

  static String? validateCode(AppLocalizations l10n, String? value) {
    final code = normalizeCode(value ?? '');
    return code.length == 8 ? null : l10n.pondCodeInvalid;
  }

  /// For pond and member names; also enforced by the database rules.
  static const maxNameLength = 40;

  /// Trimmed, with runs of spaces collapsed to one.
  static String normalizeName(String input) => input.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String? validatePondName(AppLocalizations l10n, String? value) {
    final name = normalizeName(value ?? '');
    if (name.isEmpty) return l10n.pondNameRequired;
    if (name.length > maxNameLength) return l10n.pondNameTooLong(maxNameLength);
    return null;
  }

  static String _newCode() {
    final random = Random.secure();
    return List.generate(8, (_) => _codeAlphabet[random.nextInt(_codeAlphabet.length)]).join();
  }

  /// The account's phone number, from its synthetic `<digits>@catfisense.app`
  /// email; stored with the membership so the owner can see who joined.
  String? get _phoneDigits => _auth.currentUser?.email?.split('@').first;

  /// This user's pond and role, or null when not linked. Emits again when a
  /// code is accepted, and null when the owner removes this user (the rules
  /// then cancel the listener), so [AuthGate] follows along live. Each pond
  /// is also remembered on the phone for [cachedPondId].
  Stream<PondMembership?> membership(String uid) {
    StreamSubscription<DatabaseEvent>? pondIdSub;
    StreamSubscription<DatabaseEvent>? roleSub;
    late final StreamController<PondMembership?> controller;

    void emit(PondMembership? membership) {
      unawaited(_cachePondId(uid, membership?.pondId));
      controller.add(membership);
    }

    controller = StreamController<PondMembership?>(
      onListen: () {
        pondIdSub = _database.ref('users/$uid/pondId').onValue.listen((event) {
          roleSub?.cancel();
          roleSub = null;
          final pondId = event.snapshot.value as String?;
          if (pondId == null) {
            emit(null);
            return;
          }
          roleSub = _database
              .ref('ponds/$pondId/members/$uid')
              .onValue
              .listen(
                (event) {
                  final role = PondRole.fromName(event.snapshot.value);
                  emit(role == null ? null : PondMembership(pondId: pondId, role: role));
                },
                // Non-members can't read the pond at all, so a removed member
                // gets a permission error here rather than a null value.
                onError: (Object _) => emit(null),
              );
        }, onError: controller.addError);
      },
      onCancel: () async {
        await roleSub?.cancel();
        await pondIdSub?.cancel();
      },
    );
    return controller.stream;
  }

  /// The last pond [membership] reported for this user on this phone. The
  /// database has no offline cache here, so without this an app start with
  /// no connection would wait on the loading screen until one comes back.
  Future<String?> cachedPondId(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cacheKey(uid));
  }

  Future<void> _cachePondId(String uid, String? pondId) async {
    final prefs = await SharedPreferences.getInstance();
    if (pondId == null) {
      await prefs.remove(_cacheKey(uid));
    } else {
      await prefs.setString(_cacheKey(uid), pondId);
    }
  }

  static String _cacheKey(String uid) => 'linkedPondId_$uid';

  Future<PondJoinResult> joinWithCode(String rawCode) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const PondJoinResult.failure(PondJoinError.notLoggedIn);
    }
    final code = normalizeCode(rawCode);

    final String? pondId;
    try {
      pondId = (await _database.ref('pondCodes/$code').get()).value as String?;
    } on FirebaseException {
      return const PondJoinResult.failure(PondJoinError.network);
    }
    if (pondId == null) {
      return const PondJoinResult.failure(PondJoinError.notFound);
    }

    final phone = _phoneDigits;
    final link = {
      'users/$uid/pondCode': code,
      'users/$uid/pondId': pondId,
      'ponds/$pondId/memberPhones/$uid': ?phone,
    };

    // Already a member (e.g. the link on this account was cleared): relink
    // without touching the slots. Non-members get a permission error here.
    try {
      final existing = PondRole.fromName((await _database.ref('ponds/$pondId/members/$uid').get()).value);
      if (existing != null) {
        await _database.ref().update(link);
        return PondJoinResult.success(existing);
      }
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') {
        return const PondJoinResult.failure(PondJoinError.network);
      }
    }

    // Try the owner slot first; the rules reject it if the pond already has
    // an owner, and then the caretaker slot is the only one left.
    for (final role in PondRole.values) {
      final slot = role == PondRole.owner ? 'ownerUid' : 'caretakerUid';
      try {
        await _database.ref().update({
          ...link,
          'ponds/$pondId/$slot': uid,
          'ponds/$pondId/members/$uid': role.name,
        });
        return PondJoinResult.success(role);
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') {
          return const PondJoinResult.failure(PondJoinError.network);
        }
      }
    }
    return const PondJoinResult.failure(PondJoinError.full);
  }

  /// Live code and caretaker for the owner's Settings. Only members can read
  /// these; the caller should only subscribe for an owner.
  Stream<PondDetails> pondDetails(String pondId) {
    final pond = _database.ref('ponds/$pondId');
    final values = <String, Object?>{};
    const keys = ['code', 'caretakerUid', 'memberPhones', 'memberNames'];
    final subs = <StreamSubscription<DatabaseEvent>>[];
    late final StreamController<PondDetails> controller;

    void emit() {
      if (values.length < keys.length) return;
      final caretakerUid = values['caretakerUid'] as String?;
      final phones = values['memberPhones'];
      final names = values['memberNames'];
      controller.add(
        PondDetails(
          code: values['code'] as String?,
          caretakerUid: caretakerUid,
          caretakerPhone: phones is Map && caretakerUid != null ? phones[caretakerUid] as String? : null,
          caretakerName: names is Map && caretakerUid != null ? names[caretakerUid] as String? : null,
        ),
      );
    }

    controller = StreamController<PondDetails>(
      onListen: () {
        for (final key in keys) {
          subs.add(
            pond
                .child(key)
                .onValue
                .listen(
                  (event) {
                    values[key] = event.snapshot.value;
                    emit();
                  },
                  onError: controller.addError,
                ),
          );
        }
      },
      onCancel: () => Future.wait(subs.map((sub) => sub.cancel())),
    );
    return controller.stream;
  }

  /// What a device ID (the pond's ID) may look like; also checked by the
  /// database rules. Firebase login UIDs and `pond1` both fit.
  static final _deviceIdPattern = RegExp(r'^[A-Za-z0-9_-]{3,40}$');

  /// Admin only: adds a pond for the device whose readings are at
  /// `readings/<deviceId>`, with [name] and a fresh join code. Fails if that
  /// device has sent nothing or is already a pond.
  Future<PondCreateResult> createPond({required String deviceId, required String name}) async {
    final id = deviceId.trim();
    if (!_deviceIdPattern.hasMatch(id)) return const PondCreateResult.failure(PondCreateError.invalidId);
    try {
      if ((await _database.ref('ponds/$id/deviceId').get()).exists) {
        return const PondCreateResult.failure(PondCreateError.exists);
      }
      if (!(await _database.ref('readings/$id').limitToLast(1).get()).exists) {
        return const PondCreateResult.failure(PondCreateError.noReadings);
      }
      final pondName = normalizeName(name);
      for (var attempt = 0; attempt < 3; attempt++) {
        final code = _newCode();
        try {
          await _database.ref().update({
            'ponds/$id/deviceId': id,
            'ponds/$id/name': pondName,
            'ponds/$id/code': code,
            'pondCodes/$code': id,
          });
          await const AuditService().log(AuditAction.pondAdded, pondId: id, target: pondName);
          return PondCreateResult.success(code);
        } on FirebaseException catch (e) {
          // A taken code is refused like any other write; try another.
          if (e.code != 'permission-denied') rethrow;
        }
      }
      return const PondCreateResult.failure(PondCreateError.network);
    } on FirebaseException {
      return const PondCreateResult.failure(PondCreateError.network);
    }
  }

  /// The pond's display name, live. Any member can read it.
  Stream<String?> pondName(String pondId) =>
      _database.ref('ponds/$pondId/name').onValue.map((event) => event.snapshot.value as String?);

  /// Owner or admin only. Returns whether it worked.
  Future<bool> renamePond({required String pondId, required String name, String? oldName}) async {
    final newName = normalizeName(name);
    try {
      await _database.ref('ponds/$pondId/name').set(newName);
      await const AuditService().log(
        AuditAction.pondRenamed,
        pondId: pondId,
        details: '${oldName ?? '-'} -> $newName',
      );
      return true;
    } on FirebaseException {
      return false;
    }
  }

  /// Admin only: the name shown for member [uid] instead of their phone
  /// number. A blank [name] clears it. [label] (e.g. the phone number) is
  /// what the audit log shows.
  Future<bool> setMemberName({
    required String pondId,
    required String uid,
    required String name,
    String? oldName,
    String? label,
  }) async {
    final newName = normalizeName(name);
    try {
      await _database.ref('ponds/$pondId/memberNames/$uid').set(newName.isEmpty ? null : newName);
      await const AuditService().log(
        AuditAction.memberRenamed,
        pondId: pondId,
        target: label ?? uid,
        details: '${oldName ?? '-'} -> ${newName.isEmpty ? '-' : newName}',
      );
      return true;
    } on FirebaseException {
      return false;
    }
  }

  /// Owner only: frees the caretaker slot. The removed caretaker loses
  /// access at once, but can rejoin with the current code until it changes.
  /// Returns whether it worked. [label] (e.g. the phone number) is what the
  /// audit log shows.
  Future<bool> removeCaretaker({required String pondId, required String caretakerUid, String? label}) async {
    try {
      await _database.ref().update({
        'ponds/$pondId/caretakerUid': null,
        'ponds/$pondId/members/$caretakerUid': null,
        'ponds/$pondId/memberPhones/$caretakerUid': null,
        'ponds/$pondId/memberNames/$caretakerUid': null,
      });
      await const AuditService().log(AuditAction.caretakerRemoved, pondId: pondId, target: label ?? caretakerUid);
      return true;
    } on FirebaseException {
      return false;
    }
  }

  /// Admin only: takes [uid] out of [pondId], whichever slot they hold, and
  /// clears their link so their app returns to the pond code screen. Frees
  /// the owner slot too, which the owner can't do themselves.
  Future<bool> removeMemberAsAdmin({
    required String pondId,
    required String uid,
    required PondRole role,
    String? label,
  }) async {
    try {
      await _database.ref().update({
        'ponds/$pondId/${role == PondRole.owner ? 'ownerUid' : 'caretakerUid'}': null,
        'ponds/$pondId/members/$uid': null,
        'ponds/$pondId/memberPhones/$uid': null,
        'ponds/$pondId/memberNames/$uid': null,
        'users/$uid/pondId': null,
      });
      await const AuditService().log(
        role == PondRole.owner ? AuditAction.ownerRemoved : AuditAction.caretakerRemoved,
        pondId: pondId,
        target: label ?? uid,
      );
      return true;
    } on FirebaseException {
      return false;
    }
  }

  /// Owner only: replaces the pond code. The old code stops working for new
  /// joins; current members stay in. Returns the new code, or null on failure.
  Future<String?> changeCode({required String pondId, String? oldCode}) async {
    // A fresh code can only collide with an existing one by extreme chance;
    // the rules refuse to overwrite a taken code, so just try another.
    for (var attempt = 0; attempt < 3; attempt++) {
      final code = _newCode();
      try {
        await _database.ref().update({
          'pondCodes/$code': pondId,
          if (oldCode != null) 'pondCodes/$oldCode': null,
          'ponds/$pondId/code': code,
        });
        await const AuditService().log(
          AuditAction.codeChanged,
          pondId: pondId,
          details: '${oldCode == null ? '-' : formatCode(oldCode)} -> ${formatCode(code)}',
        );
        return code;
      } on FirebaseException catch (e) {
        if (e.code != 'permission-denied') return null;
      }
    }
    return null;
  }
}
