import 'package:flutter/material.dart';

@immutable
class ScheduleEntry {
  final String id;
  final String label;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Set<int> daysOfWeek;
  final double targetTemperatureC;
  final bool enabled;

  const ScheduleEntry({
    required this.id,
    required this.label,
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
    required this.targetTemperatureC,
    this.enabled = true,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) {
    return ScheduleEntry(
      id: json['id'] as String,
      label: json['label'] as String? ?? 'Schedule',
      startTime: _parseTime(json['start'] as String),
      endTime: _parseTime(json['end'] as String),
      daysOfWeek: (json['days'] as List).map((e) => e as int).toSet(),
      targetTemperatureC: (json['target'] as num).toDouble(),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'start': _formatTime(startTime),
        'end': _formatTime(endTime),
        'days': daysOfWeek.toList()..sort(),
        'target': targetTemperatureC,
        'enabled': enabled,
      };

  ScheduleEntry copyWith({
    String? label,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Set<int>? daysOfWeek,
    double? targetTemperatureC,
    bool? enabled,
  }) {
    return ScheduleEntry(
      id: id,
      label: label ?? this.label,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      targetTemperatureC: targetTemperatureC ?? this.targetTemperatureC,
      enabled: enabled ?? this.enabled,
    );
  }

  String get daysSummary {
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.length == 5 &&
        daysOfWeek.containsAll({1, 2, 3, 4, 5})) {
      return 'Weekdays';
    }
    if (daysOfWeek.length == 2 && daysOfWeek.containsAll({6, 7})) {
      return 'Weekends';
    }
    const names = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = daysOfWeek.toList()..sort();
    return sorted.map((d) => names[d]).join(' · ');
  }
}
