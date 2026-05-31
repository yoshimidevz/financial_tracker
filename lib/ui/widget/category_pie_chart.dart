import 'package:fl_chart/fl_chart.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';
import 'package:financial_tracker/common/utils/formatter.dart';
import 'package:financial_tracker/domain/entity/transaction_category.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';

class CategoryPieChart extends StatefulWidget {
  final List<TransactionEntity> incomeTransactions;
  final List<TransactionEntity> expenseTransactions;

  const CategoryPieChart({
    super.key,
    required this.incomeTransactions,
    required this.expenseTransactions,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  TransactionType _selectedType = TransactionType.expense;
  int _touchedIndex = -1;

  // Blue-harmonic palette (clean, not rainbow)
  static const List<Color> _sliceColors = [
    Color(0xFF1A56DB),
    Color(0xFF3B82F6),
    Color(0xFF60A5FA),
    Color(0xFF93C5FD),
    Color(0xFF1E40AF),
    Color(0xFF2563EB),
    Color(0xFF7DD3FC),
    Color(0xFF0EA5E9),
  ];

  List<TransactionEntity> get _currentList =>
      _selectedType == TransactionType.income
          ? widget.incomeTransactions
          : widget.expenseTransactions;

  Map<TransactionCategory, double> get _categoryTotals {
    final now = DateTime.now();
    final filtered = _currentList.where(
        (t) => t.date.year == now.year && t.date.month == now.month);
    final Map<TransactionCategory, double> totals = {};
    for (final t in filtered) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    return totals;
  }

  double get _grandTotal =>
      _categoryTotals.values.fold(0.0, (sum, v) => sum + v);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totals = _categoryTotals;
    final total = _grandTotal;
    final isEmpty = totals.isEmpty;
    final isIncome = _selectedType == TransactionType.income;
    final activeColor = isIncome ? AppColors.blue700 : AppColors.expense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.blue50,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(Icons.donut_small_rounded,
                    color: AppColors.blue700, size: 13),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Por Categoria — ${_monthLabel()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.white : AppColors.grey800,
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildToggle(isDark),
            ],
          ),
        ),

        if (isEmpty)
          _buildEmpty()
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Row(
                children: [
                  Expanded(flex: 5, child: _buildPie(totals, total)),
                  Expanded(flex: 5, child: _buildLegend(totals, total, isDark)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToggle(bool isDark) {
    return Container(
      height: 26,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF243347) : AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn('Rec.', TransactionType.income, isDark),
          _toggleBtn('Desp.', TransactionType.expense, isDark),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, TransactionType type, bool isDark) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type;
        _touchedIndex = -1;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue700 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.grey400,
          ),
        ),
      ),
    );
  }

  Widget _buildPie(Map<TransactionCategory, double> totals, double total) {
    final entries = totals.entries.toList();
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 26,
        startDegreeOffset: -90,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex =
                  response.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sections: List.generate(entries.length, (i) {
          final isTouched = i == _touchedIndex;
          final pct = total > 0 ? entries[i].value / total * 100 : 0.0;
          final color = _sliceColors[i % _sliceColors.length];
          return PieChartSectionData(
            value: entries[i].value,
            color: color,
            radius: isTouched ? 48 : 40,
            title: isTouched ? '${pct.toStringAsFixed(0)}%' : '',
            titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white),
            showTitle: isTouched,
          );
        }),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLegend(
      Map<TransactionCategory, double> totals, double total, bool isDark) {
    final entries = totals.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      padding: const EdgeInsets.symmetric(vertical: 2),
      itemBuilder: (context, i) {
        final cat = entries[i].key;
        final value = entries[i].value;
        final pct = total > 0 ? value / total * 100 : 0.0;
        final color = _sliceColors[i % _sliceColors.length];
        final isTouched = i == _touchedIndex;

        return GestureDetector(
          onTap: () => setState(
              () => _touchedIndex = isTouched ? -1 : i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 4),
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: isTouched
                  ? color.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Icon(cat.icon, size: 11, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cat.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isTouched
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isDark ? AppColors.grey200 : AppColors.grey600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.donut_small_outlined,
                size: 30, color: AppColors.grey400),
            const SizedBox(height: 6),
            Text(
              'Sem dados no mês',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey400,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _monthLabel() {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    final now = DateTime.now();
    return '${months[now.month - 1]}/${now.year}';
  }
}