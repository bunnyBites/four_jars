import 'package:four_jars/models/main_category_type.dart';

class SubCategory {
  final String id;
  final String name;
  final double allocatedAmount;
  final MainCategoryType mainCategoryId;

  SubCategory({
    required this.id,
    required this.name,
    required this.allocatedAmount,
    required this.mainCategoryId,
  });
}
