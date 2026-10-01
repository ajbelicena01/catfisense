import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../services/admin_service.dart';
import '../../services/sensor_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/device_health.dart';
import '../../utils/time_format.dart';
import 'admin_widgets.dart';

/// The gateway app checks in every minute; allow for one missed beat.
const _gatewayOfflineAfter = Duration(minutes: 3);

class AdminHealthTab extends StatefulWidget {
  const AdminHealthTab({super.key});

  @override
  State<AdminHealthTab> createState() => _AdminHealthTabState();
}

class _AdminHealthTabState extends State<AdminHealthTab> {
  static const _admin = AdminService();
  late final Stream<List<PondSummary>> _ponds = _admin.ponds();

  /// The pond (= device) being looked at.
  String _deviceId = SensorRepository.defaultDeviceId;
  late Stream<List<UploadSample>> _uploads;
  late Stream<DateTime?> _gatewaySeen;
  late Stream<SmsQueueEntry?> _lastSms;

  void _watch(String deviceId) {
    _deviceId = deviceId;
    _uploads = _admin.uploads(deviceId: deviceId, since: DateTime.now().subtract(const Duration(hours: 24)));
    _gatewaySeen = _admin.gatewayLastSeen(deviceId);
    _lastSms = _admin.lastSms(deviceId);
  }

  // Keeps "online" and "3 min ago" honest while nothing new arrives.
  Timer? _clock;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _watch(_deviceId);
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<List<UploadSample>>(
      stream: _uploads,
      builder: (context, snapshot) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _PondPicker(
              ponds: _ponds,
              selected: _deviceId,
              onChanged: (id) => setState(() => _watch(id)),
            ),
            AdminSectionLabel(l10n.healthDevice(_deviceId)),
            if (snapshot.hasError)
              AdminMessage(icon: Icons.cloud_off, text: l10n.loadError)
            else if (!snapshot.hasData)
              const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
            else
              ..._deviceSections(context, computeDeviceHealth(snapshot.data!, _now)),
            AdminSectionLabel(l10n.healthGateway),
            _GatewayCard(seen: _gatewaySeen, lastSms: _lastSms, now: _now),
            if (_deviceId != SensorRepository.defaultDeviceId)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  l10n.healthGatewayPond1Only,
                  style: TextStyle(fontSize: 12, color: AppPalette.of(context).textSecondary),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _deviceSections(BuildContext context, DeviceHealth health) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    String delay(Duration? value) => value == null ? '-' : delayLabel(value);

    return [
      AdminCard(
        child: Row(
          children: [
            StatusPill(
              text: health.online ? l10n.healthOnline : l10n.healthOffline,
              color: health.online ? adminOnlineColor : adminOfflineColor,
              icon: health.online ? Icons.sensors : Icons.sensors_off,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                health.lastSeen == null
                    ? l10n.healthNoReadings24h
                    : l10n.healthLastReading(timeAgo(l10n, health.lastSeen!, _now)),
                style: TextStyle(fontSize: 13, color: palette.textPrimary),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.healthUploadSpeed, style: TextStyle(fontWeight: FontWeight.w800, color: palette.textPrimary)),
            const SizedBox(height: 4),
            Text(l10n.healthUploadSpeedHint, style: TextStyle(fontSize: 12, color: palette.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: AdminStat(label: l10n.healthLatest, value: delay(health.latestDelay))),
                Expanded(child: AdminStat(label: l10n.healthAverage, value: delay(health.averageDelay))),
                Expanded(child: AdminStat(label: l10n.healthSlowest, value: delay(health.maxDelay))),
              ],
            ),
            if (health.delaySeries.length > 1) ...[
              const SizedBox(height: 16),
              SizedBox(height: 120, child: _DelayChart(samples: health.delaySeries)),
            ],
            const SizedBox(height: 8),
            Text(l10n.healthClockNote, style: TextStyle(fontSize: 11, color: palette.textSecondary)),
          ],
        ),
      ),
      const SizedBox(height: 10),
      AdminCard(
        child: Row(
          children: [
            Expanded(
              child: AdminStat(
                label: l10n.healthLast10Min,
                value: l10n.healthOfExpected(health.readingsLast10Minutes, DeviceHealth.expectedPer10Minutes),
              ),
            ),
            Expanded(
              child: AdminStat(
                label: l10n.batteryLabel,
                value: health.batteryPercent == null ? '-' : '${health.batteryPercent}%',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      AdminCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.healthGaps, style: TextStyle(fontWeight: FontWeight.w800, color: palette.textPrimary)),
            const SizedBox(height: 8),
            if (health.gaps.isEmpty)
              Text(l10n.healthNoGaps, style: TextStyle(fontSize: 13, color: palette.textSecondary))
            else
              for (final gap in health.gaps.take(6))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${dateTimeLabel(l10n, gap.from)} → '
                    '${gap.to == _now ? l10n.healthNow : dateTimeLabel(l10n, gap.to)}  '
                    '(${durationLabel(l10n, gap.length)})',
                    style: TextStyle(fontSize: 13, color: palette.textPrimary),
                  ),
                ),
          ],
        ),
      ),
    ];
  }
}

