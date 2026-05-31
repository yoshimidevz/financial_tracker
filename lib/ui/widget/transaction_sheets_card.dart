import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';

import '../../common/utils/formatter.dart';
import '../../domain/entity/transaction_category.dart';
import '../../domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';

class TransactionCardSheets extends StatefulWidget {
  final List<TransactionEntity> incomeTransactions;
  final List<TransactionEntity> expenseTransactions;
  final Function(String id) onDelete;
  final Function(TransactionEntity transaction) onEdit;
  final Command1<void, Failure, TransactionEntity> undoDelete;
  final BuildContext scaffoldContext;

  const TransactionCardSheets({
    super.key,
    required this.incomeTransactions,
    required this.expenseTransactions,
    required this.onDelete,
    required this.onEdit,
    required this.undoDelete,
    required this.scaffoldContext,
  });

  @override
  State<TransactionCardSheets> createState() => _TransactionCardSheetsState();
}

class _TransactionCardSheetsState extends State<TransactionCardSheets>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Transações',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: isDark ? AppColors.white : AppColors.grey800,
              ),
            ),
          ),

          // ── Tab bar (pill style) ───────────────────────────────────────
          Container(
            height: 40,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2B3C) : AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              padding: EdgeInsets.zero,
              indicator: BoxDecoration(
                color: isDark ? AppColors.blue700 : AppColors.blue700,
                borderRadius: BorderRadius.circular(9),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.grey400,
              tabs: [
                _buildTab(TransactionType.income.namePlural,
                    Icons.arrow_upward_rounded, 0),
                _buildTab(TransactionType.expense.namePlural,
                    Icons.arrow_downward_rounded, 1),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Tab content ────────────────────────────────────────────────
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2D40) : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionList(
                    context,
                    widget.incomeTransactions,
                    AppColors.blue700,
                    TransactionType.income.namePlural,
                  ),
                  _buildTransactionList(
                    context,
                    widget.expenseTransactions,
                    AppColors.expense,
                    TransactionType.expense.namePlural,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, int index) {
    final isSelected = _tabController.index == index;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 5),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<TransactionEntity> transactions,
    Color color,
    String title,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF243347) : AppColors.grey50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                title == TransactionType.income.namePlural
                    ? Icons.savings_outlined
                    : Icons.shopping_bag_outlined,
                size: 28,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sem ${title.toLowerCase()} registradas',
              style: const TextStyle(
                color: AppColors.grey400,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: isDark ? const Color(0xFF2A3A50) : AppColors.grey100,
      ),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final undoTransaction = transaction.copyWith();

        return Dismissible(
          key: Key(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: AppColors.negative.withOpacity(0.08),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.negative,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          onDismissed: (direction) async {
            await widget.onDelete(transaction.id);

            ScaffoldMessenger.of(widget.scaffoldContext).clearSnackBars();
            ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
              SnackBar(
                content: Text('${transaction.title} excluída'),
                backgroundColor: isDark ? const Color(0xFF1E2D40) : AppColors.grey800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                action: SnackBarAction(
                  label: 'DESFAZER',
                  textColor: AppColors.blue200,
                  onPressed: () async {
                    await widget.undoDelete.execute(undoTransaction);
                    final ok = widget.undoDelete.resultSignal.value?.isSuccess ?? false;
                    ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                      SnackBar(
                        content: Text(ok
                            ? '${transaction.title} restaurada!'
                            : '${widget.undoDelete.resultSignal.value?.failureValueOrNull ?? 'Erro desconhecido'}'),
                        backgroundColor: ok ? AppColors.positive : AppColors.negative,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          child: _TransactionTile(
            transaction: transaction,
            color: color,
            onEdit: () => widget.onEdit(transaction),
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  final Color color;
  final VoidCallback onEdit;

  const _TransactionTile({
    required this.transaction,
    required this.color,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(transaction.category.icon, color: color, size: 18),
            ),

            const SizedBox(width: 12),

            // Title + date + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.grey800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        Formatter.formatDate(transaction.date),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey400,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.grey400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        transaction.category.label,
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount + edit
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatter.formatCurrency(transaction.amount),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit_outlined,
                      size: 14, color: AppColors.grey400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}