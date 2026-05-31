import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';
import '../../common/utils/formatter.dart';

class SummaryChart extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;

  const SummaryChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(Icons.pie_chart_rounded,
                    color: AppColors.blue700, size: 14),
              ),
              const SizedBox(width: 10),
              Text(
                'Receitas vs. Despesas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.grey800,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),

        if (totalIncome == 0 && totalExpense == 0)
          _buildEmptyState(context)
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(flex: 5, child: _buildPie(context)),
                  const SizedBox(width: 12),
                  Expanded(flex: 5, child: _buildLegend(context)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPie(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 32,
        sections: [
          PieChartSectionData(
            value: totalIncome,
            title: '',
            radius: 52,
            color: AppColors.blue700,
            showTitle: false,
          ),
          PieChartSectionData(
            value: totalExpense,
            title: '',
            radius: 52,
            color: AppColors.grey200,
            showTitle: false,
          ),
        ],
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(enabled: false),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegendItem(
          label: 'Receitas',
          color: AppColors.blue700,
          amount: totalIncome,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _LegendItem(
          label: 'Despesas',
          color: isDark ? AppColors.grey400 : AppColors.grey200,
          amount: totalExpense,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insert_chart_outlined_rounded,
                size: 36, color: AppColors.grey400),
            const SizedBox(height: 8),
            Text(
              'Sem transações ainda',
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey400,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final double amount;
  final bool isDark;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.amount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 1),
              Text(
                Formatter.formatCurrency(amount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColors.grey800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}