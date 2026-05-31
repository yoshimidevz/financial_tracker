import 'dart:math';
import 'package:faker_dart/faker_dart.dart';
import '../domain/entity/transaction_category.dart';
import '../domain/entity/transaction_entity.dart';

abstract class TransactionFakeFactory {
  static TransactionEntity factory() {
    final faker = Faker.instance;
    faker.setLocale(FakerLocaleType.pt_PT);

    final type = faker.datatype.boolean()
        ? TransactionType.income
        : TransactionType.expense;

    final categories = TransactionCategoryExtension.forType(type);
    final category = categories[Random().nextInt(categories.length)];

    return TransactionEntity(
      title: faker.commerce.productName(),
      type: type,
      category: category,
      date: faker.date.between(
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      ),
      amount: faker.datatype.float(
        min: 100.0,
        max: 2000.0,
        precision: 2,
      ),
    );
  }
}