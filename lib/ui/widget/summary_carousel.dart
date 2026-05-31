import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:financial_tracker/ui/widget/category_pie_chart.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';

import 'summary_card.dart';
import 'summary_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SummaryCarousel extends StatefulWidget {
  final double totalIncome;
  final double totalExpense;
  final List<TransactionEntity> incomeTransactions;
  final List<TransactionEntity> expenseTransactions;

  const SummaryCarousel({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeTransactions,
    required this.expenseTransactions,
  });

  @override
  State<SummaryCarousel> createState() => _SummaryCarouselState();
}

class _SummaryCarouselState extends State<SummaryCarousel>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  static const int _pageCount = 3;
  static const List<String> _pageLabels = [
    'Resumo',
    'Receitas vs. Despesas',
    'Por Categoria',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _pageCount,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              HapticFeedback.selectionClick();
            },
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildPage(index),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pageCount, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 20 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.blue700
                    : (isDark ? AppColors.grey600 : AppColors.grey200),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Hint label
        Text(
          _pageLabels[(_currentPage + 1) % _pageCount],
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.grey400 : AppColors.grey400,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return SummaryCard(
          totalIncome: widget.totalIncome,
          totalExpense: widget.totalExpense,
          balance: widget.totalIncome - widget.totalExpense,
        );
      case 1:
        return _CardWrapper(
          child: SummaryChart(
            totalIncome: widget.totalIncome,
            totalExpense: widget.totalExpense,
          ),
        );
      case 2:
      default:
        return _CardWrapper(
          child: CategoryPieChart(
            incomeTransactions: widget.incomeTransactions,
            expenseTransactions: widget.expenseTransactions,
          ),
        );
    }
  }
}

class _CardWrapper extends StatelessWidget {
  final Widget child;

  const _CardWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2D40) : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}