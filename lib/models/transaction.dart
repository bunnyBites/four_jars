import 'package:hive/hive.dart';
import 'package:four_jars/models/main_category_type.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final MainCategoryType mainCategoryId;

  @HiveField(5)
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