class _DelayChart extends StatelessWidget {
  const _DelayChart({required this.samples});

  final List<UploadSample> samples;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final seconds = [for (final s in samples) s.delay.inMilliseconds / 1000];
    final top = seconds.reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: top <= 0 ? 1 : top * 1.2,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) =>
                  Text('${value.toStringAsFixed(1)}s', style: TextStyle(fontSize: 9, color: palette.textSecondary)),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < seconds.length; i++) FlSpot(i.toDouble(), seconds[i] < 0 ? 0 : seconds[i])],
            color: palette.primary,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _GatewayCard extends StatelessWidget {
  const _GatewayCard({required this.seen, required this.lastSms, required this.now});

  final Stream<DateTime?> seen;
  final Stream<SmsQueueEntry?> lastSms;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<DateTime?>(
            stream: seen,
            builder: (context, snapshot) {
              final lastSeen = snapshot.data;
              final online = lastSeen != null && now.difference(lastSeen) <= _gatewayOfflineAfter;
              return Row(
                children: [
                  StatusPill(
                    text: !snapshot.hasData && !snapshot.hasError
                        ? l10n.commonChecking
                        : online
                        ? l10n.healthOnline
                        : l10n.healthOffline,
                    color: online ? adminOnlineColor : (lastSeen == null ? adminUnknownColor : adminOfflineColor),
                    icon: Icons.phone_android,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      lastSeen == null ? l10n.healthGatewayNever : l10n.healthGatewaySeen(timeAgo(l10n, lastSeen, now)),
                      style: TextStyle(fontSize: 13, color: palette.textPrimary),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<SmsQueueEntry?>(
            stream: lastSms,
            builder: (context, snapshot) {
              final sms = snapshot.data;
              final text = sms == null
                  ? l10n.healthNoSms
                  : l10n.healthLastSms(
                      _smsStatus(l10n, sms.status),
                      sms.createdAt == null ? '-' : timeAgo(l10n, sms.createdAt!, now),
                    );
              return Text(text, style: TextStyle(fontSize: 13, color: palette.textSecondary));
            },
          ),
        ],
      ),
    );
  }

  static String _smsStatus(AppLocalizations l10n, String status) => switch (status) {
    'sent' => l10n.smsStatusSent,
    'failed' => l10n.smsStatusFailed,
    'rejected' => l10n.smsStatusRejected,
    'expired' => l10n.smsStatusExpired,
    'pending' || 'sending' => l10n.smsStatusPending,
    _ => status,
  };
}

/// Chooses which pond's device the tab shows; hidden while there is only one.
class _PondPicker extends StatelessWidget {
  const _PondPicker({required this.ponds, required this.selected, required this.onChanged});

  final Stream<List<PondSummary>> ponds;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<List<PondSummary>>(
      stream: ponds,
      builder: (context, snapshot) {
        final list = snapshot.data ?? const <PondSummary>[];
        if (list.length < 2) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: DropdownButtonFormField<String>(
            initialValue: list.any((pond) => pond.id == selected) ? selected : null,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.adminPondPicker, border: const OutlineInputBorder()),
            items: [
              for (final pond in list)
                DropdownMenuItem(value: pond.id, child: Text(pond.name, overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (id) {
              if (id != null && id != selected) onChanged(id);
            },
          ),
        );
      },
    );
  }
}
