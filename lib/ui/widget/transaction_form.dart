import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/common/theme/app_theme.dart';
import 'package:financial_tracker/domain/entity/transaction_category.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TransactionForm extends StatefulWidget {
  final Command1<void, Failure, TransactionEntity> submitCommand;
  final TransactionType type;
  final Color color;
  final TransactionEntity? initialTransaction;

  const TransactionForm({
    super.key,
    required this.type,
    required this.color,
    required this.submitCommand,
    this.initialTransaction,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late DateTime _selectedDate;
  late TransactionCategory _selectedCategory;

  bool get _isEditing => widget.initialTransaction != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
        text: widget.initialTransaction?.title ?? '');
    _amountController = TextEditingController(
        text: widget.initialTransaction != null
            ? widget.initialTransaction!.amount.toStringAsFixed(2)
            : '');
    _selectedDate = widget.initialTransaction?.date ?? DateTime.now();
    _selectedCategory = widget.initialTransaction?.category ??
        TransactionCategoryExtension.defaultFor(widget.type);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.blue700,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final transaction = TransactionEntity(
        id: widget.initialTransaction?.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        type: widget.type,
        category: _selectedCategory,
      );

      await widget.submitCommand.execute(transaction);

      if (widget.submitCommand.resultSignal.value?.isFailure ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Erro ao ${_isEditing ? 'editar' : 'adicionar'} ${widget.type.nameSingular}',
          ),
          backgroundColor: AppColors.negative,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.pop(context);
        return;
      }

      if (!_isEditing) {
        _titleController.clear();
        _amountController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedCategory =
              TransactionCategoryExtension.defaultFor(widget.type);
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            '${widget.type.nameSingular} ${_isEditing ? 'atualizada' : 'adicionada'} com sucesso!'),
        backgroundColor: AppColors.positive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = TransactionCategoryExtension.forType(widget.type);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),

            // Descrição
            _Label(text: 'Descrição', isDark: isDark),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Ex: Salário mensal',
                hintStyle: const TextStyle(
                    color: AppColors.grey400, fontSize: 14),
                prefixIcon: Icon(Icons.description_outlined,
                    color: AppColors.grey400, size: 18),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Informe uma descrição' : null,
            ),

            const SizedBox(height: 16),

            // Valor
            _Label(text: 'Valor', isDark: isDark),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0,00',
                hintStyle: const TextStyle(
                    color: AppColors.grey400, fontSize: 14),
                prefixIcon: Icon(Icons.attach_money_rounded,
                    color: AppColors.grey400, size: 18),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe um valor';
                if (double.tryParse(v) == null) return 'Digite um número válido';
                if (double.parse(v) <= 0)
                  return 'O valor deve ser maior que zero';
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Categoria
            _Label(text: 'Categoria', isDark: isDark),
            const SizedBox(height: 6),
            DropdownButtonFormField<TransactionCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                prefixIcon: Icon(_selectedCategory.icon,
                    color: widget.color, size: 18),
              ),
              selectedItemBuilder: (context) =>
                  categories.map((cat) => Text(cat.label)).toList(),
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 16, color: widget.color),
                      const SizedBox(width: 10),
                      Text(cat.label,
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),

            const SizedBox(height: 16),

            // Data
            _Label(text: 'Data', isDark: isDark),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _presentDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2D40)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2A3A50)
                        : AppColors.grey200,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: AppColors.grey400, size: 16),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.white : AppColors.grey800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Alterar',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Submit button
            Watch((context) {
              final isRunning = widget.submitCommand.runningSignal.value;
              return SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isRunning ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    disabledBackgroundColor:
                        widget.color.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: isRunning
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing
                              ? 'Salvar ${widget.type.nameSingular}'
                              : 'Adicionar ${widget.type.nameSingular}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;

  const _Label({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.grey400 : AppColors.grey600,
        letterSpacing: 0.3,
      ),
    );
  }
}