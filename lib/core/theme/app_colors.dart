// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryOrange = Color(0xffE9762B);
  static const Color primaryOrangeHover = Color(0xFFE67E00);
  static const Color primaryOrangeActive = Color(0xFFCC6600);
  static const Color primaryOrangeLight = Color(0xFFFFE4CC);
  static const Color primaryOrangeLighter = Color(0xFFFFF0E6);

  // Secondary Colors (Navy)
  static const Color deepNavy = Color(0xFF0F1B3C);
  static const Color navyAccent = Color(0xFF1A2F5C);
  static const Color navyLight = Color(0xFFE8EDF7);

  // Tertiary Accents
  static const Color tealSuccess = Color(0xFF48cfcb);
  static const Color emerald = Color(0xFF48cfcb);
  static const Color warmRed = Color(0xFFE74C3C);
  static const Color softAmber = Color(0xFFF39C12);

  // Neutral/Grayscale
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFCCCCCC);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundNeutral = Color(0xFFF8F9FB);
  static const Color backgroundDarkNeutral = Color(0xFFF0F2F5);

  // Semantic Colors
  static const Color success = tealSuccess;
  static const Color warning = softAmber;
  static const Color error = warmRed;
  static const Color info = Color(0xFF3498DB);
  static const Color disabled = Color(0xFFBDBDBD);

  // Add these to lib/core/theme/app_colors.dart

  // ==================== ADD TO AppColors CLASS ====================

  // Background colors
  static const Color background = Color(0xFFF5F7FA); // Light gray background

  // Divider
  static const Color divider = Color(0xFFE5E7EB);

  // Success (alias for consistency)
  static const Color successGreen = Color(0xFF10B981);

  // Opacity utilities
  static Color withOpacityFromHex(String hexColor, double opacity) {
    final buffer = StringBuffer();
    if (!hexColor.startsWith('#')) buffer.write('#');
    buffer.write(hexColor);
    return Color(
      int.parse(buffer.toString().replaceFirst('#', '0xff')),
    ).withAlpha((255 * opacity).toInt());
  }
}

// lib/core/theme/app_text_theme.dart

class AppTextTheme {
  static const String fontFamily = 'Inter';

  static const TextStyle display = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 56 / 48,
    letterSpacing: -0.02,
    fontFamily: fontFamily,
  );
  // Add these to lib/core/theme/app_text_theme.dart

  // ==================== ADD TO AppTextTheme CLASS ====================

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.01,
    fontFamily: fontFamily,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    letterSpacing: 0,
    fontFamily: fontFamily,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.02,
    fontFamily: fontFamily,
  );

  static const TextStyle micro = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    letterSpacing: 0.02,
    fontFamily: fontFamily,
  );

  // Compose text styles for common use cases
  static TextStyle heading1WithColor(Color color) =>
      heading1.copyWith(color: color);

  static TextStyle heading2WithColor(Color color) =>
      heading2.copyWith(color: color);

  static TextStyle bodyLargeWithColor(Color color) =>
      bodyLarge.copyWith(color: color);

  static TextStyle bodyRegularWithColor(Color color) =>
      bodyRegular.copyWith(color: color);
}

// lib/core/theme/app_spacing.dart

class AppSpacing {
  // Base unit: 8px
  static const double xs0 = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double smPlus = 12;
  static const double md = 16;
  static const double mdPlus = 20;
  static const double lg = 24;
  static const double lgPlus = 32;
  static const double xl = 40;
  static const double xlPlus = 48;
  static const double xxl = 56;
  static const double xxlPlus = 64;

  // Common combinations
  static const EdgeInsets paddingComponent = EdgeInsets.all(md);
  static const EdgeInsets paddingCard = EdgeInsets.all(mdPlus);
  static const EdgeInsets paddingCardLarge = EdgeInsets.all(lg);
  static const EdgeInsets marginSection = EdgeInsets.all(lg);
  static const EdgeInsets marginPage = EdgeInsets.all(lgPlus);

