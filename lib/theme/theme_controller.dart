import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeController extends ChangeNotifier {
  final _box = Hive.box('budgetBox');
  static const _themeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    loadThemeMode();
  }

  void loadThemeMode() {
    // read the saved theme index from Hive, defaulting to 0 (system)
    final savedThemeIndex = _box.get(_themeKey, defaultValue: 0);

    // convert the index back to a ThemeMode enum
    _themeMode = ThemeMode.values[savedThemeIndex];
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;

    // save the new theme's index to Hive
    _box.put(_themeKey, mode.index);
    notifyListeners();
  }
}
