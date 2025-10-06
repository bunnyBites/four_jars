import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:hive/hive.dart';

part 'sub_category.g.dart';

@HiveType(typeId: 3)
class SubCategory {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final MainCategoryType mainCategoryId;

  SubCategory({
    required this.id,
    required this.name,
    required this.mainCategoryId,
  });
}
