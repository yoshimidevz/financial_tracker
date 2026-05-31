import 'package:financial_tracker/common/errors/errors_classes.dart';
import 'package:financial_tracker/common/patterns/command.dart';
import 'package:financial_tracker/domain/entity/transaction_category.dart';
import 'package:financial_tracker/domain/entity/transaction_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Um widget reutilizável de formulário para adicionar transações de receita ou despesa
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
      text: widget.initialTransaction?.title ?? '',
    );
    _amountController = TextEditingController(
      text: widget.initialTransaction != null
          ? widget.initialTransaction!.amount.toStringAsFixed(2)
          : '',
    );
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
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao ${_isEditing ? 'editar' : 'adicionar'} ${widget.type.nameSingular}: '
              '${widget.submitCommand.resultSignal.value?.failureValueOrNull ?? 'Erro desconhecido'}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.type.nameSingular} ${_isEditing ? 'atualizada' : 'adicionada'} com sucesso!',
          ),
          backgroundColor: widget.color,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = TransactionCategoryExtension.forType(widget.type);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Descrição
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe uma descrição';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Valor
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Informe um valor';
                if (double.tryParse(value) == null) return 'Digite um número válido';
                if (double.parse(value) <= 0) return 'O valor deve ser maior que zero';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Categoria
            DropdownButtonFormField<TransactionCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Categoria',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  _selectedCategory.icon,
                  color: widget.color,
                ),
              ),
              // O selectedItemBuilder define como o item selecionado aparece quando o dropdown está fechado
              selectedItemBuilder: (context) {
                return categories.map((cat) {
                  return Text(cat.label);
                }).toList();
              },
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 18, color: widget.color),
                      const SizedBox(width: 10),
                      Text(cat.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Data
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: Text(
                    'Selecionar Data',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Botão de envio
            Watch((context) {
              final isRunning = widget.submitCommand.runningSignal.value;
              return SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isRunning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing
                              ? 'Salvar ${widget.type.nameSingular}'
                              : 'Adicionar ${widget.type.nameSingular}',
                          style: const TextStyle(fontSize: 16),
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
