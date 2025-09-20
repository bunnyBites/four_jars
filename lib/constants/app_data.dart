import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/sub_category.dart';

// Our starting budget data
final List<Map<String, dynamic>> initialCategoriesData = [
  {
    'name': 'Needs',
    'type': MainCategoryType.needs,
    'allocated': 0.0,
    'spent': 0.0,
    'colorName': 'green',
  },
  {
    'name': 'Wants',
    'type': MainCategoryType.wants,
    'allocated': 0.0,
    'spent': 0.0,
    'colorName': 'blue',
  },
  {
    'name': 'Savings',
    'type': MainCategoryType.savings,
    'allocated': 0.0,
    'spent': 0.0,
    'colorName': 'purple',
  },
  {
    'name': 'Investments',
    'type': MainCategoryType.investments,
    'allocated': 0.0,
    'spent': 0.0,
    'colorName': 'orange',
  },
];

// Default sub-categories for the first launch
final List<SubCategory> initialSubCategories = [
  // Needs
  SubCategory(
    id: 'needs-groceries',
    name: 'Groceries',
    mainCategoryId: MainCategoryType.needs,
  ),
  SubCategory(
    id: 'needs-rent',
    name: 'Rent/Mortgage',
    mainCategoryId: MainCategoryType.needs,
  ),
  SubCategory(
    id: 'needs-utilities',
    name: 'Utilities',
    mainCategoryId: MainCategoryType.needs,
  ),
  // Wants
  SubCategory(
    id: 'wants-dining',
    name: 'Dining Out',
    mainCategoryId: MainCategoryType.wants,
  ),
  SubCategory(
    id: 'wants-movies',
    name: 'Movies',
    mainCategoryId: MainCategoryType.wants,
  ),
  SubCategory(
    id: 'wants-shopping',
    name: 'Shopping',
    mainCategoryId: MainCategoryType.wants,
  ),
  // Savings & Investments
  SubCategory(
    id: 'savings-general',
    name: 'General Savings',
    mainCategoryId: MainCategoryType.savings,
  ),
  SubCategory(
    id: 'investments-stocks',
    name: 'Stocks',
    mainCategoryId: MainCategoryType.investments,
  ),
];
