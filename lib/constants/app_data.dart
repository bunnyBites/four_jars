import 'package:four_jars/models/main_category_type.dart';

final List<Map<String, dynamic>> initialCategoriesData = [
  {
    'name': 'Needs',
    'type': MainCategoryType.needs,
    'allocated': 50000.0,
    'spent': 32500.0,
    'colorName': 'green',
  },
  {
    'name': 'Wants',
    'type': MainCategoryType.wants,
    'allocated': 30000.0,
    'spent': 15750.0,
    'colorName': 'blue',
  },
  {
    'name': 'Savings',
    'type': MainCategoryType.savings,
    'allocated': 10000.0,
    'spent': 10000.0,
    'colorName': 'purple',
  },
  {
    'name': 'Investments',
    'type': MainCategoryType.investments,
    'allocated': 10000.0,
    'spent': 10000.0,
    'colorName': 'orange',
  },
];
