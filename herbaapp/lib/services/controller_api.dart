import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/controller_status.dart';
import '../models/energy_record.dart';
import '../models/schedule_entry.dart';

/// Talks to the Herba controller (ESP32) over its local HTTP API once it's
/// joined the user's WiFi network. Endpoints:
///
///   `GET  /status`            -> ControllerStatus json
///   `POST /target`            `{ "value": 21.5 }`
///   `POST /heater/enabled`    `{ "value": true|false }`
///   `GET  /schedules`         -> `List<ScheduleEntry>`
///   `PUT  /schedules`         body: `List<ScheduleEntry>`
///   `GET  /energy?days=7`     -> `List<EnergyRecord>`
class ControllerApi {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  ControllerApi({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 4),
  }) : _client = client ?? http.Client();

  Uri _u(String path, [Map<String, dynamic>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query?.map(
            (k, v) => MapEntry(k, v.toString()),
          ));

  Future<ControllerStatus> fetchStatus() async {
    final res = await _client.get(_u('/status')).timeout(timeout);
    _ensureOk(res);
    return ControllerStatus.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<void> setTargetTemperature(double celsius) async {
    final res = await _client
        .post(
          _u('/target'),
          headers: const {'content-type': 'application/json'},
          body: jsonEncode({'value': celsius}),
        )
        .timeout(timeout);
    _ensureOk(res);
  }

  Future<void> setHeaterEnabled(bool enabled) async {
    final res = await _client
        .post(
          _u('/heater/enabled'),
          headers: const {'content-type': 'application/json'},
          body: jsonEncode({'value': enabled}),
        )
        .timeout(timeout);
    _ensureOk(res);
  }

  Future<List<ScheduleEntry>> fetchSchedules() async {
    final res = await _client.get(_u('/schedules')).timeout(timeout);
    _ensureOk(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => ScheduleEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> putSchedules(List<ScheduleEntry> schedules) async {
    final res = await _client
        .put(
          _u('/schedules'),
          headers: const {'content-type': 'application/json'},
          body: jsonEncode(schedules.map((s) => s.toJson()).toList()),
        )
        .timeout(timeout);
    _ensureOk(res);
  }

  Future<List<EnergyRecord>> fetchEnergyHistory({int days = 7}) async {
    final res = await _client
        .get(_u('/energy', {'days': days}))
        .timeout(timeout);
    _ensureOk(res);
    final list = jsonDecode(res.body) as List;
    return list
        .map((e) => EnergyRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw HttpException('Controller responded ${res.statusCode}');
    }
  }

  void dispose() => _client.close();
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  @override
  String toString() => message;
}
