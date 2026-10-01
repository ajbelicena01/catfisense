import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../services/audit_service.dart';
import '../../services/threshold_controller.dart';
import '../../theme/app_theme.dart';
import '../../utils/thresholds.dart';
import 'admin_widgets.dart';

enum _Bound { healthyMin, healthyMax, warningMin, warningMax }

/// One parameter on the form: which bounds it has (DO has no maximum,
/// ammonia no minimum).
class _ParamSpec {
  const _ParamSpec(this.key, this.bounds, this.unit);

  final String key;
  final List<_Bound> bounds;
  final String unit;
}

const _specs = [
  _ParamSpec('ph', [_Bound.healthyMin, _Bound.healthyMax, _Bound.warningMin, _Bound.warningMax], ''),
  _ParamSpec('temperature', [_Bound.healthyMin, _Bound.healthyMax, _Bound.warningMin, _Bound.warningMax], '°C'),
  _ParamSpec('dissolvedOxygen', [_Bound.healthyMin, _Bound.warningMin], 'mg/L'),
  _ParamSpec('ammonia', [_Bound.healthyMax, _Bound.warningMax], 'mg/L'),
];

ParamRange _rangeOf(Thresholds t, String key) => switch (key) {
  'ph' => t.ph,
  'temperature' => t.temperature,
  'dissolvedOxygen' => t.dissolvedOxygen,
  _ => t.ammonia,
};

double? _boundOf(ParamRange range, _Bound bound) => switch (bound) {
  _Bound.healthyMin => range.healthyMin,
  _Bound.healthyMax => range.healthyMax,
  _Bound.warningMin => range.warningMin,
  _Bound.warningMax => range.warningMax,
};

