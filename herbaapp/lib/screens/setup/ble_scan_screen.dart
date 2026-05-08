import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../../services/ble_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/eco_card.dart';
import '../../widgets/leaf_background.dart';
import 'wifi_provision_screen.dart';

class BleScanScreen extends StatefulWidget {
  const BleScanScreen({super.key});

  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  final _ble = BleService();
  StreamSubscription<List<BleScanResult>>? _scanSub;
  List<BleScanResult> _results = const [];
  bool _scanning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _error = null;
      _results = const [];
    });
    try {
      final granted = await _ble.ensurePermissions();
      if (!granted) {
        setState(() {
          _error = 'Bluetooth and location permissions are required.';
          _scanning = false;
        });
        return;
      }
      if (!await _ble.isAvailable()) {
        setState(() {
          _error = 'Please turn on Bluetooth to find your controller.';
          _scanning = false;
        });
        return;
      }
      _scanSub = _ble
          .scanForControllers(timeout: const Duration(seconds: 12))
          .listen(
        (results) => setState(() => _results = results),
        onDone: () => setState(() => _scanning = false),
        onError: (Object e) => setState(() {
          _error = e.toString();
          _scanning = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _scanning = false;
      });
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _ble.stopScan();
      await _ble.connect(device);
      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WifiProvisionScreen(ble: _ble, device: device),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not connect: $e')),
      );
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _ble.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Find your controller')),
      body: LeafBackground(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EcoCard(
                  gradient: AppColors.ecoGradient,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(Icons.bluetooth_searching_rounded,
                          color: Colors.white, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _scanning
                                  ? 'Searching nearby…'
                                  : 'Scan complete',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Power on your controller and keep it within a few meters.',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  EcoCard(
                    color: AppColors.ember.withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.ember),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_error!)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: _results.isEmpty
                      ? _EmptyHint(scanning: _scanning)
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final r = _results[i];
                            return EcoCard(
                              onTap: () => _connect(r.device),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.mint,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.spa_rounded,
                                        color: AppColors.forest),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.device.advName.isEmpty
                                              ? 'Herba controller'
                                              : r.device.advName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          r.device.remoteId.str,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                  color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _SignalIcon(rssi: r.rssi),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _scanning ? null : _startScan,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(_scanning ? 'Scanning…' : 'Scan again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final bool scanning;
  const _EmptyHint({required this.scanning});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (scanning)
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          else
            const Icon(Icons.bluetooth_disabled_rounded,
                size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            scanning ? 'Looking for nearby controllers…' : 'No controllers found yet',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Make sure the controller LED is pulsing blue.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SignalIcon extends StatelessWidget {
  final int rssi;
  const _SignalIcon({required this.rssi});

  @override
  Widget build(BuildContext context) {
    int bars;
    if (rssi >= -60) {
      bars = 4;
    } else if (rssi >= -70) {
      bars = 3;
    } else if (rssi >= -80) {
      bars = 2;
    } else {
      bars = 1;
    }
    final color = bars >= 3 ? AppColors.leaf : AppColors.sun;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        return Container(
          width: 4,
          height: 6.0 + i * 4,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: i < bars ? color : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