  // Horizontal/Vertical helpers
  static EdgeInsets horizontalPadding(double value) =>
      EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets verticalPadding(double value) =>
      EdgeInsets.symmetric(vertical: value);
}

// lib/core/theme/app_border_radius.dart

class AppBorderRadius {
  static const double none = 0;
  static const double minimal = 2;
  static const double small = 6;
  static const double medium = 8;
  static const double large = 12;
  static const double xl = 16;
  static const double full = 9999;

  // BorderRadius objects for direct use
  static const BorderRadius noneRadius = BorderRadius.all(
    Radius.circular(none),
  );
  static const BorderRadius minimalRadius = BorderRadius.all(
    Radius.circular(minimal),
  );
  static const BorderRadius smallRadius = BorderRadius.all(
    Radius.circular(small),
  );
  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius largeRadius = BorderRadius.all(
    Radius.circular(large),
  );
  static const BorderRadius xlRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullRadius = BorderRadius.all(
    Radius.circular(full),
  );

  // Common shapes
  static const RoundedRectangleBorder buttonBorder = RoundedRectangleBorder(
    borderRadius: mediumRadius,
  );
  static const RoundedRectangleBorder cardBorder = RoundedRectangleBorder(
    borderRadius: mediumRadius,
  );
  static const RoundedRectangleBorder modalBorder = RoundedRectangleBorder(
    borderRadius: largeRadius,
  );
}

// lib/core/theme/app_shadows.dart

class AppShadows {
  // Elevation 0 - Flat (no shadow)
  static const List<BoxShadow> elevation0 = [];

  // Elevation 1 - Subtle (Cards)
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      color: Color.fromRGBO(0, 0, 0, 0.05),
    ),
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color.fromRGBO(0, 0, 0, 0.08),
    ),
  ];

  // Elevation 2 - Cards, Chips
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      color: Color.fromRGBO(0, 0, 0, 0.06),
    ),
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8,
      color: Color.fromRGBO(0, 0, 0, 0.10),
    ),
  ];

  // Elevation 3 - Floating UI
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8,
      color: Color.fromRGBO(0, 0, 0, 0.08),
    ),
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 16,
      color: Color.fromRGBO(0, 0, 0, 0.12),
    ),
  ];

  // Elevation 4 - Modals, Dropdowns
  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 16,
      color: Color.fromRGBO(0, 0, 0, 0.10),
    ),
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 24,
      color: Color.fromRGBO(0, 0, 0, 0.15),
    ),
  ];

  // Elevation 5 - Premium Overlays
  static const List<BoxShadow> elevation5 = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 32,
      color: Color.fromRGBO(0, 0, 0, 0.15),
    ),
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 48,
      color: Color.fromRGBO(0, 0, 0, 0.20),
    ),
  ];
}

