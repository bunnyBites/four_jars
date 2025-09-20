import 'package:hive/hive.dart';

part 'main_category_type.g.dart';

@HiveType(typeId: 0)
enum MainCategoryType {
  @HiveField(0)
  needs,
  @HiveField(1)
  wants,
  @HiveField(2)
  savings,
  @HiveField(3)
  investments,
}
