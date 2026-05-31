import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:financial_tracker/ui/widget/category_pie_chart.dart';

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
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  static const int _pageCount = 3;
  static const List<String> _pageLabels = [
    'Gráfico de Receitas/Despesas',
    'Gráfico por Categoria',
    'Resumo',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: SizedBox(
            height: 240,
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _pageCount,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                HapticFeedback.lightImpact();
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildPage(index),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Indicadores de página
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pageCount,
            (index) => TweenAnimationBuilder(
              tween: Tween<double>(
                begin: 0.0,
                end: _currentPage == index ? 1.0 : 0.0,
              ),
              duration: const Duration(milliseconds: 300),
              builder: (context, double value, _) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: value * 24 + 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Dica de navegação
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Arraste para ver: ${_pageLabels[(_currentPage + 1) % _pageCount]}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Hero(
          tag: 'summary1-card',
          child: SummaryCard(
            totalIncome: widget.totalIncome,
            totalExpense: widget.totalExpense,
            balance: widget.totalIncome - widget.totalExpense,
          ),
        );
      case 1:
        return Hero(
          tag: 'chart-widget',
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SummaryChart(
              totalIncome: widget.totalIncome,
              totalExpense: widget.totalExpense,
            ),
          ),
        );
      case 2:
      default:
        return Hero(
          tag: 'category-pie-chart',
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: CategoryPieChart(
              incomeTransactions: widget.incomeTransactions,
              expenseTransactions: widget.expenseTransactions,
            ),
          ),
        );
    }
  }
}