// lib/core/theme/app_theme.dart

ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: AppTextTheme.fontFamily,

  // Color scheme
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryOrange,
    secondary: AppColors.deepNavy,
    tertiary: AppColors.tealSuccess,
    surface: AppColors.backgroundWhite,
    surfaceContainer: AppColors.backgroundNeutral,
    error: AppColors.warmRed,
    background: AppColors.backgroundNeutral,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onBackground: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
    brightness: Brightness.light,
  ),

  // Text theme
  textTheme: TextTheme(
    displayLarge: AppTextTheme.display.copyWith(color: AppColors.textPrimary),
    headlineSmall: AppTextTheme.heading1.copyWith(color: AppColors.textPrimary),
    headlineMedium: AppTextTheme.heading2.copyWith(
      color: AppColors.textPrimary,
    ),

    bodyLarge: AppTextTheme.bodyLarge.copyWith(color: AppColors.textPrimary),
    bodyMedium: AppTextTheme.bodyRegular.copyWith(color: AppColors.textPrimary),
    bodySmall: AppTextTheme.bodySmall.copyWith(color: AppColors.textSecondary),
    labelLarge: AppTextTheme.caption.copyWith(color: AppColors.textPrimary),
    labelSmall: AppTextTheme.micro.copyWith(color: AppColors.textSecondary),
  ),

  // Elevated button
  elevatedButtonTheme: ElevatedButtonThemeData(
    style:
        ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.mediumRadius,
          ),
          elevation: 2,
          textStyle: AppTextTheme.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          // Hover state
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) return 3;
            if (states.contains(MaterialState.pressed)) return 4;
            return 2;
          }),
          // Disabled state
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled))
              return AppColors.disabled;
            return AppColors.primaryOrange;
          }),
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled))
              return AppColors.textTertiary;
            return Colors.white;
          }),
        ),
  ),

  // Outlined button
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryOrange,
      minimumSize: const Size(double.infinity, 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.mediumRadius),
      side: const BorderSide(color: AppColors.primaryOrange, width: 1),
      textStyle: AppTextTheme.bodyLarge.copyWith(
        color: AppColors.primaryOrange,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Text button
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryOrange,
      minimumSize: const Size(double.infinity, 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      textStyle: AppTextTheme.bodyLarge.copyWith(
        color: AppColors.primaryOrange,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),

  // Input decoration theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.backgroundWhite,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    border: OutlineInputBorder(
      borderRadius: AppBorderRadius.smallRadius,
      borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppBorderRadius.smallRadius,
      borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppBorderRadius.smallRadius,
      borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppBorderRadius.smallRadius,
      borderSide: const BorderSide(color: AppColors.warmRed, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppBorderRadius.smallRadius,
      borderSide: const BorderSide(color: AppColors.warmRed, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: AppBorderRadius.smallRadius,
      borderSide: const BorderSide(color: AppColors.borderMedium, width: 1),
    ),
    hintStyle: AppTextTheme.bodyRegular.copyWith(
      color: AppColors.textTertiary.withAlpha(180),
    ),
    labelStyle: AppTextTheme.bodyRegular.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
    ),
    helperStyle: AppTextTheme.bodySmall.copyWith(
      color: AppColors.textSecondary,
    ),
    errorStyle: AppTextTheme.bodySmall.copyWith(color: AppColors.warmRed),
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: AppColors.backgroundWhite,
    shadowColor: Colors.black.withAlpha(26),
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: AppBorderRadius.mediumRadius,
      side: const BorderSide(color: AppColors.borderLight, width: 1),
    ),
    margin: EdgeInsets.zero,
  ),

  // Dialog theme
  dialogTheme: DialogThemeData(
    backgroundColor: AppColors.backgroundWhite,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.largeRadius),
  ),

  // App bar theme
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.backgroundWhite,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextTheme.heading2.copyWith(
      color: AppColors.textPrimary,
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
  ),

  // Bottom navigation bar theme
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.backgroundWhite,
    selectedItemColor: AppColors.primaryOrange,
    unselectedItemColor: AppColors.textSecondary,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),

  // Chip theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.navyLight,
    selectedColor: AppColors.primaryOrange,
    secondarySelectedColor: AppColors.tealSuccess,
    disabledColor: AppColors.disabled.withAlpha(128),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    labelStyle: AppTextTheme.bodySmall.copyWith(color: AppColors.textPrimary),
    secondaryLabelStyle: AppTextTheme.bodySmall.copyWith(
      color: AppColors.backgroundWhite,
    ),
    brightness: Brightness.light,
    shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.fullRadius),
  ),

  // Divider theme
  dividerTheme: DividerThemeData(
    color: AppColors.borderLight,
    thickness: 1,
    space: AppSpacing.lg,
  ),

  // Progress indicator theme
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColors.primaryOrange,

    linearMinHeight: 4,
  ),
);

// Dark theme variant (future implementation)
ThemeData appThemeDark = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: AppTextTheme.fontFamily,
  // Configure dark theme colors and styles similarly
);
