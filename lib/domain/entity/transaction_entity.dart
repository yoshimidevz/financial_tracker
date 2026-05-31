import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'transaction_category.dart';

enum TransactionType { income, expense }

extension TransactionTypeExtension on TransactionType {
  String get nameSingular {
    switch (this) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
    }
  }

  String get namePlural {
    switch (this) {
      case TransactionType.income:
        return 'Receitas';
      case TransactionType.expense:
        return 'Despesas';
    }
  }
}

class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;

  static final Uuid _uuid = Uuid();

  TransactionEntity({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    TransactionCategory? category,
  })  : id = id ?? _uuid.v4(),
        category =
            category ?? TransactionCategoryExtension.defaultFor(type);

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionCategory? category,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'type': type.name,
      'category': category.name,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    final type = TransactionType.values.firstWhere(
      (e) => e.name == map['type'],
      orElse: () => TransactionType.expense,
    );

    return TransactionEntity(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']).toLocal(),
      type: type,
      category: map['category'] != null
          ? TransactionCategory.values.firstWhere(
              (e) => e.name == map['category'],
              orElse: () => TransactionCategoryExtension.defaultFor(type),
            )
          : TransactionCategoryExtension.defaultFor(type),
    );
  }

  factory TransactionEntity.sampleExpense() {
    return TransactionEntity(
      title: 'Almoço',
      amount: 30.0,
      date: DateTime.now(),
      type: TransactionType.expense,
      category: TransactionCategory.alimentacao,
    );
  }

  factory TransactionEntity.sampleIncome() {
    return TransactionEntity(
      title: 'Salário',
      amount: 2500.0,
      date: DateTime.now(),
      type: TransactionType.income,
      category: TransactionCategory.salario,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionEntity &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.date == date &&
        other.type == type &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        date.hashCode ^
        type.hashCode ^
        category.hashCode;
  }
}