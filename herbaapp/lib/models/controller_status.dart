import 'package:flutter/foundation.dart';

enum HeaterState { off, heating, idle, fault }

extension HeaterStateLabel on HeaterState {
  String get label {
    switch (this) {
      case HeaterState.off:
        return 'Off';
      case HeaterState.heating:
        return 'Heating';
      case HeaterState.idle:
        return 'Idle';
      case HeaterState.fault:
        return 'Fault';
    }
  }
}

@immutable
class ControllerStatus {
  final bool online;
  final double currentTemperatureC;
  final double targetTemperatureC;
  final HeaterState heaterState;
  final bool heaterEnabled;
  final double instantPowerW;
  final String? faultMessage;
  final DateTime lastUpdated;

  const ControllerStatus({
    required this.online,
    required this.currentTemperatureC,
    required this.targetTemperatureC,
    required this.heaterState,
    required this.heaterEnabled,
    required this.instantPowerW,
    required this.lastUpdated,
    this.faultMessage,
  });

  factory ControllerStatus.offline() => ControllerStatus(
        online: false,
        currentTemperatureC: 0,
        targetTemperatureC: 18,
        heaterState: HeaterState.off,
        heaterEnabled: false,
        instantPowerW: 0,
        lastUpdated: DateTime.now(),
      );

  factory ControllerStatus.fromJson(Map<String, dynamic> json) {
    return ControllerStatus(
      online: json['online'] as bool? ?? true,
      currentTemperatureC: (json['temperature'] as num).toDouble(),
      targetTemperatureC: (json['target'] as num).toDouble(),
      heaterState: HeaterState.values.firstWhere(
        (e) => e.name == json['heater_state'],
        orElse: () => HeaterState.off,
      ),
      heaterEnabled: json['heater_enabled'] as bool? ?? false,
      instantPowerW: (json['power_w'] as num?)?.toDouble() ?? 0,
      faultMessage: json['fault'] as String?,
      lastUpdated: DateTime.now(),
    );
  }

  ControllerStatus copyWith({
    bool? online,
    double? currentTemperatureC,
    double? targetTemperatureC,
    HeaterState? heaterState,
    bool? heaterEnabled,
    double? instantPowerW,
    String? faultMessage,
    DateTime? lastUpdated,
  }) {
    return ControllerStatus(
      online: online ?? this.online,
      currentTemperatureC: currentTemperatureC ?? this.currentTemperatureC,
      targetTemperatureC: targetTemperatureC ?? this.targetTemperatureC,
      heaterState: heaterState ?? this.heaterState,
      heaterEnabled: heaterEnabled ?? this.heaterEnabled,
      instantPowerW: instantPowerW ?? this.instantPowerW,
      faultMessage: faultMessage ?? this.faultMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
