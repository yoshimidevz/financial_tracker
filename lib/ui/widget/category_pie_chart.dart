import 'package:fl_chart/fl_chart.dart';
import 'package:financial_tracker/common/utils/formatter.dart';
import 'package:financial_tracker/domain/entity/transaction_category.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';

/// Gráfico de pizza com breakdown por categoria para o mês atual
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

  // Paleta de cores para as fatias
  static const List<Color> _sliceColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6584),
    Color(0xFF43C6AC),
    Color(0xFFFFA07A),
    Color(0xFF4FC3F7),
    Color(0xFFFFD54F),
    Color(0xFFAED581),
    Color(0xFFBA68C8),
  ];

  List<TransactionEntity> get _currentList =>
      _selectedType == TransactionType.income
          ? widget.incomeTransactions
          : widget.expenseTransactions;

  /// Agrupa as transações do mês atual por categoria e soma os valores
  Map<TransactionCategory, double> get _categoryTotals {
    final now = DateTime.now();
    final filtered = _currentList.where(
      (t) => t.date.year == now.year && t.date.month == now.month,
    );

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totals = _categoryTotals;
    final total = _grandTotal;
    final isEmpty = totals.isEmpty;

    final isIncome = _selectedType == TransactionType.income;
    final activeColor =
        isIncome ? colorScheme.primary : colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com título e toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Icon(Icons.donut_large, color: activeColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Por Categoria — ${_monthLabel()}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Toggle Receita / Despesa
              _buildToggle(colorScheme),
            ],
          ),
        ),

        // Corpo: gráfico + legenda
        if (isEmpty)
          _buildEmpty(context)
        else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
              child: Row(
                children: [
                  // Pizza
                  Expanded(
                    flex: 5,
                    child: _buildPie(totals, total, activeColor),
                  ),
                  // Legenda
                  Expanded(
                    flex: 5,
                    child: _buildLegend(totals, total, theme),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToggle(ColorScheme colorScheme) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleBtn(
            label: 'Receitas',
            type: TransactionType.income,
            activeColor: colorScheme.primary,
          ),
          _toggleBtn(
            label: 'Despesas',
            type: TransactionType.expense,
            activeColor: colorScheme.secondary,
          ),
        ],
      ),
    );
  }

  Widget _toggleBtn({
    required String label,
    required TransactionType type,
    required Color activeColor,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = type;
        _touchedIndex = -1;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildPie(
    Map<TransactionCategory, double> totals,
    double total,
    Color activeColor,
  ) {
    final entries = totals.entries.toList();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 28,
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
            radius: isTouched ? 52 : 42,
            title: isTouched ? '${pct.toStringAsFixed(0)}%' : '',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            showTitle: isTouched,
          );
        }),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildLegend(
    Map<TransactionCategory, double> totals,
    double total,
    ThemeData theme,
  ) {
    final entries = totals.entries.toList();

    return ListView.builder(
      itemCount: entries.length,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (context, i) {
        final cat = entries[i].key;
        final value = entries[i].value;
        final pct = total > 0 ? value / total * 100 : 0.0;
        final color = _sliceColors[i % _sliceColors.length];
        final isTouched = i == _touchedIndex;

        return GestureDetector(
          onTap: () => setState(() {
            _touchedIndex = isTouched ? -1 : i;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isTouched
                  ? color.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(cat.icon, size: 12, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cat.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: isTouched
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.donut_large, size: 36, color: Colors.grey[350]),
            const SizedBox(height: 8),
            Text(
              'Sem dados no mês atual',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
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