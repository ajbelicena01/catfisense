import 'package:catfisense/utils/pond_status.dart';
import 'package:catfisense/utils/thresholds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => Thresholds.current = Thresholds.defaults);

  test('defaults match the original fixed ranges', () {
    expect(phStatus(7), PondStatus.healthy);
    expect(phStatus(6.2), PondStatus.warning);
    expect(phStatus(5.5), PondStatus.critical);
    expect(temperatureStatus(31), PondStatus.warning);
    expect(dissolvedOxygenStatus(4), PondStatus.warning);
    expect(dissolvedOxygenStatus(2), PondStatus.critical);
    expect(ammoniaStatus(0.03), PondStatus.warning);
    expect(ammoniaStatus(0.1), PondStatus.critical);
  });

  test('saved ranges change how readings are judged', () {
    final saved = Thresholds.defaults.toMap()..['dissolvedOxygen'] = {'healthyMin': 6.0, 'warningMin': 4.0};
    Thresholds.current = Thresholds.fromMap(saved);
    expect(dissolvedOxygenStatus(5.5), PondStatus.warning);
    expect(dissolvedOxygenStatus(3.5), PondStatus.critical);
    expect(phStatus(7), PondStatus.healthy);
  });

  test('missing or out-of-order parameters fall back to defaults', () {
    final bad = Thresholds.fromMap({
      'ph': {'healthyMin': 8.0, 'healthyMax': 7.0, 'warningMin': 6.0, 'warningMax': 9.0},
    });
    expect(bad, Thresholds.defaults);
    expect(Thresholds.fromMap(null), Thresholds.defaults);
  });

  test('a round trip through the database map keeps every value', () {
    expect(Thresholds.fromMap(Thresholds.defaults.toMap()), Thresholds.defaults);
  });

  test('range text', () {
    expect(healthyRangeText(Thresholds.defaults.ph, unit: 'pH'), '6.5–8.5 pH');
    expect(healthyRangeText(Thresholds.defaults.dissolvedOxygen, unit: 'mg/L'), '≥ 5 mg/L');
    expect(healthyRangeText(Thresholds.defaults.ammonia, unit: 'mg/L', ascii: true), '<= 0.02 mg/L');
  });
}
