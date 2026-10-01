import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';
import '../l10n/app_localizations.dart';

enum AuthError {
  phoneTaken,
  weakPassword,
  wrongCredentials,
  recentLogin,
  notSignedIn,
  samePhone,
  generic;

  String message(AppLocalizations l10n) => switch (this) {
    AuthError.phoneTaken => l10n.authPhoneTaken,
    AuthError.weakPassword => l10n.authWeakPassword,
    AuthError.wrongCredentials => l10n.authWrongCredentials,
    AuthError.recentLogin => l10n.authRecentLogin,
    AuthError.notSignedIn => l10n.authNotSignedIn,
    AuthError.samePhone => l10n.authSamePhone,
    AuthError.generic => l10n.authGeneric,
  };
}

class AuthResult {
  const AuthResult.success() : error = null;
  const AuthResult.failure(AuthError this.error);

  final AuthError? error;
  bool get success => error == null;
}

/// Firebase Auth has no native "phone + password" sign-in method, so each
/// user is registered under a synthetic email derived from their phone
/// number (e.g. 09171234567 -> 09171234567@catfisense.app). The phone
/// number is what the UI ever shows; Firebase still owns secure password
/// storage under the hood.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _authOverride = auth;

  final FirebaseAuth? _authOverride;

  // Resolved lazily (not in the constructor) so the login/signup forms can
  // still build before Firebase.initializeApp() has run during setup.
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  // On Android, the default FirebaseApp can end up auto-initialized natively
  // from google-services.json (which has no Realtime Database URL in it), so
  // FirebaseDatabase.instance alone may not know which RTDB instance to use.
  // Pointing at the URL explicitly avoids depending on which app config won.
  FirebaseDatabase get _database =>
      FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL);

  User? get currentUser => _auth.currentUser;

  /// The phone number is all the UI ever shows; recover it from the
  /// synthetic email's local part for display purposes.
  String? get currentPhoneDigits => _auth.currentUser?.email?.split('@').first;

  /// Admin accounts log in with a username such as `admin_belicena`
  /// instead of a phone number; they map to `<username>@catfisense.app` the
  /// same way phone numbers do. Admin accounts are created by the project
  /// team, never through the app's sign-up.
  static final _adminUsername = RegExp(r'^admin_[a-z0-9_]{2,30}$');

  static bool isAdminUsername(String input) => _adminUsername.hasMatch(input.trim().toLowerCase());

  String _emailForLogin(String phoneOrUsername) {
    final input = phoneOrUsername.trim().toLowerCase();
    return isAdminUsername(input) ? '$input@catfisense.app' : _emailForPhone(input);
  }

  String _emailForPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return '$digits@catfisense.app';
  }

  Future<AuthResult> signUp({required String phone, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailForPhone(phone),
        password: password,
      );
      try {
        await _writeProfile(uid: credential.user!.uid, phone: phone);
      } on FirebaseException {
        // The account already exists and is signed in; a missing profile
        // must not strand the user on a spinner with a "taken" number.
      }
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_error(e.code));
    }
  }

  Future<void> _writeProfile({required String uid, required String phone}) {
    return _database.ref('users/$uid').set({
      'phone': phone,
      'createdAt': ServerValue.timestamp,
    });
  }

  /// [phone] may also be an admin username (see [isAdminUsername]).
  Future<AuthResult> login({required String phone, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailForLogin(phone),
        password: password,
      );
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_error(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<AuthResult> _reauthenticate(User user, String currentPassword) async {
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: currentPassword),
      );
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_error(e.code));
    }
  }

  /// Firebase Auth removed [User.updateEmail] in favor of
  /// [User.verifyBeforeUpdateEmail], which only takes effect once the user
  /// clicks a confirmation link sent to the new email — but this app's
  /// "emails" are synthetic placeholders with no real mailbox behind them, so
  /// that link could never be delivered or clicked.
  ///
  /// Instead, changing the phone number creates a fresh account under the
  /// new synthetic email (new account is created before the old one is
  /// removed, so a failure here never leaves the user accountless) and
  /// retires the old one. This means the Firebase Auth UID changes, which
  /// orphans the old uid's `readings/<uid>` history in the Realtime
  /// Database — the new account starts with a clean slate and no past
  /// chart data. Fine for now; the real fix is a phone -> uid lookup table
  /// so the uid (and its data) stays stable across a number change.
  Future<AuthResult> updatePhoneNumber({required String currentPassword, required String newPhone}) async {
    final oldUser = _auth.currentUser;
    if (oldUser == null || oldUser.email == null) {
      return const AuthResult.failure(AuthError.notSignedIn);
    }

    final reauth = await _reauthenticate(oldUser, currentPassword);
    if (!reauth.success) return reauth;

    final newEmail = _emailForPhone(newPhone);
    if (newEmail == oldUser.email) {
      return const AuthResult.failure(AuthError.samePhone);
    }

    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(email: newEmail, password: currentPassword);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_error(e.code));
    }
    await _writeProfile(uid: credential.user!.uid, phone: newPhone);

    try {
      await oldUser.delete();
    } catch (_) {
      // Best-effort cleanup; the new account is already active either way.
    }
    return const AuthResult.success();
  }

  Future<AuthResult> updatePassword({required String currentPassword, required String newPassword}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return const AuthResult.failure(AuthError.notSignedIn);
    }

    final reauth = await _reauthenticate(user, currentPassword);
    if (!reauth.success) return reauth;

    try {
      await user.updatePassword(newPassword);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_error(e.code));
    }
  }

  AuthError _error(String code) => switch (code) {
    'email-already-in-use' => AuthError.phoneTaken,
    'weak-password' => AuthError.weakPassword,
    'user-not-found' || 'wrong-password' || 'invalid-credential' => AuthError.wrongCredentials,
    'requires-recent-login' => AuthError.recentLogin,
    _ => AuthError.generic,
  };
}
