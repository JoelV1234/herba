import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/leaf_background.dart';
import 'ble_scan_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: LeafBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.ecoGradient,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.eco_rounded,
                      color: Colors.white, size: 48),
                ),
                const Spacer(),
                Text(
                  'Welcome to Herba',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Let's grow together. Pair your Herba controller to keep your greenhouse at the perfect temperature, automatically.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                _Bullet(
                  icon: Icons.bluetooth_rounded,
                  title: 'Pair over Bluetooth',
                  description:
                      "We'll find your controller and connect it to your WiFi.",
                ),
                const SizedBox(height: 16),
                _Bullet(
                  icon: Icons.thermostat_rounded,
                  title: 'Set the climate',
                  description: 'Choose target temperatures and schedules.',
                ),
                const SizedBox(height: 16),
                _Bullet(
                  icon: Icons.bolt_rounded,
                  title: 'Track energy use',
                  description: "Watch your heater's runtime and consumption.",
                ),
                const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BleScanScreen()),
                    );
                  },
                  child: const Text('Pair my controller'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    final state = context.read<AppState>();
                    await state.setDemoMode(true);
                  },
                  child: const Text('Try the demo without hardware'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  const _Bullet({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.mint,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.forest),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(description,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
