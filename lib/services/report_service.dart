import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' show DateUtils;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import '../utils/alert_history.dart';
import '../utils/maintenance.dart';
import '../utils/pond_status.dart';
import '../utils/sensor_history.dart';
import '../utils/thresholds.dart';
import '../utils/time_format.dart';
import 'logbook_service.dart';
import 'pond_service.dart';

/// Everything a report covers, fetched once when the export starts.
class ReportData {
  const ReportData({
    required this.start,
    required this.end,
    required this.points,
    required this.logs,
    required this.generatedAt,
  });

  final DateTime start;
  final DateTime end;

  /// Oldest first.
  final List<SensorHistoryPoint> points;

  /// Newest first, as the logbook returns them.
  final List<LogEntry> logs;
  final DateTime generatedAt;
}

enum _Param { ph, temperature, oxygen, ammonia }

/// Builds the PDF and CSV exports and hands them to the phone's share sheet.
///
/// The PDF uses the standard Helvetica font, which only covers Latin-1, so
/// the report avoids symbols like ≥ or subscripts and uses plain ASCII for
/// ranges ("6.5 - 8.5").
class ReportService {
  const ReportService();

  static final _csvTime = DateFormat('yyyy-MM-dd HH:mm:ss');

  Future<void> sharePdf(AppLocalizations l10n, ReportData data) async {
    final bytes = await buildPdf(l10n, data);
    await _share(l10n, bytes, 'pdf', 'application/pdf', data);
  }

  Future<void> shareCsv(AppLocalizations l10n, ReportData data) async {
    // A byte-order mark makes Excel open the file as UTF-8.
    final bytes = utf8.encode('﻿${buildCsv(data.points)}');
    await _share(l10n, bytes, 'csv', 'text/csv', data);
  }

  /// One row per reading; English column names so formulas and imports
  /// behave the same whatever language the app is in.
  static String buildCsv(List<SensorHistoryPoint> points) {
    final rows = [
      'time,ph,temperature_c,dissolved_oxygen_mg_l,ammonia_mg_l,status',
      for (final point in points)
        [
          _csvTime.format(point.time),
          point.ph.toStringAsFixed(2),
          point.temperature.toStringAsFixed(2),
          point.dissolvedOxygen.toStringAsFixed(2),
          point.ammonia.toStringAsFixed(3),
          _overall(point).name,
        ].join(','),
    ];
    return '${rows.join('\r\n')}\r\n';
  }

  Future<void> _share(AppLocalizations l10n, List<int> bytes, String extension, String mimeType, ReportData data) async {
    final day = DateFormat('yyyy-MM-dd');
    final name = 'catfisense-report_${day.format(data.start)}_to_${day.format(data.end)}.$extension';
    final file = File('${(await getTemporaryDirectory()).path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType)], subject: l10n.reportTitle, title: l10n.reportTitle),
    );
  }

  static PondStatus _overall(SensorHistoryPoint point) => worstOf([
    phStatus(point.ph),
    temperatureStatus(point.temperature),
    dissolvedOxygenStatus(point.dissolvedOxygen),
    ammoniaStatus(point.ammonia),
  ]);

  static double _value(_Param param, SensorHistoryPoint point) => switch (param) {
    _Param.ph => point.ph,
    _Param.temperature => point.temperature,
    _Param.oxygen => point.dissolvedOxygen,
    _Param.ammonia => point.ammonia,
  };

  static PondStatus _status(_Param param, SensorHistoryPoint point) => switch (param) {
    _Param.ph => phStatus(point.ph),
    _Param.temperature => temperatureStatus(point.temperature),
    _Param.oxygen => dissolvedOxygenStatus(point.dissolvedOxygen),
    _Param.ammonia => ammoniaStatus(point.ammonia),
  };

  static String _format(_Param param, double value) => switch (param) {
    _Param.ph => value.toStringAsFixed(1),
    _Param.temperature => '${value.toStringAsFixed(1)} °C',
    _Param.oxygen => '${value.toStringAsFixed(1)} mg/L',
    _Param.ammonia => '${value.toStringAsFixed(3)} mg/L',
  };

