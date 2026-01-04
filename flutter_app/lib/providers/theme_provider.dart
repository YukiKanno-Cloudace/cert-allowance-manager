import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_theme.dart';

/// テーマ管理プロバイダー
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  AppThemeType _currentTheme = AppThemeType.light;

  AppThemeType get currentTheme => _currentTheme;

  ThemeData get themeData => AppTheme.getTheme(_currentTheme);

  LinearGradient get gradient => AppTheme.getGradient(_currentTheme);

  bool get isDarkMode => _currentTheme == AppThemeType.dark;

  /// 初期化
  Future<void> initialize() async {
    await _loadTheme();
  }

  /// テーマを読み込み
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null && themeIndex < AppThemeType.values.length) {
        _currentTheme = AppThemeType.values[themeIndex];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  /// テーマを変更
  Future<void> setTheme(AppThemeType theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, theme.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// テーマをトグル（ライト⇔ダーク）
  Future<void> toggleDarkMode() async {
    if (_currentTheme == AppThemeType.dark) {
      await setTheme(AppThemeType.light);
    } else {
      await setTheme(AppThemeType.dark);
    }
  }
}

