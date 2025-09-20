import 'package:flutter/material.dart';
import 'package:four_jars/logic/budget_manager.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:four_jars/screens/home/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register our new adapters
  Hive.registerAdapter(MainCategoryTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());

  // We'll open a second box just for transactions
  await Hive.openBox('budgetBox');
  await Hive.openBox<Transaction>('transactionsBox'); // A typed box

  // Create the single BudgetManager instance
  final budgetManager = BudgetManager();

  // Load the data from Hive
  budgetManager.loadData();

  runApp(FourJarsApp(budgetManager: budgetManager));
}

class FourJarsApp extends StatelessWidget {
  final BudgetManager budgetManager;
  const FourJarsApp({super.key, required this.budgetManager});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Four Jars',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: HomeScreen(budgetManager: budgetManager),
    );
  }
}
