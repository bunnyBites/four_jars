import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:hive/hive.dart';

part 'recurring_transaction.g.dart';

@HiveType(typeId: 5)
enum RecurrenceFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
}

@HiveType(typeId: 6)
class RecurringTransaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final MainCategoryType mainCategoryId;

  @HiveField(4)
  final String subCategoryId;

  @HiveField(5)
  final RecurrenceFrequency frequency;

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  DateTime? lastProcessedDate;

  RecurringTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.mainCategoryId,
    required this.subCategoryId,
    required this.frequency,
    required this.startDate,
    this.lastProcessedDate,
  });
}
