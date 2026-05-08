import 'package:flutter/foundation.dart';

@immutable
class EnergyRecord {
  final DateTime timestamp;
  final double kilowattHours;
  final Duration runtime;

  const EnergyRecord({
    required this.timestamp,
    required this.kilowattHours,
    required this.runtime,
  });

  factory EnergyRecord.fromJson(Map<String, dynamic> json) {
    return EnergyRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      kilowattHours: (json['kwh'] as num).toDouble(),
      runtime: Duration(seconds: (json['runtime_s'] as num).toInt()),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'kwh': kilowattHours,
        'runtime_s': runtime.inSeconds,
      };
}
