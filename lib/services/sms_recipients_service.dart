import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../firebase_options.dart';
import 'audit_service.dart';

/// The numbers the SMS gateway phone texts pond alerts to, at
/// `smsRecipients/<pondId>/<639XXXXXXXXX>: "+639XXXXXXXXX"`. The gateway app
/// sends every queued alert to all of them, whatever number the ESP32 wrote
/// into the queue, so changing them here needs no firmware change. Pond
/// owners and admins can edit the list.
class SmsRecipientsService {
  const SmsRecipientsService();

  static FirebaseDatabase get _database => FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL,
  );

  /// "09171234567", "9171234567", "+63 917 123 4567" -> "+639171234567";
  /// null when it isn't a PH mobile number.
  static String? normalize(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('09') && digits.length == 11) digits = '63${digits.substring(1)}';
    if (digits.startsWith('9') && digits.length == 10) digits = '63$digits';
    return RegExp(r'^639\d{9}$').hasMatch(digits) ? '+$digits' : null;
  }

  /// "+639171234567" -> "0917 123 4567" for display.
  static String display(String number) {
    final local = number.startsWith('+63') ? '0${number.substring(3)}' : number;
    return local.length == 11 ? '${local.substring(0, 4)} ${local.substring(4, 7)} ${local.substring(7)}' : local;
  }

  Stream<List<String>> watch(String pondId) {
    return _database.ref('smsRecipients/$pondId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is! Map) return const <String>[];
      return [for (final value in data.values) if (value is String) value]..sort();
    });
  }

  /// [number] must already be [normalize]d. Returns whether it saved.
  Future<bool> add(String pondId, String number) async {
    try {
      await _database.ref('smsRecipients/$pondId/${number.substring(1)}').set(number);
      await const AuditService().log(AuditAction.recipientAdded, pondId: pondId, target: number);
      return true;
    } on FirebaseException {
      return false;
    }
  }

  Future<bool> remove(String pondId, String number) async {
    try {
      await _database.ref('smsRecipients/$pondId/${number.substring(1)}').remove();
      await const AuditService().log(AuditAction.recipientRemoved, pondId: pondId, target: number);
      return true;
    } on FirebaseException {
      return false;
    }
  }
}
