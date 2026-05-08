import 'package:flutter/foundation.dart';

@immutable
class ControllerDevice {
  final String id;
  final String name;
  final String? localIp;
  final String? bleId;
  final DateTime? pairedAt;

  const ControllerDevice({
    required this.id,
    required this.name,
    this.localIp,
    this.bleId,
    this.pairedAt,
  });

  factory ControllerDevice.fromJson(Map<String, dynamic> json) {
    return ControllerDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      localIp: json['ip'] as String?,
      bleId: json['ble_id'] as String?,
      pairedAt: json['paired_at'] != null
          ? DateTime.parse(json['paired_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (localIp != null) 'ip': localIp,
        if (bleId != null) 'ble_id': bleId,
        if (pairedAt != null) 'paired_at': pairedAt!.toIso8601String(),
      };

  ControllerDevice copyWith({String? localIp, String? bleId, DateTime? pairedAt}) {
    return ControllerDevice(
      id: id,
      name: name,
      localIp: localIp ?? this.localIp,
      bleId: bleId ?? this.bleId,
      pairedAt: pairedAt ?? this.pairedAt,
    );
  }
}