String _number(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

/// "good 6.5-8.5, warning 6-9" in plain ASCII for the audit log.
String _describe(ParamRange r) {
  String band(double? low, double? high) => switch ((low, high)) {
    (final l?, final h?) => '${_number(l)}-${_number(h)}',
    (final l?, null) => '>=${_number(l)}',
    (null, final h?) => '<=${_number(h)}',
    _ => '-',
  };
  return 'good ${band(r.healthyMin, r.healthyMax)}, warning ${band(r.warningMin, r.warningMax)}';
}

class AdminThresholdsTab extends StatefulWidget {
  const AdminThresholdsTab({super.key});

  @override
  State<AdminThresholdsTab> createState() => _AdminThresholdsTabState();
}

class _AdminThresholdsTabState extends State<AdminThresholdsTab> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = {
    for (final spec in _specs)
      for (final bound in spec.bounds) (spec.key, bound): TextEditingController(),
  };
  final _paramErrors = <String, bool>{};
  late ThresholdController _thresholds;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _thresholds = context.read<ThresholdController>()..addListener(_onRemoteChange);
    _load(Thresholds.current);
  }

  @override
  void dispose() {
    _thresholds.removeListener(_onRemoteChange);
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _load(Thresholds t) {
    for (final MapEntry(key: (param, bound), value: controller) in _controllers.entries) {
      final value = _boundOf(_rangeOf(t, param), bound);
      controller.text = value == null ? '' : _number(value);
    }
  }

  /// Another admin saved: refresh the form unless someone is mid-edit here.
  void _onRemoteChange() {
    if (!_dirty && mounted) setState(() => _load(Thresholds.current));
  }

  /// The form as thresholds, or null when a number can't be read.
  Thresholds? _read() {
    ParamRange? range(String key) {
      double? value(_Bound bound) {
        final controller = _controllers[(key, bound)];
        return controller == null ? null : double.tryParse(controller.text.trim().replaceAll(',', '.'));
      }

      final spec = _specs.firstWhere((s) => s.key == key);
      if (spec.bounds.any((bound) => value(bound) == null)) return null;
      return ParamRange(
        healthyMin: value(_Bound.healthyMin),
        healthyMax: value(_Bound.healthyMax),
        warningMin: value(_Bound.warningMin),
        warningMax: value(_Bound.warningMax),
      );
    }

    final ph = range('ph'), temperature = range('temperature');
    final oxygen = range('dissolvedOxygen'), ammonia = range('ammonia');
    if (ph == null || temperature == null || oxygen == null || ammonia == null) return null;
    return Thresholds(ph: ph, temperature: temperature, dissolvedOxygen: oxygen, ammonia: ammonia);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (!_formKey.currentState!.validate()) return;
    final next = _read()!;
    setState(() {
      for (final spec in _specs) {
        _paramErrors[spec.key] = !_rangeOf(next, spec.key).isValid;
      }
    });
    if (!next.isValid) return;

    final before = Thresholds.current;
    final changes = [
      for (final spec in _specs)
        if (_rangeOf(before, spec.key) != _rangeOf(next, spec.key))
          '${_paramName(l10n, spec.key)}: ${_describe(_rangeOf(before, spec.key))} -> ${_describe(_rangeOf(next, spec.key))}',
    ];
    if (changes.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.thresholdsNoChanges)));
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.thresholdsConfirmTitle),
        content: Text('${changes.join('\n\n')}\n\n${l10n.thresholdsConfirmBody}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.thresholdsSave)),
        ],
      ),
    );
    if (confirmed != true) return;
    await _commit(next, AuditAction.thresholdsChanged, changes.join('; '));
  }

  Future<void> _reset() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.thresholdsResetTitle),
        content: Text(l10n.thresholdsResetBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.commonCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.thresholdsReset)),
        ],
      ),
    );
    if (confirmed != true) return;
    await _commit(Thresholds.defaults, AuditAction.thresholdsReset, null);
  }

  Future<void> _commit(Thresholds next, AuditAction action, String? details) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final saved = await ThresholdController.save(next);
    if (saved) await const AuditService().log(action, details: details);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (saved) {
        _dirty = false;
        _paramErrors.clear();
        _load(next);
      }
    });
    messenger.showSnackBar(SnackBar(content: Text(saved ? l10n.thresholdsSaved : l10n.thresholdsSaveError)));
  }

  static String _paramName(AppLocalizations l10n, String key) => switch (key) {
    'ph' => 'pH',
    'temperature' => l10n.paramTemperature,
    'dissolvedOxygen' => l10n.paramOxygen,
    _ => l10n.paramAmmonia,
  };

  static String _boundLabel(AppLocalizations l10n, _Bound bound) => switch (bound) {
    _Bound.healthyMin => l10n.thresholdsGoodFrom,
    _Bound.healthyMax => l10n.thresholdsGoodTo,
    _Bound.warningMin => l10n.thresholdsWarningFrom,
    _Bound.warningMax => l10n.thresholdsWarningTo,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = AppPalette.of(context);
    return Form(
      key: _formKey,
      onChanged: () => _dirty = true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AdminSectionLabel(l10n.thresholdsTitle),
          Text(l10n.thresholdsHelp, style: TextStyle(fontSize: 13, height: 1.4, color: palette.textSecondary)),
          for (final spec in _specs) ...[
            const SizedBox(height: 14),
            AdminCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spec.unit.isEmpty ? _paramName(l10n, spec.key) : '${_paramName(l10n, spec.key)} (${spec.unit})',
                    style: TextStyle(fontWeight: FontWeight.w800, color: palette.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      for (final bound in spec.bounds)
                        SizedBox(
                          width: 140,
                          child: TextFormField(
                            controller: _controllers[(spec.key, bound)],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: _boundLabel(l10n, bound), isDense: true),
                            validator: (value) =>
                                double.tryParse((value ?? '').trim().replaceAll(',', '.')) == null
                                ? l10n.thresholdsNumberError
                                : null,
                          ),
                        ),
                    ],
                  ),
                  if (_paramErrors[spec.key] == true) ...[
                    const SizedBox(height: 8),
                    Text(l10n.thresholdsOrderError, style: const TextStyle(fontSize: 12, color: adminOfflineColor)),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primaryFill,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(l10n.thresholdsSave, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _saving ? null : _reset, child: Text(l10n.thresholdsReset)),
          const SizedBox(height: 4),
          Text(l10n.thresholdsDeviceNote, style: TextStyle(fontSize: 11, color: palette.textSecondary)),
        ],
      ),
    );
  }
}
