import 'package:flutter/material.dart';

/// テーマの種類
enum AppThemeType {
  light,
  neutralGray,
  softBlue,
  softGreen,
  warmGray,
  minimalGray,
  dark,
}

/// テーマ情報クラス
class ThemeInfo {
  final String name;
  final String description;
  final AppThemeType type;
  final Color previewColor1;
  final Color previewColor2;

  const ThemeInfo({
    required this.name,
    required this.description,
    required this.type,
    required this.previewColor1,
    required this.previewColor2,
  });
}

/// アプリのテーマ設定
class AppTheme {
  /// テーマ一覧
  static const List<ThemeInfo> themes = [
    ThemeInfo(
      name: 'ライト',
      description: 'シンプル・ブルーグレー',
      type: AppThemeType.light,
      previewColor1: Color(0xFF5B7C99),
      previewColor2: Color(0xFF7D98B3),
    ),
    ThemeInfo(
      name: 'ニュートラルグレー',
      description: 'Google風シンプル',
      type: AppThemeType.neutralGray,
      previewColor1: Color(0xFF5F6368),
      previewColor2: Color(0xFF80868B),
    ),
    ThemeInfo(
      name: 'ソフトブルー',
      description: '落ち着いた青',
      type: AppThemeType.softBlue,
      previewColor1: Color(0xFF4A6FA5),
      previewColor2: Color(0xFF6B89B8),
    ),
    ThemeInfo(
      name: 'ソフトグリーン',
      description: '優しい緑',
      type: AppThemeType.softGreen,
      previewColor1: Color(0xFF5A8F7B),
      previewColor2: Color(0xFF73A598),
    ),
    ThemeInfo(
      name: 'ウォームグレー',
      description: '温かみのあるグレー',
      type: AppThemeType.warmGray,
      previewColor1: Color(0xFF7D6B5D),
      previewColor2: Color(0xFF998577),
    ),
    ThemeInfo(
      name: 'ミニマルグレー',
      description: '最小限の色使い',
      type: AppThemeType.minimalGray,
      previewColor1: Color(0xFF4A5568),
      previewColor2: Color(0xFF718096),
    ),
    ThemeInfo(
      name: 'ダークモード',
      description: '目に優しい暗色',
      type: AppThemeType.dark,
      previewColor1: Color(0xFF2C2C2C),
      previewColor2: Color(0xFF1E1E1E),
    ),
  ];

  /// 共通のカラー定義
  static const Color errorColor = Color(0xFFD32F2F); // 赤：期限切れ
  static const Color warningColor = Color(0xFFF57C00); // オレンジ：更新必要
  static const Color cautionColor = Color(0xFFFFC107); // 黄色：注意
  static const Color successColor = Color(0xFF388E3C); // 緑：有効

  /// ダークモード用の色
  static const Color darkErrorColor = Color(0xFFF28B82);
  static const Color darkWarningColor = Color(0xFFFDD663);
  static const Color darkSuccessColor = Color(0xFF81C995);

  /// デフォルトのプライマリカラー（後方互換性のため）
  static const Color primaryColor = Color(0xFF5B7C99);

  /// デフォルトのテキストスタイル（後方互換性のため）
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2C3E50),
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Color(0xFF90A4AE),
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: Color(0xFF2C3E50),
  );

  /// テーマに応じたThemeDataを取得
  static ThemeData getTheme(AppThemeType type) {
    switch (type) {
      case AppThemeType.light:
        return _buildTheme(
          primaryColor: const Color(0xFF5B7C99),
          secondaryColor: const Color(0xFF7D98B3),
          backgroundColor: const Color(0xFFF5F7FA),
          textColor: const Color(0xFF2C3E50),
          textSecondaryColor: const Color(0xFF546E7A),
          textMutedColor: const Color(0xFF90A4AE),
          isDark: false,
        );
      case AppThemeType.neutralGray:
        return _buildTheme(
          primaryColor: const Color(0xFF5F6368),
          secondaryColor: const Color(0xFF80868B),
          backgroundColor: const Color(0xFFF8F9FA),
          textColor: const Color(0xFF202124),
          textSecondaryColor: const Color(0xFF5F6368),
          textMutedColor: const Color(0xFF9AA0A6),
          isDark: false,
        );
      case AppThemeType.softBlue:
        return _buildTheme(
          primaryColor: const Color(0xFF4A6FA5),
          secondaryColor: const Color(0xFF6B89B8),
          backgroundColor: const Color(0xFFF0F4F8),
          textColor: const Color(0xFF1E3A5F),
          textSecondaryColor: const Color(0xFF4A6FA5),
          textMutedColor: const Color(0xFF8BA3C7),
          isDark: false,
        );
      case AppThemeType.softGreen:
        return _buildTheme(
          primaryColor: const Color(0xFF5A8F7B),
          secondaryColor: const Color(0xFF73A598),
          backgroundColor: const Color(0xFFF1F8F5),
          textColor: const Color(0xFF2D4A3E),
          textSecondaryColor: const Color(0xFF5A8F7B),
          textMutedColor: const Color(0xFF8DB3A4),
          isDark: false,
        );
      case AppThemeType.warmGray:
        return _buildTheme(
          primaryColor: const Color(0xFF7D6B5D),
          secondaryColor: const Color(0xFF998577),
          backgroundColor: const Color(0xFFFAF7F5),
          textColor: const Color(0xFF3E352E),
          textSecondaryColor: const Color(0xFF7D6B5D),
          textMutedColor: const Color(0xFFB5A193),
          isDark: false,
        );
      case AppThemeType.minimalGray:
        return _buildTheme(
          primaryColor: const Color(0xFF4A5568),
          secondaryColor: const Color(0xFF718096),
          backgroundColor: const Color(0xFFF7FAFC),
          textColor: const Color(0xFF1A202C),
          textSecondaryColor: const Color(0xFF4A5568),
          textMutedColor: const Color(0xFFA0AEC0),
          isDark: false,
        );
      case AppThemeType.dark:
        return _buildTheme(
          primaryColor: const Color(0xFF8AB4F8),
          secondaryColor: const Color(0xFFA8C7FA),
          backgroundColor: const Color(0xFF121212),
          textColor: const Color(0xFFE8EAED),
          textSecondaryColor: const Color(0xFFBDC1C6),
          textMutedColor: const Color(0xFF9AA0A6),
          isDark: true,
        );
    }
  }

  /// テーマビルダー
  static ThemeData _buildTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color textColor,
    required Color textSecondaryColor,
    required Color textMutedColor,
    required bool isDark,
  }) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? const Color(0xFF3C4043) : const Color(0xFFE0E5E9);
    final errorCol = isDark ? darkErrorColor : errorColor;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorCol,
        surface: cardColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: cardColor,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorCol, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: TextStyle(color: textSecondaryColor),
        hintStyle: TextStyle(color: textMutedColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryColor.withOpacity(0.1),
        labelStyle: TextStyle(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 20,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: TextStyle(fontSize: 16, color: textColor),
        bodyMedium: TextStyle(fontSize: 14, color: textColor),
        bodySmall: TextStyle(fontSize: 12, color: textSecondaryColor),
        labelSmall: TextStyle(fontSize: 11, color: textMutedColor),
      ),
    );
  }

  /// グラデーションを取得
  static LinearGradient getGradient(AppThemeType type) {
    final theme = themes.firstWhere((t) => t.type == type);
    return LinearGradient(
      colors: [theme.previewColor1, theme.previewColor2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// 影
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> buttonShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
