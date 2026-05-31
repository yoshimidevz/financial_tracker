import 'package:flutter/material.dart';

import 'transaction_entity.dart';

enum TransactionCategory {
  // Receitas
  salario,
  freelance,
  investimento,
  presente,
  outrasReceitas,

  // Despesas
  alimentacao,
  transporte,
  moradia,
  saude,
  lazer,
  educacao,
  vestuario,
  outrasDespesas,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.salario:
        return 'Salário';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investimento:
        return 'Investimento';
      case TransactionCategory.presente:
        return 'Presente';
      case TransactionCategory.outrasReceitas:
        return 'Outras Receitas';
      case TransactionCategory.alimentacao:
        return 'Alimentação';
      case TransactionCategory.transporte:
        return 'Transporte';
      case TransactionCategory.moradia:
        return 'Moradia';
      case TransactionCategory.saude:
        return 'Saúde';
      case TransactionCategory.lazer:
        return 'Lazer';
      case TransactionCategory.educacao:
        return 'Educação';
      case TransactionCategory.vestuario:
        return 'Vestuário';
      case TransactionCategory.outrasDespesas:
        return 'Outras Despesas';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.salario:
        return Icons.work;
      case TransactionCategory.freelance:
        return Icons.laptop;
      case TransactionCategory.investimento:
        return Icons.trending_up;
      case TransactionCategory.presente:
        return Icons.card_giftcard;
      case TransactionCategory.outrasReceitas:
        return Icons.attach_money;
      case TransactionCategory.alimentacao:
        return Icons.restaurant;
      case TransactionCategory.transporte:
        return Icons.directions_car;
      case TransactionCategory.moradia:
        return Icons.home;
      case TransactionCategory.saude:
        return Icons.favorite;
      case TransactionCategory.lazer:
        return Icons.sports_esports;
      case TransactionCategory.educacao:
        return Icons.school;
      case TransactionCategory.vestuario:
        return Icons.checkroom;
      case TransactionCategory.outrasDespesas:
        return Icons.more_horiz;
    }
  }

  /// Retorna as categorias disponíveis para cada tipo de transação
  static List<TransactionCategory> forType(TransactionType type) {
    if (type == TransactionType.income) {
      return [
        TransactionCategory.salario,
        TransactionCategory.freelance,
        TransactionCategory.investimento,
        TransactionCategory.presente,
        TransactionCategory.outrasReceitas,
      ];
    } else {
      return [
        TransactionCategory.alimentacao,
        TransactionCategory.transporte,
        TransactionCategory.moradia,
        TransactionCategory.saude,
        TransactionCategory.lazer,
        TransactionCategory.educacao,
        TransactionCategory.vestuario,
        TransactionCategory.outrasDespesas,
      ];
    }
  }

  /// Categoria padrão para cada tipo
  static TransactionCategory defaultFor(TransactionType type) {
    return type == TransactionType.income
        ? TransactionCategory.outrasReceitas
        : TransactionCategory.outrasDespesas;
  }
}