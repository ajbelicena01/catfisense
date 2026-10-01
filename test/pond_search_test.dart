import 'package:catfisense/services/admin_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pond = PondSummary(
    id: 'pond1',
    name: 'Tiwi Pond_1',
    code: 'WDRPCEP7',
    ownerUid: 'A',
    caretakerUid: 'B',
    phones: {'A': '09171234567'},
    names: {'B': 'Aling Rosa'},
  );

  bool matches(String query) => pondMatchesSearch(pond, query, userPhones: const {'B': '09998887777'});

  test('blank search matches everything', () {
    expect(matches(''), isTrue);
    expect(matches('   '), isTrue);
  });

  test('matches name, ID and code, ignoring case', () {
    expect(matches('tiwi'), isTrue);
    expect(matches('POND1'), isTrue);
    expect(matches('wdrp'), isTrue);
    expect(matches('WDRP-CEP7'), isTrue);
  });

  test('matches member names and phone numbers, however they are typed', () {
    expect(matches('rosa'), isTrue);
    expect(matches('0917 123 4567'), isTrue);
    expect(matches('4567'), isTrue);
    // The caretaker's number comes from their profile.
    expect(matches('0999-888'), isTrue);
  });

  test('no match', () {
    expect(matches('bangus'), isFalse);
    expect(matches('0918'), isFalse);
  });
}
