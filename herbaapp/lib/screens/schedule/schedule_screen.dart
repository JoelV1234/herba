import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/schedule_entry.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/eco_card.dart';
import '../../widgets/leaf_background.dart';
import 'schedule_editor_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LeafBackground(
      child: SafeArea(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            final schedules = state.schedules;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Schedule',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.forest,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () => _openEditor(context, null),
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.forest,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Automate when the heater wakes up and shuts down.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: schedules.isEmpty
                        ? _Empty(onAdd: () => _openEditor(context, null))
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: schedules.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final entry = schedules[i];
                              return _ScheduleCard(
                                entry: entry,
                                onTap: () => _openEditor(context, entry),
                                onToggle: (v) => state.upsertSchedule(
                                    entry.copyWith(enabled: v)),
                                onDelete: () =>
                                    state.deleteSchedule(entry.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, ScheduleEntry? entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScheduleEditorScreen(initial: entry),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleEntry entry;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.entry,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EcoCard(
      onTap: onTap,
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
                  gradient: entry.enabled
                      ? AppColors.ecoGradient
                      : LinearGradient(colors: [
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.schedule_rounded,
                  color: entry.enabled ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.label,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${_fmt(entry.startTime)} – ${_fmt(entry.endTime)} · ${entry.targetTemperatureC.toStringAsFixed(1)}°C',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(value: entry.enabled, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.daysSummary,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: AppColors.forest),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

class _Empty extends StatelessWidget {
  final VoidCallback onAdd;
  const _Empty({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.schedule_rounded,
                size: 44, color: AppColors.forest),
          ),
          const SizedBox(height: 16),
          Text('No schedules yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Add a schedule to automate when the heater turns on and off across the week.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add schedule'),
          ),
        ],
      ),
    );
  }
}
