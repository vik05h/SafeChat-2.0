import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../providers/safety_provider.dart';
import '../models/safety_stats.dart';

class SafetyCenterScreen extends ConsumerWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyStatsAsync = ref.watch(safetyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Center'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              context.pushNamed('community_guidelines');
            },
          )
        ],
      ),
      body: safetyStatsAsync.when(
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCards(context, stats),
                const SizedBox(height: 24),
                const Text('30-Day Safety Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTrendChart(context, stats.safetyTrend),
                const SizedBox(height: 24),
                const Text('Moderation Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildStatsGrid(context, stats),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.gavel_rounded),
                    label: const Text('Appeals Dashboard'),
                    onPressed: () => context.pushNamed('appeals'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeaderCards(BuildContext context, SafetyStats stats) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryOrange),
            ),
            child: Column(
              children: [
                const Icon(Icons.shield_rounded, color: AppColors.primaryOrange, size: 32),
                const SizedBox(height: 8),
                Text('${stats.safetyScore}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                const Text('Safety Score', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success),
            ),
            child: Column(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.success, size: 32),
                const SizedBox(height: 8),
                Text('${stats.reputationScore}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.success)),
                const Text('Reputation', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(BuildContext context, List<SafetyTrendPoint> trendData) {
    if (trendData.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.elevatedSurface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('Not enough data to display trend.')),
      );
    }

    final spots = trendData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.score.toDouble());
    }).toList();

    return Container(
      height: 250,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (trendData.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primaryOrange,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primaryOrange.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, SafetyStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatTile('Reports Submitted', stats.reportsSubmitted.toString(), Icons.flag_rounded),
        _buildStatTile('Reports Resolved', stats.reportsResolved.toString(), Icons.check_circle_outline),
        _buildStatTile('Warnings Received', stats.warningsReceived.toString(), Icons.warning_amber_rounded, color: AppColors.warning),
        _buildStatTile('Appeals Won / Lost', '${stats.appealsWon} / ${stats.appealsLost}', Icons.balance_rounded),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
            ],
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}
