import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/energy_record.dart';
import '../../state/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/eco_card.dart';
import '../../widgets/leaf_background.dart';

const double _kWhPriceEur = 0.28; // Reasonable EU default for the cost estimate.

class EnergyScreen extends StatelessWidget {
  const EnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LeafBackground(
      child: SafeArea(
        child: Consumer<AppState>(
          builder: (context, state, _) {
            final history = state.energy;
            final todayKwh = history.isEmpty ? 0.0 : history.last.kilowattHours;
            final todayRuntime =
                history.isEmpty ? Duration.zero : history.last.runtime;
            final weekKwh =
                history.fold<double>(0, (sum, r) => sum + r.kilowattHours);
            final weekRuntime = history.fold<Duration>(
                Duration.zero, (sum, r) => sum + r.runtime);

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Text(
                  'Energy',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.forest,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Track your heater's runtime and consumption.",
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                _SummaryGrid(
                  todayKwh: todayKwh,
                  todayRuntime: todayRuntime,
                  weekKwh: weekKwh,
                  weekRuntime: weekRuntime,
                ),
                const SizedBox(height: 16),
                EcoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Last 7 days',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              'kWh',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.forest,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: history.isEmpty
                            ? Center(
                                child: Text(
                                  'No energy data yet.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary),
                                ),
                              )
                            : _EnergyChart(history: history),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                EcoCard(
                  gradient: AppColors.coolGradient,
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded,
                          color: AppColors.forest, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated cost (7d)',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppColors.forest,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(symbol: '€')
                                  .format(weekKwh * _kWhPriceEur),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.bark,
                              ),
                            ),
                            Text(
                              'at €${_kWhPriceEur.toStringAsFixed(2)} / kWh',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.bark.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SummaryGrid extends StatelessWidget {
  final double todayKwh;
  final Duration todayRuntime;
  final double weekKwh;
  final Duration weekRuntime;

  const _SummaryGrid({
    required this.todayKwh,
    required this.todayRuntime,
    required this.weekKwh,
    required this.weekRuntime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            title: 'Today',
            primary: '${todayKwh.toStringAsFixed(2)} kWh',
            secondary: _formatDuration(todayRuntime),
            gradient: AppColors.ecoGradient,
            primaryColor: Colors.white,
            secondaryColor: Colors.white70,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            title: 'This week',
            primary: '${weekKwh.toStringAsFixed(1)} kWh',
            secondary: _formatDuration(weekRuntime),
            color: AppColors.surface,
            primaryColor: AppColors.forest,
            secondaryColor: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m runtime';
    return '${h}h ${m}m runtime';
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String primary;
  final String secondary;
  final Color? color;
  final Gradient? gradient;
  final Color primaryColor;
  final Color secondaryColor;

  const _StatTile({
    required this.title,
    required this.primary,
    required this.secondary,
    required this.primaryColor,
    required this.secondaryColor,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return EcoCard(
      color: color,
      gradient: gradient,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: primaryColor.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Text(
            primary,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            secondary,
            style: theme.textTheme.bodySmall?.copyWith(color: secondaryColor),
          ),
        ],
      ),
    );
  }
}

class _EnergyChart extends StatelessWidget {
  final List<EnergyRecord> history;
  const _EnergyChart({required this.history});

  @override
  Widget build(BuildContext context) {
    final maxY = (history
                .map((r) => r.kilowattHours)
                .fold<double>(0, (a, b) => a > b ? a : b) *
            1.25)
        .clamp(1.0, double.infinity);
    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= history.length) return const SizedBox();
                final d = history[i].timestamp;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    DateFormat.E().format(d).substring(0, 1),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < history.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: history[i].kilowattHours,
                  width: 18,
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [AppColors.leaf, AppColors.forest],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
