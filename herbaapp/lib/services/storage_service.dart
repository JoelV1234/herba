import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/controller_device.dart';
import '../models/schedule_entry.dart';

class StorageService {
  static const _keyDevice = 'device';
  static const _keySchedules = 'schedules';
  static const _keyDemoMode = 'demo_mode';
  static const _keyOnboarded = 'onboarded';
  static const _keyThemeMode = 'theme_mode';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<ControllerDevice?> loadDevice() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keyDevice);
    if (raw == null) return null;
    return ControllerDevice.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveDevice(ControllerDevice device) async {
    final prefs = await _prefs;
    await prefs.setString(_keyDevice, jsonEncode(device.toJson()));
  }

  Future<void> clearDevice() async {
    final prefs = await _prefs;
    await prefs.remove(_keyDevice);
    await prefs.remove(_keyOnboarded);
  }

  Future<List<ScheduleEntry>> loadSchedules() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keySchedules);
    if (raw == null) return _defaultSchedules();
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => ScheduleEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSchedules(List<ScheduleEntry> schedules) async {
    final prefs = await _prefs;
    await prefs.setString(
      _keySchedules,
      jsonEncode(schedules.map((s) => s.toJson()).toList()),
    );
  }

  Future<bool> isDemoMode() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyDemoMode) ?? false;
  }

  Future<void> setDemoMode(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyDemoMode, value);
  }

  Future<bool> isOnboarded() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  Future<void> markOnboarded() async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboarded, true);
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keyThemeMode);
    return ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    await prefs.setString(_keyThemeMode, mode.name);
  }

  List<ScheduleEntry> _defaultSchedules() => const [];
}
