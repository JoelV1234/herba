import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/schedule_entry.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/eco_card.dart';
import '../../widgets/leaf_background.dart';

class ScheduleEditorScreen extends StatefulWidget {
  final ScheduleEntry? initial;
  const ScheduleEditorScreen({super.key, this.initial});

  @override
  State<ScheduleEditorScreen> createState() => _ScheduleEditorScreenState();
}

class _ScheduleEditorScreenState extends State<ScheduleEditorScreen> {
  late TextEditingController _label;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late Set<int> _days;
  late double _target;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _label = TextEditingController(text: i?.label ?? 'Morning warm-up');
    _start = i?.startTime ?? const TimeOfDay(hour: 6, minute: 0);
    _end = i?.endTime ?? const TimeOfDay(hour: 9, minute: 0);
    _days = i?.daysOfWeek.toSet() ?? {1, 2, 3, 4, 5};
    _target = i?.targetTemperatureC ?? 20;
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await showTimePicker(context: context, initialTime: _start);
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(context: context, initialTime: _end);
    if (picked != null) setState(() => _end = picked);
  }

  void _toggleDay(int day) {
    setState(() {
      if (_days.contains(day)) {
        _days.remove(day);
      } else {
        _days.add(day);
      }
    });
  }

  Future<void> _save() async {
    if (_days.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one day')),
      );
      return;
    }
    final id = widget.initial?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final entry = ScheduleEntry(
      id: id,
      label: _label.text.trim().isEmpty ? 'Schedule' : _label.text.trim(),
      startTime: _start,
      endTime: _end,
      daysOfWeek: _days,
      targetTemperatureC: _target,
      enabled: widget.initial?.enabled ?? true,
    );
    await context.read<AppState>().upsertSchedule(entry);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'New schedule' : 'Edit schedule'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: LeafBackground(
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              EcoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _label,
                      decoration: const InputDecoration(
                        hintText: 'Morning warm-up',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              EcoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TimePill(
                            label: 'Starts',
                            time: _start,
                            onTap: _pickStart,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimePill(
                            label: 'Ends',
                            time: _end,
                            onTap: _pickEnd,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              EcoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Days',
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (i) {
                        final day = i + 1;
                        const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final selected = _days.contains(day);
                        return GestureDetector(
                          onTap: () => _toggleDay(day),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.forest
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              labels[i],
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: selected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              EcoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Target temperature',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const Spacer(),
                        Text(
                          '${_target.toStringAsFixed(1)}°C',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.forest),
                        ),
                      ],
                    ),
                    Slider(
                      value: _target,
                      min: 5,
                      max: 30,
                      divisions: 50,
                      label: '${_target.toStringAsFixed(1)}°C',
                      onChanged: (v) => setState(() => _target = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimePill({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.forest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
