import 'package:flutter/foundation.dart';

@immutable
class WifiNetwork {
  final String ssid;
  final int signalStrength;
  final bool secured;

  const WifiNetwork({
    required this.ssid,
    required this.signalStrength,
    required this.secured,
  });

  factory WifiNetwork.fromJson(Map<String, dynamic> json) {
    return WifiNetwork(
      ssid: json['ssid'] as String,
      signalStrength: (json['rssi'] as num).toInt(),
      secured: json['secured'] as bool? ?? true,
    );
  }
}
