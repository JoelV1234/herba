import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/eco_card.dart';
import '../../widgets/leaf_background.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
                    color: scheme.primary,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appearance',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _ThemeModeSelector(
                        value: state.themeMode,
                        onChanged: (m) => state.setThemeMode(m),
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
                        leading: Icon(Icons.refresh_rounded,
                            color: scheme.primary),
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
                        ?.copyWith(color: scheme.onSurfaceVariant),
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
    final scheme = theme.colorScheme;
    return Row(
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant)),
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

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ModeChip(
          icon: Icons.brightness_auto_rounded,
          label: 'System',
          selected: value == ThemeMode.system,
          onTap: () => onChanged(ThemeMode.system),
        ),
        const SizedBox(width: 8),
        _ModeChip(
          icon: Icons.light_mode_rounded,
          label: 'Light',
          selected: value == ThemeMode.light,
          onTap: () => onChanged(ThemeMode.light),
        ),
        const SizedBox(width: 8),
        _ModeChip(
          icon: Icons.dark_mode_rounded,
          label: 'Dark',
          selected: value == ThemeMode.dark,
          onTap: () => onChanged(ThemeMode.dark),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = selected ? scheme.primary : scheme.surfaceContainerHighest;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
