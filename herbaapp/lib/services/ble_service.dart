import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/wifi_network.dart';

/// Custom GATT layout exposed by the Herba controller while in pairing mode.
/// The ESP32 advertises with its name starting with "Herba-".
class HerbaBleUuids {
  HerbaBleUuids._();
  static final Guid service = Guid('6e8a0001-c8b4-4f0e-9d27-2a1b6e1f3c10');
  // Read scanned wifi networks (json list).
  static final Guid wifiList = Guid('6e8a0002-c8b4-4f0e-9d27-2a1b6e1f3c10');
  // Write { "ssid": "...", "password": "..." }.
  static final Guid wifiCreds = Guid('6e8a0003-c8b4-4f0e-9d27-2a1b6e1f3c10');
  // Notify provisioning state ("scanning" | "connecting" | "ok" | "error:..").
  static final Guid provisionState = Guid('6e8a0004-c8b4-4f0e-9d27-2a1b6e1f3c10');
  // Read controller info (json: { id, name, ip }).
  static final Guid info = Guid('6e8a0005-c8b4-4f0e-9d27-2a1b6e1f3c10');
}

class BleScanResult {
  final BluetoothDevice device;
  final int rssi;
  BleScanResult(this.device, this.rssi);
}

class BleService {
  StreamSubscription<List<ScanResult>>? _scanSub;
  BluetoothDevice? _connected;

  Future<bool> ensurePermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return statuses.values.every((s) => s.isGranted || s.isLimited);
  }

  Future<bool> isAvailable() async {
    if (await FlutterBluePlus.isSupported == false) return false;
    return FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on;
  }

  Stream<List<BleScanResult>> scanForControllers({
    Duration timeout = const Duration(seconds: 10),
  }) {
    final controller = StreamController<List<BleScanResult>>.broadcast();
    final discovered = <String, BleScanResult>{};

    FlutterBluePlus.startScan(timeout: timeout);

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        final name = r.device.advName;
        if (name.startsWith('Herba-')) {
          discovered[r.device.remoteId.str] = BleScanResult(r.device, r.rssi);
        }
      }
      controller.add(discovered.values.toList());
    });

    Future.delayed(timeout).then((_) async {
      await stopScan();
      if (!controller.isClosed) await controller.close();
    });

    return controller.stream;
  }

  Future<void> stopScan() async {
    await _scanSub?.cancel();
    _scanSub = null;
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    await device.connect(timeout: const Duration(seconds: 10));
    _connected = device;
  }

  Future<List<WifiNetwork>> scanWifiNetworks() async {
    final char = await _findCharacteristic(HerbaBleUuids.wifiList);
    final raw = await char.read();
    final list = jsonDecode(utf8.decode(raw)) as List;
    return list
        .map((e) => WifiNetwork.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sends WiFi creds to the controller and waits for it to acknowledge that
  /// it joined the network. Returns the controller's local IP on success.
  Future<String> provisionWifi({
    required String ssid,
    required String password,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final stateChar = await _findCharacteristic(HerbaBleUuids.provisionState);
    await stateChar.setNotifyValue(true);

    final completer = Completer<String>();
    final sub = stateChar.lastValueStream.listen((bytes) async {
      if (bytes.isEmpty) return;
      final msg = utf8.decode(bytes);
      if (msg == 'ok') {
        final info = await _readInfo();
        if (!completer.isCompleted) completer.complete(info['ip'] as String);
      } else if (msg.startsWith('error:')) {
        if (!completer.isCompleted) {
          completer.completeError(BleException(msg.substring(6)));
        }
      }
    });

    final credsChar = await _findCharacteristic(HerbaBleUuids.wifiCreds);
    await credsChar.write(
      utf8.encode(jsonEncode({'ssid': ssid, 'password': password})),
      withoutResponse: false,
    );

    try {
      return await completer.future.timeout(timeout);
    } finally {
      await sub.cancel();
    }
  }

  Future<Map<String, dynamic>> _readInfo() async {
    final char = await _findCharacteristic(HerbaBleUuids.info);
    final raw = await char.read();
    return jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
  }

  Future<BluetoothCharacteristic> _findCharacteristic(Guid uuid) async {
    final device = _connected;
    if (device == null) {
      throw BleException('Not connected to a controller');
    }
    final services = await device.discoverServices();
    final svc = services.firstWhere(
      (s) => s.uuid == HerbaBleUuids.service,
      orElse: () => throw BleException('Herba service not found'),
    );
    return svc.characteristics.firstWhere(
      (c) => c.uuid == uuid,
      orElse: () => throw BleException('Characteristic $uuid missing'),
    );
  }

  Future<void> disconnect() async {
    await _connected?.disconnect();
    _connected = null;
  }
}

class BleException implements Exception {
  final String message;
  BleException(this.message);
  @override
  String toString() => message;
}
