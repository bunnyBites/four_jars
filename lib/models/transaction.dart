import 'package:four_jars/models/main_category_type.dart';

class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final MainCategoryType mainCategoryId;
  final String subCategoryId;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.mainCategoryId,
    required this.subCategoryId,
  });
}
