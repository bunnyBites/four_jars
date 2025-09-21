import 'package:flutter/material.dart';
import 'package:four_jars/models/main_category_type.dart';
import 'package:four_jars/models/sub_category.dart';
import 'package:four_jars/models/transaction.dart';
import 'package:four_jars/screens/home/home_screen.dart';
import 'package:four_jars/screens/home/home_screen_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter is ready before we do anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register our model adapters
  Hive.registerAdapter(MainCategoryTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(SubCategoryAdapter());

  // Open all the boxes we need for our data
  await Hive.openBox('budgetBox');
  await Hive.openBox<Transaction>('transactionsBox');
  await Hive.openBox<SubCategory>('subCategoriesBox');

  runApp(
    ChangeNotifierProvider(
      create: (context) => HomeController(),
      child: const FourJarsApp(),
    ),
  );
}

class FourJarsApp extends StatelessWidget {
  const FourJarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Four Jars',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
