import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/goal/goal.dart';
import 'package:four_jars/models/main_category_type/main_category_type.dart';
import 'package:four_jars/models/recurring_transaction/recurring_transaction.dart';
import 'package:four_jars/models/sub_category/sub_category.dart';
import 'package:four_jars/models/transaction/transaction.dart';
import 'package:four_jars/screens/dashboard/dashboard_controller.dart';
import 'package:four_jars/screens/main/main_screen.dart';
import 'package:four_jars/theme/app_theme.dart';
import 'package:four_jars/theme/theme_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  // ensure Flutter is ready before we do anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // register our model adapters
  Hive.registerAdapter(MainCategoryTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(SubCategoryAdapter());
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(RecurrenceFrequencyAdapter());
  Hive.registerAdapter(RecurringTransactionAdapter());

  // Open all the boxes we need for our data
  await Hive.openBox('budgetBox');
  await Hive.openBox<Transaction>('transactionsBox');
  await Hive.openBox<SubCategory>('subCategoriesBox');
  await Hive.openBox<Goal>('goalsBox');
  await Hive.openBox<RecurringTransaction>('recurringTransactionsBox');

  runApp(
    MultiProvider(
      providers: [
        // 1. Provide a single instance of BudgetManager
        Provider<BudgetManager>(create: (context) => BudgetManager()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        // 2. Our existing DashboardController provider
        ChangeNotifierProvider(
          create: (context) => DashboardController(
            // It now reads the BudgetManager from the provider
            context.read<BudgetManager>(),
          ),
        ),
      ],
      child: const FourJarsApp(),
    ),
  );
}

class FourJarsApp extends StatelessWidget {
  const FourJarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          title: 'Four Jars',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
