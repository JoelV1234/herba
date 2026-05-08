import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/eco_card.dart';
import '../../widgets/leaf_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LeafBackground(
      child: SafeArea(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  'Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 16),
                EcoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Controller',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _Row(
                        label: 'Name',
                        value: state.demoMode
                            ? 'Demo greenhouse'
                            : (state.device?.name ?? '—'),
                      ),
                      const Divider(height: 24),
                      _Row(
                        label: 'Local IP',
                        value: state.demoMode
                            ? '127.0.0.1 (mock)'
                            : (state.device?.localIp ?? '—'),
                      ),
                      const Divider(height: 24),
                      _Row(
                        label: 'Paired',
                        value: state.demoMode
                            ? 'Demo session'
                            : state.device?.pairedAt != null
                                ? DateFormat.yMMMd()
                                    .add_jm()
                                    .format(state.device!.pairedAt!)
                                : '—',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                EcoCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Demo mode'),
                        subtitle: const Text(
                            'Simulate the controller in-app — no hardware required.'),
                        value: state.demoMode,
                        onChanged: (v) => state.setDemoMode(v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                EcoCard(
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.refresh_rounded,
                            color: AppColors.forest),
                        title: const Text('Re-pair controller'),
                        subtitle: const Text(
                            'Forget this controller and start setup again.'),
                        onTap: () => _confirmReset(context, state),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Herba · v1.0.0',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, AppState state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Re-pair controller?'),
        content: const Text(
            'This forgets the current controller. Your schedules will be kept.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Re-pair')),
        ],
      ),
    );
    if (ok == true) {
      await state.resetController();
      await state.setDemoMode(false);
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
