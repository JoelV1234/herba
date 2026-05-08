import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/controller_status.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/eco_card.dart';
import '../../widgets/leaf_background.dart';
import '../../widgets/status_dot.dart';
import 'widgets/temperature_dial.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LeafBackground(
      child: SafeArea(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            final s = state.status;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: _Header(state: state),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TemperatureDial(
                      currentC: s.currentTemperatureC,
                      targetC: s.targetTemperatureC,
                      heaterState: s.heaterState,
                      onTargetChanged: state.online
                          ? (v) => state.setTargetTemperature(v)
                          : null,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: _HeaterControlsCard(state: state),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _StatusCard(state: state),
                  ),
                ),
                if (s.faultMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _FaultCard(message: s.faultMessage!),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: _NextScheduleCard(state: state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

extension _OnlineExt on AppState {
  bool get online => status.online;
}

class _Header extends StatelessWidget {
  final AppState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _greetingForNow();
    final controllerName =
        state.demoMode ? 'Demo greenhouse' : (state.device?.name ?? 'Greenhouse');
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                controllerName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.forest,
                ),
              ),
            ],
          ),
        ),
        _ConnectionPill(online: state.status.online, demoMode: state.demoMode),
      ],
    );
  }

  String _greetingForNow() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Good night';
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

class _ConnectionPill extends StatelessWidget {
  final bool online;
  final bool demoMode;
  const _ConnectionPill({required this.online, required this.demoMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = online ? AppColors.leaf : AppColors.ember;
    final label = demoMode
        ? 'Demo mode'
        : online
            ? 'Online'
            : 'Offline';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusDot(color: color, pulsing: online, size: 8),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaterControlsCard extends StatelessWidget {
  final AppState state;
  const _HeaterControlsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = state.status;
    final running = s.heaterState == HeaterState.heating;
    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: running
                      ? AppColors.warmGradient
                      : const LinearGradient(colors: [
                          AppColors.surfaceMuted,
                          AppColors.surfaceMuted,
                        ]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: running ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Heater',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      _heaterStatusText(s),
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: s.heaterEnabled,
                onChanged: state.online
                    ? (v) => state.setHeaterEnabled(v)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniStat(
                icon: Icons.flash_on_rounded,
                label: 'Power',
                value: '${s.instantPowerW.round()} W',
              ),
              const SizedBox(width: 12),
              _MiniStat(
                icon: Icons.thermostat_rounded,
                label: 'Target',
                value: '${s.targetTemperatureC.toStringAsFixed(1)}°C',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _heaterStatusText(ControllerStatus s) {
    if (!s.heaterEnabled) return 'Switched off — heater will not run';
    switch (s.heaterState) {
      case HeaterState.heating:
        return 'Heating now to reach target';
      case HeaterState.idle:
        return 'Idle — target temperature reached';
      case HeaterState.off:
        return 'Off';
      case HeaterState.fault:
        return 'Fault detected — see below';
    }
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(label,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final AppState state;
  const _StatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = state.status;
    final lastSeen = s.online
        ? 'Live now'
        : 'Last seen ${DateFormat.jm().format(s.lastUpdated)}';
    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Controller',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _StatusRow(
            icon: Icons.signal_wifi_4_bar_rounded,
            label: 'Connection',
            valueWidget: Row(
              children: [
                StatusDot(
                  color: s.online ? AppColors.leaf : AppColors.ember,
                  pulsing: s.online,
                ),
                const SizedBox(width: 8),
                Text(s.online ? 'Connected' : 'Unreachable'),
              ],
            ),
          ),
          const Divider(height: 24),
          _StatusRow(
            icon: Icons.history_rounded,
            label: 'Update',
            valueWidget: Text(lastSeen),
          ),
          if (state.lastError != null) ...[
            const Divider(height: 24),
            _StatusRow(
              icon: Icons.warning_amber_rounded,
              label: 'Last error',
              valueWidget: Expanded(
                child: Text(
                  state.lastError!,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.ember),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget valueWidget;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary)),
        const Spacer(),
        valueWidget,
      ],
    );
  }
}

class _FaultCard extends StatelessWidget {
  final String message;
  const _FaultCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EcoCard(
      color: AppColors.ember.withValues(alpha: 0.08),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.ember),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Heater stopped',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700, color: AppColors.ember)),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextScheduleCard extends StatelessWidget {
  final AppState state;
  const _NextScheduleCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = _findNextActive(state);
    return EcoCard(
      gradient: AppColors.coolGradient,
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: AppColors.forest, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  next == null ? 'No active schedule' : 'Next schedule',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  next == null
                      ? 'Add one in Schedule to automate heating'
                      : '${next.label} · ${_formatTime(next.startTime)} – ${_formatTime(next.endTime)} · ${next.targetTemperatureC.toStringAsFixed(1)}°C',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.bark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  dynamic _findNextActive(AppState state) {
    if (state.schedules.isEmpty) return null;
    for (final s in state.schedules) {
      if (s.enabled) return s;
    }
    return null;
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
