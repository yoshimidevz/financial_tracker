import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';

import 'transaction_form.dart';

class TransactionSheet extends StatelessWidget {
  final TransactionType type;
  final Command1<void, Failure, TransactionEntity> submitCommand;
  final TransactionEntity? initialTransaction;

  const TransactionSheet({
    super.key,
    required this.type,
    required this.submitCommand,
    this.initialTransaction,
  });

  static Future<void> show({
    required BuildContext context,
    required TransactionType type,
    required Command1<void, Failure, TransactionEntity> submitCommand,
    TransactionEntity? initialTransaction,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionSheet(
        type: type,
        submitCommand: submitCommand,
        initialTransaction: initialTransaction,
      ),
    );
  }

  bool get _isEditing => initialTransaction != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = type == TransactionType.income;
    final availableHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: availableHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF152030) : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A3A50) : AppColors.grey200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? AppColors.blue700.withOpacity(0.1)
                        : AppColors.expense.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isEditing
                        ? Icons.edit_rounded
                        : (isIncome
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded),
                    color: isIncome ? AppColors.blue700 : AppColors.expense,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${_isEditing ? 'Editar' : 'Adicionar'} ${type.nameSingular}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: isDark ? AppColors.white : AppColors.grey800,
                  ),
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A3A50) : AppColors.grey100,
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: TransactionForm(
                  type: type,
                  color: isIncome ? AppColors.blue700 : AppColors.expense,
                  submitCommand: submitCommand,
                  initialTransaction: initialTransaction,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}