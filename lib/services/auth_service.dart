import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';

class AuthResult {
  const AuthResult.success() : error = null;
  const AuthResult.failure(this.error);

  final String? error;
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
      await _writeProfile(uid: credential.user!.uid, phone: phone);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_message(e.code));
    }
  }

  Future<void> _writeProfile({required String uid, required String phone}) {
    return _database.ref('users/$uid').set({
      'phone': phone,
      'createdAt': ServerValue.timestamp,
    });
  }

  Future<AuthResult> login({required String phone, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailForPhone(phone),
        password: password,
      );
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_message(e.code));
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
      return AuthResult.failure(_message(e.code));
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
      return const AuthResult.failure('You need to be signed in to do this.');
    }

    final reauth = await _reauthenticate(oldUser, currentPassword);
    if (!reauth.success) return reauth;

    final newEmail = _emailForPhone(newPhone);
    if (newEmail == oldUser.email) {
      return const AuthResult.failure('That is already your registered number.');
    }

    UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(email: newEmail, password: currentPassword);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_message(e.code));
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
      return const AuthResult.failure('You need to be signed in to do this.');
    }

    final reauth = await _reauthenticate(user, currentPassword);
    if (!reauth.success) return reauth;

    try {
      await user.updatePassword(newPassword);
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_message(e.code));
    }
  }

  String _message(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This phone number is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect phone number or password.';
      case 'requires-recent-login':
        return 'Please re-enter your current password to continue.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
