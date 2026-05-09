import 'dart:async';

import 'package:flutter/material.dart';

import '../models/controller_device.dart';
import '../models/controller_status.dart';
import '../models/energy_record.dart';
import '../models/schedule_entry.dart';
import '../services/controller_api.dart';
import '../services/mock_controller.dart';
import '../services/storage_service.dart';

/// One-stop ChangeNotifier for the live controller state. Owns whichever
/// transport is active (real HTTP vs in-process mock) and exposes a
/// uniform surface for the UI.
class AppState extends ChangeNotifier {
  AppState({StorageService? storage})
      : _storage = storage ?? StorageService();

  final StorageService _storage;

  // Lifecycle
  bool _initialized = false;
  bool get initialized => _initialized;

  // Setup
  bool _onboarded = false;
  bool get onboarded => _onboarded;

  ControllerDevice? _device;
  ControllerDevice? get device => _device;

  // Mode
  bool _demoMode = false;
  bool get demoMode => _demoMode;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  // Live state
  ControllerStatus _status = ControllerStatus.offline();
  ControllerStatus get status => _status;
  String? _lastError;
  String? get lastError => _lastError;

  List<ScheduleEntry> _schedules = [];
  List<ScheduleEntry> get schedules => List.unmodifiable(_schedules);

  List<EnergyRecord> _energy = [];
  List<EnergyRecord> get energy => List.unmodifiable(_energy);

  ControllerApi? _api;
  StreamSubscription<ControllerStatus>? _mockSub;
  Timer? _pollTimer;

  Future<void> bootstrap() async {
    if (_initialized) return;
    _onboarded = await _storage.isOnboarded();
    _device = await _storage.loadDevice();
    _demoMode = await _storage.isDemoMode();
    _themeMode = await _storage.loadThemeMode();
    _schedules = await _storage.loadSchedules();
    if (_onboarded || _demoMode) {
      await _attachTransport();
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _storage.saveThemeMode(mode);
    notifyListeners();
  }

  Future<void> setDemoMode(bool value) async {
    _demoMode = value;
    await _storage.setDemoMode(value);
    await _detachTransport();
    await _attachTransport();
    notifyListeners();
  }

  Future<void> completeSetup(ControllerDevice device) async {
    _device = device.copyWith(pairedAt: DateTime.now());
    await _storage.saveDevice(_device!);
    await _storage.markOnboarded();
    _onboarded = true;
    await _detachTransport();
    await _attachTransport();
    notifyListeners();
  }

  Future<void> resetController() async {
    await _detachTransport();
    await _storage.clearDevice();
    _device = null;
    _onboarded = false;
    _status = ControllerStatus.offline();
    notifyListeners();
  }

  Future<void> _attachTransport() async {
    if (_demoMode) {
      MockController.instance.setSchedules(_schedules);
      _status = MockController.instance.snapshot();
      _mockSub = MockController.instance.statusStream.listen((s) {
        _status = s;
        notifyListeners();
      });
      _energy = MockController.instance.energyHistory(days: 7);
    } else if (_device?.localIp != null) {
      _api = ControllerApi(baseUrl: 'http://${_device!.localIp}');
      await _refreshNow();
      _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _refreshNow());
    }
  }

  Future<void> _detachTransport() async {
    await _mockSub?.cancel();
    _mockSub = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _api?.dispose();
    _api = null;
  }

  Future<void> _refreshNow() async {
    final api = _api;
    if (api == null) return;
    try {
      final s = await api.fetchStatus();
      _status = s;
      _lastError = null;
      _energy = await api.fetchEnergyHistory(days: 7);
      notifyListeners();
    } catch (e) {
      _status = _status.copyWith(online: false);
      _lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> setTargetTemperature(double celsius) async {
    final clamped = celsius.clamp(5.0, 35.0).toDouble();
    if (_demoMode) {
      MockController.instance.setTarget(clamped);
    } else {
      await _api?.setTargetTemperature(clamped);
      await _refreshNow();
    }
    _status = _status.copyWith(targetTemperatureC: clamped);
    notifyListeners();
  }

  Future<void> setHeaterEnabled(bool enabled) async {
    if (_demoMode) {
      MockController.instance.setHeaterEnabled(enabled);
    } else {
      await _api?.setHeaterEnabled(enabled);
      await _refreshNow();
    }
    _status = _status.copyWith(
      heaterEnabled: enabled,
      heaterState: enabled ? _status.heaterState : HeaterState.off,
    );
    notifyListeners();
  }

  Future<void> upsertSchedule(ScheduleEntry entry) async {
    final next = List<ScheduleEntry>.from(_schedules);
    final i = next.indexWhere((s) => s.id == entry.id);
    if (i == -1) {
      next.add(entry);
    } else {
      next[i] = entry;
    }
    await _persistSchedules(next);
  }

  Future<void> deleteSchedule(String id) async {
    final next = _schedules.where((s) => s.id != id).toList();
    await _persistSchedules(next);
  }

  Future<void> _persistSchedules(List<ScheduleEntry> next) async {
    _schedules = next;
    await _storage.saveSchedules(next);
    if (_demoMode) {
      MockController.instance.setSchedules(next);
    } else {
      try {
        await _api?.putSchedules(next);
      } catch (_) {
        // local-only is fine; schedules will sync next time controller polls
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _detachTransport();
    super.dispose();
  }
}