  static String _paramName(AppLocalizations l10n, _Param param) => switch (param) {
    _Param.ph => 'pH',
    _Param.temperature => l10n.paramTemperature,
    _Param.oxygen => l10n.paramOxygen,
    _Param.ammonia => l10n.paramAmmonia,
  };

  static String _healthyRange(_Param param) {
    final t = Thresholds.current;
    return switch (param) {
      _Param.ph => healthyRangeText(t.ph, ascii: true),
      _Param.temperature => healthyRangeText(t.temperature, unit: '°C', ascii: true),
      _Param.oxygen => healthyRangeText(t.dissolvedOxygen, unit: 'mg/L', ascii: true),
      _Param.ammonia => healthyRangeText(t.ammonia, unit: 'mg/L', ascii: true),
    };
  }

  static String _issueText(AppLocalizations l10n, AlertIssueSummary summary) {
    final name = switch (summary.issue) {
      AlertIssue.lowPh => l10n.issueLowPh,
      AlertIssue.highPh => l10n.issueHighPh,
      AlertIssue.lowTemperature => l10n.issueLowTemperature,
      AlertIssue.highTemperature => l10n.issueHighTemperature,
      AlertIssue.lowOxygen => l10n.issueLowOxygen,
      AlertIssue.highAmmonia => l10n.issueHighAmmonia,
    };
    final param = switch (summary.issue) {
      AlertIssue.lowPh || AlertIssue.highPh => _Param.ph,
      AlertIssue.lowTemperature || AlertIssue.highTemperature => _Param.temperature,
      AlertIssue.lowOxygen => _Param.oxygen,
      AlertIssue.highAmmonia => _Param.ammonia,
    };
    final value = _format(param, summary.extremeValue);
    return '$name (${summary.issue.isHigh ? l10n.alertHighest(value) : l10n.alertLowest(value)})';
  }

  static String _logLabel(AppLocalizations l10n, LogEntry entry) => switch (entry.type) {
    LogType.feeding => l10n.logTypeFeeding,
    LogType.waterChange => l10n.logTypeWaterChange,
    LogType.aerator => l10n.logTypeAerator,
    LogType.treatment => l10n.logTypeTreatment,
    LogType.maintenance => entry.task == null ? l10n.logTypeMaintenance : maintenanceDoneLabel(l10n, entry.task!),
    LogType.other => l10n.logTypeOther,
  };

