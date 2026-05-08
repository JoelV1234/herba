import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../../models/controller_device.dart';
import '../../models/wifi_network.dart';
import '../../services/ble_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/eco_card.dart';
import '../../widgets/leaf_background.dart';
import 'setup_complete_screen.dart';

class WifiProvisionScreen extends StatefulWidget {
  final BleService ble;
  final BluetoothDevice device;

  const WifiProvisionScreen({
    super.key,
    required this.ble,
    required this.device,
  });

  @override
  State<WifiProvisionScreen> createState() => _WifiProvisionScreenState();
}

class _WifiProvisionScreenState extends State<WifiProvisionScreen> {
  final _passwordController = TextEditingController();
  List<WifiNetwork> _networks = const [];
  WifiNetwork? _selected;
  bool _loading = true;
  bool _provisioning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNetworks();
  }

  Future<void> _loadNetworks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.ble.scanWifiNetworks();
      list.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
      setState(() {
        _networks = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    final ssid = _selected?.ssid;
    if (ssid == null) return;
    setState(() {
      _provisioning = true;
      _error = null;
    });
    try {
      final ip = await widget.ble.provisionWifi(
        ssid: ssid,
        password: _passwordController.text,
      );
      await widget.ble.disconnect();
      if (!mounted) return;
      final device = ControllerDevice(
        id: widget.device.remoteId.str,
        name: widget.device.advName.isEmpty
            ? 'Herba controller'
            : widget.device.advName,
        bleId: widget.device.remoteId.str,
        localIp: ip,
      );
      await context.read<AppState>().completeSetup(device);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SetupCompleteScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _provisioning = false;
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to WiFi')),
      body: LeafBackground(
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose a network',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  "Pick the WiFi network you'd like the controller to use.",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _networks.isEmpty
                          ? Center(
                              child: Text(
                                'No networks found. Move closer to your router and retry.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _networks.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, i) {
                                final n = _networks[i];
                                final isSelected = n.ssid == _selected?.ssid;
                                return EcoCard(
                                  color: isSelected
                                      ? AppColors.mint
                                      : AppColors.surface,
                                  onTap: () =>
                                      setState(() => _selected = n),
                                  child: Row(
                                    children: [
                                      Icon(
                                        n.secured
                                            ? Icons.wifi_lock_rounded
                                            : Icons.wifi_rounded,
                                        color: isSelected
                                            ? AppColors.forest
                                            : AppColors.textPrimary,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          n.ssid,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(Icons.check_circle_rounded,
                                            color: AppColors.forest),
                                    ],
                                  ),
                                );
                              },
                            ),
                ),
                if (_selected != null && _selected!.secured) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password for ${_selected!.ssid}',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style:
                        theme.textTheme.bodyMedium?.copyWith(color: AppColors.ember),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selected == null || _provisioning ? null : _submit,
                  child: _provisioning
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Connect controller'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _loading || _provisioning ? null : _loadNetworks,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Rescan networks'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
