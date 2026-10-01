import 'package:catfisense/l10n/app_localizations.dart';
import 'package:catfisense/services/pond_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('names are trimmed and inner spaces collapsed', () {
    expect(PondService.normalizeName('  Catfish   Pond 2 '), 'Catfish Pond 2');
  });

  test('empty or blank names are refused', () {
    expect(PondService.validatePondName(l10n, ''), l10n.pondNameRequired);
    expect(PondService.validatePondName(l10n, '   '), l10n.pondNameRequired);
    expect(PondService.validatePondName(l10n, null), l10n.pondNameRequired);
  });

  test('names longer than the database allows are refused', () {
    expect(PondService.validatePondName(l10n, 'x' * PondService.maxNameLength), isNull);
    expect(
      PondService.validatePondName(l10n, 'x' * (PondService.maxNameLength + 1)),
      l10n.pondNameTooLong(PondService.maxNameLength),
    );
  });
}