  Future<List<int>> buildPdf(AppLocalizations l10n, ReportData data) async {
    final date = DateFormat.yMMMd(l10n.localeName);
    final points = data.points;
    final alerts = detectAlerts(points, now: data.generatedAt);
    final goodShare = points.isEmpty
        ? 0
        : (100 * points.where((point) => _overall(point) == PondStatus.healthy).length / points.length).round();

    final doc = pw.Document(title: l10n.reportTitle, creator: l10n.appName);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: _text(
            l10n.reportPage(context.pageNumber, context.pagesCount),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
        build: (context) => [
          _text(l10n.reportTitle, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          _text(l10n.reportPeriod(date.format(data.start), date.format(data.end))),
          _text(
            l10n.reportGenerated(dateTimeLabel(l10n, data.generatedAt)),
            style: const pw.TextStyle(color: PdfColors.grey700),
          ),
          _heading(l10n.reportSummary),
          _text('${l10n.reportReadingsCount(points.length)} - ${l10n.reportGoodShare(goodShare)}'),
          pw.SizedBox(height: 8),
          _table(
            [l10n.reportParameter, l10n.reportLowest, l10n.reportAverage, l10n.reportHighest, l10n.reportHealthyRange, l10n.reportGoodReadings],
            [
              for (final param in _Param.values)
                if (points.isNotEmpty)
                  () {
                    final values = points.map((point) => _value(param, point)).toList();
                    final good = points.where((point) => _status(param, point) == PondStatus.healthy).length;
                    return [
                      _paramName(l10n, param),
                      _format(param, values.reduce((a, b) => a < b ? a : b)),
                      _format(param, values.reduce((a, b) => a + b) / values.length),
                      _format(param, values.reduce((a, b) => a > b ? a : b)),
                      _healthyRange(param),
                      '${(100 * good / points.length).round()}%',
                    ];
                  }(),
            ],
          ),
          _heading(l10n.reportAlerts),
          if (alerts.isEmpty)
            _text(l10n.alertsNoneTitle)
          else
            _table(
              [l10n.reportStarted, l10n.reportDuration, l10n.reportStatus, l10n.reportDetails],
              [
                for (final alert in alerts)
                  [
                    dateTimeLabel(l10n, alert.start),
                    alert.ongoing ? l10n.alertOngoing : durationLabel(l10n, alert.duration),
                    statusShortLabel(l10n, alert.worst),
                    alert.issues.map((issue) => _issueText(l10n, issue)).join('\n'),
                  ],
              ],
              flex: const [3, 2, 2, 6],
            ),
          _heading(l10n.logbookNav),
          if (data.logs.isEmpty)
            _text(l10n.reportNoLogs)
          else
            _table(
              [l10n.reportTime, l10n.reportActivity, l10n.reportNote, l10n.reportBy],
              [
                for (final entry in data.logs.reversed)
                  [
                    dateTimeLabel(l10n, entry.at),
                    _logLabel(l10n, entry),
                    entry.note ?? '',
                    switch (entry.byRole) {
                      PondRole.owner => l10n.roleOwner,
                      PondRole.caretaker => l10n.roleCaretaker,
                      null => '',
                    },
                  ],
              ],
              flex: const [3, 3, 5, 2],
            ),
          _heading(l10n.reportDaily),
          if (points.isEmpty)
            _text(l10n.alertsNoReadings)
          else
            _table(
              [l10n.reportDate, l10n.reportReadings, 'pH', '°C', 'DO', 'NH3', l10n.reportWorst],
              [
                for (final day in _byDay(points).entries)
                  [
                    DateFormat.MMMEd(l10n.localeName).format(day.key),
                    '${day.value.length}',
                    for (final param in _Param.values)
                      (day.value.map((point) => _value(param, point)).reduce((a, b) => a + b) / day.value.length)
                          .toStringAsFixed(param == _Param.ammonia ? 3 : 1),
                    statusShortLabel(l10n, worstOf(day.value.map(_overall).toList())),
                  ],
              ],
            ),
        ],
      ),
    );
    return doc.save();
  }

  static Map<DateTime, List<SensorHistoryPoint>> _byDay(List<SensorHistoryPoint> points) {
    final days = <DateTime, List<SensorHistoryPoint>>{};
    for (final point in points) {
      days.putIfAbsent(DateUtils.dateOnly(point.time), () => []).add(point);
    }
    return days;
  }

  /// Helvetica only has Latin-1 glyphs: map common typographic characters
  /// (including the narrow space some locales put before AM/PM) to plain
  /// ones, and anything else it can't draw, like emoji in a note, to "?".
  static String _safe(String text) {
    const replacements = {
      '–': '-', '—': '-', '‘': "'", '’': "'", '“': '"', '”': '"',
      '…': '...', ' ': ' ', ' ': ' ', ' ': ' ', '₃': '3',
    };
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(replacements[char] ?? (rune <= 0xFF ? char : '?'));
    }
    return buffer.toString();
  }

  static pw.Widget _text(String text, {pw.TextStyle? style}) => pw.Text(_safe(text), style: style);

  static pw.Widget _heading(String text) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
    child: _text(text, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
  );

  static pw.Widget _table(List<String> headers, List<List<String>> rows, {List<int>? flex}) {
    return pw.TableHelper.fromTextArray(
      headers: headers.map(_safe).toList(),
      data: [for (final row in rows) row.map(_safe).toList()],
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF6A242)),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      columnWidths: flex == null ? null : {for (var i = 0; i < flex.length; i++) i: pw.FlexColumnWidth(flex[i].toDouble())},
    );
  }
}
