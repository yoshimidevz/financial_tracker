import '../../common/config/dependencies.dart';
import '../../common/theme/app_theme.dart';
import '../../common/types/date_filter_type.dart';
import '../../domain/entity/transaction_entity.dart';
import 'package:financial_tracker/ui/controller/home_page_controller.dart';
import 'package:financial_tracker/ui/widget/date_filter_transactions.dart';
import 'package:financial_tracker/ui/widget/summary_carousel.dart';
import 'package:financial_tracker/ui/widget/transaction_sheet.dart';
import 'package:financial_tracker/ui/widget/transaction_sheets_card.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomePageController viewModelController;

  @override
  void initState() {
    viewModelController = injector.get<HomePageController>();
    viewModelController.load.execute();
    super.initState();
  }

  void _toggleFilterVisibility() {
    viewModelController.toggleFilterVisibility();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.grey800 : AppColors.grey50,
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        backgroundColor: isDark ? AppColors.grey800 : AppColors.white,
        foregroundColor: isDark ? AppColors.white : AppColors.grey800,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200),
        ),
        actions: [
          Watch((context) {
            final isVisible = viewModelController.isFilterVisible.value;
            return _AppBarIconBtn(
              icon: isVisible ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
              tooltip: isVisible ? 'Ocultar filtros' : 'Mostrar filtros',
              onPressed: viewModelController.toggleFilterVisibility,
            );
          }),
          _AppBarIconBtn(
            icon: Icons.receipt_long_rounded,
            tooltip: 'Visualizar todas as transações',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Summary Carousel ─────────────────────────────────────────
            Watch((context) {
              final income   = viewModelController.totalIncome.value;
              final expense  = viewModelController.totalExpense.value;
              final incomes  = viewModelController.incomes.value;
              final expenses = viewModelController.expenses.value;
              return SummaryCarousel(
                totalIncome: income,
                totalExpense: expense,
                incomeTransactions: incomes,
                expenseTransactions: expenses,
              );
            }),

            // ── Date Filter ───────────────────────────────────────────────
            Watch((context) {
              final isVisible = viewModelController.isFilterVisible.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: isVisible ? null : 0,
                child: isVisible
                    ? DateFilterTransactions(
                        filtro: (
                          type: viewModelController.filterType,
                          startDate: viewModelController.startDate,
                          endDate: viewModelController.endDate,
                        ),
                        onFilterChanged: (startDate, endDate) {
                          viewModelController.searchTransactionsByDate
                              .execute(startDate!, endDate!);
                        },
                        onUpdateFilter: (type, startDate, endDate) {
                          viewModelController.setFiltersParams(
                              type, startDate, endDate);
                        },
                        onAllTransactionsFiltered: () {
                          viewModelController.load.execute();
                        },
                        onTapHideFilter: _toggleFilterVisibility,
                      )
                    : const SizedBox.shrink(),
              );
            }),

            // ── Action Buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      type: TransactionType.income,
                      icon: Icons.add_rounded,
                      color: AppColors.blue700,
                      onPressed: () => _showIncomeSheet(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      type: TransactionType.expense,
                      icon: Icons.remove_rounded,
                      color: AppColors.expense,
                      onPressed: () => _showExpenseSheet(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Transactions ──────────────────────────────────────────────
            Watch((context) {
              final incomes  = viewModelController.incomes.value;
              final expenses = viewModelController.expenses.value;
              return TransactionCardSheets(
                incomeTransactions: incomes,
                expenseTransactions: expenses,
                onDelete: (id) {
                  viewModelController.deleteTransaction.execute(id);
                },
                onEdit: (transaction) {
                  _showEditSheet(context, transaction);
                },
                undoDelete: viewModelController.undoDelectedTransaction,
                scaffoldContext: context,
              );
            }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showIncomeSheet(BuildContext context) {
    TransactionSheet.show(
      context: context,
      type: TransactionType.income,
      submitCommand: viewModelController.saveTransaction,
    );
  }

  void _showExpenseSheet(BuildContext context) {
    TransactionSheet.show(
      context: context,
      type: TransactionType.expense,
      submitCommand: viewModelController.saveTransaction,
    );
  }

  void _showEditSheet(BuildContext context, TransactionEntity transaction) {
    TransactionSheet.show(
      context: context,
      type: transaction.type,
      submitCommand: viewModelController.editTransaction,
      initialTransaction: transaction,
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _AppBarIconBtn({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      color: isDark ? AppColors.grey400 : AppColors.grey600,
      splashRadius: 20,
      onPressed: onPressed,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final TransactionType type;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.type,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = type == TransactionType.income;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isIncome
                ? (isDark ? AppColors.blue700.withOpacity(0.18) : AppColors.blue50)
                : (isDark ? AppColors.grey600.withOpacity(0.18) : AppColors.grey100),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isIncome
                  ? AppColors.blue200.withOpacity(isDark ? 0.3 : 0.8)
                  : AppColors.grey200,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                type.namePlural,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}