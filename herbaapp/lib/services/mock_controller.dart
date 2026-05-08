import 'dart:async';
import 'dart:math';

import '../models/controller_status.dart';
import '../models/energy_record.dart';
import '../models/schedule_entry.dart';

/// Simulates a Herba controller in-process so the UI is fully usable
/// without real hardware. The thermostat logic mirrors what the ESP32
/// firmware will do: hysteresis-based on/off around the target temp.
class MockController {
  static final MockController instance = MockController._();
  MockController._() {
    _tick();
  }

  final _statusController = StreamController<ControllerStatus>.broadcast();
  Stream<ControllerStatus> get statusStream => _statusController.stream;

  final _rng = Random();
  Timer? _timer;

  bool _online = true;
  bool _heaterEnabled = true;
  double _currentTempC = 14.0;
  final double _outsideTempC = 8.0;
  double _targetTempC = 19.0;
  HeaterState _heaterState = HeaterState.idle;
  static const double _hysteresis = 0.5;
  static const double _heaterPowerW = 1500;
  String? _faultMessage;

  // Rolling logs.
  final List<EnergyRecord> _energyLog = [];
  Duration _todayRuntime = Duration.zero;
  double _todayKwh = 0;
  DateTime _energyDay = DateTime.now();

  List<ScheduleEntry> _schedules = [];

  void _tick() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_online) {
        _emit();
        return;
      }

      // Apply schedule overrides.
      _applySchedule();

      // Hysteresis logic — mirrors firmware.
      if (_heaterEnabled && _faultMessage == null) {
        if (_currentTempC < _targetTempC - _hysteresis) {
          _heaterState = HeaterState.heating;
        } else if (_currentTempC >= _targetTempC + _hysteresis) {
          _heaterState = HeaterState.idle;
        }
      } else {
        _heaterState = _faultMessage != null ? HeaterState.fault : HeaterState.off;
      }

      // Physics-ish update: heater warms, environment cools.
      const double kHeat = 0.025; // °C per second when heating
      const double kCool = 0.008; // °C per second toward outside
      if (_heaterState == HeaterState.heating) {
        _currentTempC += kHeat;
        _todayRuntime += const Duration(seconds: 1);
        _todayKwh += _heaterPowerW / 1000 / 3600; // kWh per second
      }
      _currentTempC -= kCool * (_currentTempC - _outsideTempC) / 10;
      // Tiny noise to feel real.
      _currentTempC += (_rng.nextDouble() - 0.5) * 0.01;

      _rolloverEnergyIfNeeded();
      _emit();
    });
  }

  void _applySchedule() {
    final now = DateTime.now();
    final dow = now.weekday; // 1..7
    final minutes = now.hour * 60 + now.minute;
    for (final s in _schedules) {
      if (!s.enabled || !s.daysOfWeek.contains(dow)) continue;
      final start = s.startTime.hour * 60 + s.startTime.minute;
      final end = s.endTime.hour * 60 + s.endTime.minute;
      final inRange =
          start <= end ? (minutes >= start && minutes < end) : (minutes >= start || minutes < end);
      if (inRange) {
        _targetTempC = s.targetTemperatureC;
        _heaterEnabled = true;
        return;
      }
    }
  }

  void _rolloverEnergyIfNeeded() {
    final now = DateTime.now();
    if (now.day != _energyDay.day || now.month != _energyDay.month) {
      _energyLog.add(EnergyRecord(
        timestamp: DateTime(_energyDay.year, _energyDay.month, _energyDay.day),
        kilowattHours: _todayKwh,
        runtime: _todayRuntime,
      ));
      _todayKwh = 0;
      _todayRuntime = Duration.zero;
      _energyDay = now;
    }
  }

  void _emit() {
    _statusController.add(ControllerStatus(
      online: _online,
      currentTemperatureC: _currentTempC,
      targetTemperatureC: _targetTempC,
      heaterState: _heaterState,
      heaterEnabled: _heaterEnabled,
      instantPowerW: _heaterState == HeaterState.heating ? _heaterPowerW : 0,
      faultMessage: _faultMessage,
      lastUpdated: DateTime.now(),
    ));
  }

  ControllerStatus snapshot() => ControllerStatus(
        online: _online,
        currentTemperatureC: _currentTempC,
        targetTemperatureC: _targetTempC,
        heaterState: _heaterState,
        heaterEnabled: _heaterEnabled,
        instantPowerW: _heaterState == HeaterState.heating ? _heaterPowerW : 0,
        faultMessage: _faultMessage,
        lastUpdated: DateTime.now(),
      );

  void setTarget(double celsius) {
    _targetTempC = celsius;
    _emit();
  }

  void setHeaterEnabled(bool value) {
    _heaterEnabled = value;
    if (!value) _heaterState = HeaterState.off;
    _emit();
  }

  void setOnline(bool value) {
    _online = value;
    _emit();
  }

  void triggerFault(String? message) {
    _faultMessage = message;
    _emit();
  }

  void setSchedules(List<ScheduleEntry> schedules) {
    _schedules = List.of(schedules);
  }

  List<EnergyRecord> energyHistory({int days = 7}) {
    final history = <EnergyRecord>[];
    final today = DateTime.now();
    // Synthesize prior days with believable values.
    for (var i = days - 1; i >= 1; i--) {
      final day = DateTime(today.year, today.month, today.day - i);
      final hours = 4 + _rng.nextDouble() * 6;
      final kwh = hours * (_heaterPowerW / 1000) * (0.5 + _rng.nextDouble() * 0.4);
      history.add(EnergyRecord(
        timestamp: day,
        kilowattHours: kwh,
        runtime: Duration(minutes: (hours * 60).round()),
      ));
    }
    history.add(EnergyRecord(
      timestamp: DateTime(today.year, today.month, today.day),
      kilowattHours: _todayKwh,
      runtime: _todayRuntime,
    ));
    return history;
  }

  void dispose() {
    _timer?.cancel();
    _statusController.close();
  }
}
