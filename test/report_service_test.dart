import 'package:catfisense/l10n/app_localizations.dart';
import 'package:catfisense/services/logbook_service.dart';
import 'package:catfisense/services/pond_service.dart';
import 'package:catfisense/services/report_service.dart';
import 'package:catfisense/utils/sensor_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _start = DateTime(2026, 9, 28, 6);

SensorHistoryPoint _point(int minutes, {double oxygen = 6, double ammonia = 0.01}) => SensorHistoryPoint(
  time: _start.add(Duration(minutes: minutes)),
  ph: 7.4,
  temperature: 28.2,
  ammonia: ammonia,
  dissolvedOxygen: oxygen,
  phi: 2,
);

ReportData _data() => ReportData(
  start: _start,
  end: _start.add(const Duration(days: 2)),
  generatedAt: _start.add(const Duration(days: 2)),
  points: [
    for (var i = 0; i < 60; i++) _point(i),
    _point(61, oxygen: 2.8, ammonia: 0.06),
    _point(62, oxygen: 3.5),
    for (var i = 1500; i < 1560; i++) _point(i),
  ],
  logs: [
    LogEntry(
      id: 'a',
      type: LogType.aerator,
      at: _start.add(const Duration(minutes: 63)),
      byUid: 'u1',
      byRole: PondRole.caretaker,
      // Emoji and curly quotes must not break the Latin-1 PDF font.
      note: 'Aerator on “full” 💨 – DO was low',
    ),
  ],
);

void main() {
  setUpAll(() => initializeDateFormatting());

  for (final locale in AppLocalizations.supportedLocales) {
    test('builds a PDF in ${locale.languageCode}', () async {
      final l10n = lookupAppLocalizations(locale);
      final bytes = await const ReportService().buildPdf(l10n, _data());
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(2000));
    });
  }

  test('CSV has a header and one row per reading', () {
    final csv = ReportService.buildCsv(_data().points);
    final lines = csv.trim().split('\r\n');
    expect(lines.first, 'time,ph,temperature_c,dissolved_oxygen_mg_l,ammonia_mg_l,status');
    expect(lines, hasLength(_data().points.length + 1));
    expect(lines[61], '2026-09-28 07:01:00,7.40,28.20,2.80,0.060,critical');
  });
}
