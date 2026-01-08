import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final String fontFamily = 'biotifbold';
ThemeData appTheme = ThemeData(
  extensions: [
    AppShadows(
      cardShadow: [
        BoxShadow(color: Colors.grey.shade200, offset: Offset(0, 4)),
        BoxShadow(color: Colors.grey.shade200, offset: Offset(4, 1)),
        BoxShadow(color: Colors.grey.shade200, offset: Offset(1, 2)),
        BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 1)),
      ],
    ),
    const AppGradients(
      gridWidget: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFCFC), Color(0xFFD9EDF8), Color(0xFFE4EBF5)],
      ),
      // App / Screen background
      background: LinearGradient(
        begin: .topLeft,
        end: AlignmentGeometry.centerRight,
        colors: [Color(0xFFE4EDFC), Color(0xFFFCFCFC), Color(0xFFEAEBFD)],
      ),

      // Scroll / list fade
      verticalFade: LinearGradient(
        end: AlignmentGeometry.xy(0, 3),
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFCFCFC),
          Color(0xFFF8F6FF),
          Color(0xFFD9E5FF),
          Color(0xFFE6EBFF),
          Color(0xFFE6EBFF),
          Color(0xFFE6EBFF),
          Color(0xFFE6EBFF),
          Color(0xFFE6EBFF),
        ],
      ),

      // Card / tile gradient
      card: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF4F6FF)],
      ),

      // Header / AppBar / Hero section
      header: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE6EBFF), Color(0xFFFFFFFF)],
      ),
    ),
  ],

  tabBarTheme: TabBarThemeData(
    labelStyle: TextStyle(fontSize: 11, fontFamily: fontFamily),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(builders: {}), //add later
  brightness: Brightness.light,
  bannerTheme: const MaterialBannerThemeData(
    padding: EdgeInsets.zero,
    leadingPadding: EdgeInsets.zero,
  ),
  hintColor: Colors.grey,
  highlightColor: const Color(0xFF2C2E65),
  dividerColor: Colors.black54,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: ColorScheme.light(
    primary: Color(0xFF2C2E65),
    onPrimary: Colors.white,
    scrim: Colors.white,
    surface: Colors.white,
    secondary: Colors.grey,
    surfaceContainer: Color(0xff21295E),
    surfaceContainerLowest: Color(0xffE1E1E1),
    surfaceContainerLow: Colors.grey.shade100,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      fixedSize: const WidgetStatePropertyAll(Size(300, 35)),
      maximumSize: const WidgetStatePropertyAll(Size(300, 35)),
      minimumSize: const WidgetStatePropertyAll(Size(300, 35)),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: fontFamily, fontSize: 12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF2C2E65)),
      foregroundColor: const WidgetStatePropertyAll(Colors.white),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
  ),
  dialogTheme: DialogThemeData(
    surfaceTintColor: Colors.white,
    backgroundColor: Colors.white,
    contentTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 13,
      color: Colors.black,
    ),
    titleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
  useMaterial3: true,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: primarSwatch),
        ),
      ),
      foregroundColor: WidgetStatePropertyAll(primarSwatch),
      fixedSize: const WidgetStatePropertyAll(Size(90, 35)),
      maximumSize: const WidgetStatePropertyAll(Size(90, 35)),
      minimumSize: const WidgetStatePropertyAll(Size(90, 35)),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: fontFamily,
        ),
      ),
    ),
  ),
  fontFamily: fontFamily,
  disabledColor: const Color(0xfff5f5f5),
  datePickerTheme: DatePickerThemeData(
    dayForegroundColor: WidgetStatePropertyAll(Colors.black),
    shape: RoundedRectangleBorder(),
    cancelButtonStyle: ButtonStyle(
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: fontFamily, fontSize: 13, color: Colors.black),
      ),
    ),
    confirmButtonStyle: ButtonStyle(
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: fontFamily, fontSize: 13, color: Colors.black),
      ),
    ),
    todayForegroundColor: WidgetStatePropertyAll(Colors.white),
    headerForegroundColor: Colors.white,
    todayBackgroundColor: WidgetStatePropertyAll(Color(0xFF2C2E65)),
    headerHeadlineStyle: TextStyle(
      fontSize: 16,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
    ),
    yearStyle: TextStyle(fontFamily: fontFamily, fontSize: 11),
    weekdayStyle: TextStyle(fontFamily: fontFamily, fontSize: 11),
    dayStyle: TextStyle(fontSize: 11, fontFamily: fontFamily),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    headerBackgroundColor: Color(0xFF2C2E65),
  ),
  listTileTheme: ListTileThemeData(
    iconColor: Color(0xFF2C2E65),
    minLeadingWidth: 20,
    style: ListTileStyle.list,
    horizontalTitleGap: 0,
    minVerticalPadding: 0,
    titleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    ),
    subtitleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      color: Colors.grey,
      fontSize: 8,
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontFamily: fontFamily,
      color: Colors.black,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    hintStyle: TextStyle(
      color: const Color(0x993C3C43),
      fontSize: 12,
      fontFamily: fontFamily,
      height: 1.0,
      letterSpacing: -0.14,
    ),

    filled: true,
    fillColor: const Color(0xFFFFFFFF),
    isDense: false,
    isCollapsed: false, // Minimal height but affects label/error placement
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Color(0x33000000), width: 0.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Color(0x33000000), width: 0.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Color(0x33000000), width: 0.0),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
      borderSide: const BorderSide(color: Color(0x33000000), width: 0.0),
    ),
    contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
    labelStyle: TextStyle(height: 1),
    errorStyle: const TextStyle(fontSize: 10, height: 1.0),
    floatingLabelBehavior: FloatingLabelBehavior.never,
  ),

  expansionTileTheme: ExpansionTileThemeData(
    backgroundColor: Colors.white,
    collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
    collapsedTextColor: primarSwatch,
    tilePadding: EdgeInsets.zero,
    childrenPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      side: BorderSide.none,
      borderRadius: BorderRadius.circular(0),
    ),
    textColor: primarSwatch,
    expandedAlignment: Alignment.topLeft,
  ),
  focusColor: const Color(0XffEFF3F6),
  iconTheme: const IconThemeData(color: Color(0xFF2C2E65)),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    scrolledUnderElevation: 0.0,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: primarSwatch,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    backgroundColor: const Color(0xFF2C2E65),
    titleTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 18),
  ),
  primaryColor: primarSwatch,
  primarySwatch: primarSwatch,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 37,
      color: Colors.black87,
      fontFamily: fontFamily,
      fontWeight: .w600,
    ),
    displayLarge: TextStyle(
      fontSize: 18,
      color: primarSwatch,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      color: Colors.black,
      fontFamily: fontFamily,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF2C2E65),
      fontFamily: fontFamily,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      color: Colors.black,
      fontFamily: fontFamily,
    ),
    displayMedium: TextStyle(
      fontSize: 14,
      color: primarSwatch,
      overflow: TextOverflow.ellipsis,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
    ),
    displaySmall: TextStyle(
      fontSize: 11,
      color: Colors.black,
      fontFamily: fontFamily,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontFamily: fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      color: Colors.black54.withValues(alpha: 0.7),
      fontFamily: fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 11,
      color: Colors.black,
      fontFamily: fontFamily,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Color(0xFF2C2E65),
      fontFamily: fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 10,
      color: Colors.black,
      fontFamily: fontFamily,
    ),
  ),
  chipTheme: ChipThemeData(
    labelStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
);

ThemeData darkTheme = ThemeData(dropdownMenuTheme: DropdownMenuThemeData(
    disabledColor: Colors.grey[850], // dropdown menu background
   menuStyle: MenuStyle(surfaceTintColor: WidgetStatePropertyAll(Colors.black)),
    textStyle: TextStyle(
      color: Colors.black, // text color for items
      fontSize: 14,
    ),
    inputDecorationTheme: InputDecorationTheme(contentPadding: .zero,
      filled: true,
      fillColor: Colors.grey[850], // optional
    ),
  ),
  extensions: [
    AppShadows(
      cardShadow: [
        BoxShadow(color: Colors.grey.shade800, offset: Offset(0, 0)),
        BoxShadow(color: Colors.grey.shade800, offset: Offset(0, 0)),
        BoxShadow(color: Colors.grey.shade800, offset: Offset(0, 0)),
        BoxShadow(color: Colors.grey.shade800, offset: Offset(0, 0)),
      ],
    ),
    const AppGradients(
      gridWidget: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2B2F3C), Color(0xFF353944), Color(0xFF404555)],
      ),

      background: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E2433), Color(0xFF121212), Color(0xFF232A44)],
      ),

      // Scroll / list fade
      verticalFade: LinearGradient(
        end: AlignmentGeometry.xy(0, 3),
        colors: [
          Color(0xFF121212),
          Color(0xFF161616),
          Color(0xFF1C1F2B),
          Color(0xFF24314A),
          Color(0xFF2B3552),
          Color(0xFF2B3552),
          Color(0xFF2B3552),
          Color(0xFF2B3552),
          Color(0xFF2B3552),
        ],
      ),

      // Card / tile gradient
      card: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1C28), Color(0xFF242634)],
      ),

      // Header / AppBar / Hero section
      header: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2B3552), Color(0xFF1E2433)],
      ),
    ),
  ],

  bannerTheme: const MaterialBannerThemeData(
    padding: EdgeInsets.zero,
    leadingPadding: EdgeInsets.zero,
  ),
  brightness: Brightness.dark,
  hintColor: Colors.grey,
  dividerTheme: const DividerThemeData(color: Colors.white),
  dividerColor: Colors.white70,
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.black,
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: fontFamily,
    ),
    titleTextStyle: TextStyle(
      fontFamily: fontFamily,
      color: Colors.white,
      fontSize: 16,
    ),
  ),
  datePickerTheme: const DatePickerThemeData(
    dayForegroundColor: WidgetStatePropertyAll(Colors.black),
  ),
  outlinedButtonTheme: const OutlinedButtonThemeData(),
  primaryColorDark: Colors.black,
  primaryColorLight: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      fixedSize: const WidgetStatePropertyAll(Size(300, 35)),
      maximumSize: const WidgetStatePropertyAll(Size(300, 35)),
      minimumSize: const WidgetStatePropertyAll(Size(300, 35)),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: fontFamily, fontSize: 12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      backgroundColor: const WidgetStatePropertyAll(Color(0xFF2C2C2C)),
      foregroundColor: const WidgetStatePropertyAll(Colors.white),
    ),
  ),
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  listTileTheme: ListTileThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textColor: Colors.white,
    iconColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide.none,
    ),
    titleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      fontSize: 16,
    ),
    subtitleTextStyle: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontFamily: fontFamily,
      color: Colors.white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2C2C2C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),

    labelStyle: TextStyle(color: Colors.white),
    hintStyle: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      color: Colors.white,
    ),
    contentPadding: EdgeInsets.only(left: 8, top: 0, bottom: 10),
  ),
  expansionTileTheme: ExpansionTileThemeData(
    collapsedTextColor: primarSwatchDark,
    tilePadding: EdgeInsets.zero,
    textColor: Colors.white,
    expandedAlignment: Alignment.topLeft,
  ),
  focusColor: const Color(0XffEFF3F6),
  iconTheme: const IconThemeData(color: Colors.white),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    backgroundColor: Colors.black,
    titleTextStyle: TextStyle(fontFamily: fontFamily, fontSize: 18),
  ),

  chipTheme: const ChipThemeData(
    brightness: Brightness.dark,
    disabledColor: Colors.black,
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.black,
    labelStyle: TextStyle(color: Colors.white),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: primarSwatch,
  ),
  disabledColor: const Color(0xff212121),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.white,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xff212121),
    surfaceTintColor: Color(0xff212121),
    modalBackgroundColor: Color(0xff212121),
  ),
  colorScheme: ColorScheme.dark(
    surface: Colors.black,
    onPrimary: Colors.white,
    primary: Colors.white,
    secondary: Colors.grey,
    surfaceContainerLowest: Color(0xFF2C2C2C),
  ),
  primaryColor: const Color(0xff212121),
  primarySwatch: primarSwatchDark,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 38,
      fontFamily: fontFamily,
      fontWeight: .w600,
    ),
    displayLarge: TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    ),
    displayMedium: TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontFamily: fontFamily,
    ),
    displaySmall: TextStyle(
      fontSize: 11,
      color: Colors.white,
      fontFamily: fontFamily,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontFamily: fontFamily,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      color: Colors.white,
      fontFamily: fontFamily,
    ),
    titleSmall: TextStyle(
      fontSize: 11,
      color: Colors.white,
      fontFamily: fontFamily,
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: Colors.white,
      fontFamily: fontFamily,
    ),
    bodySmall: TextStyle(
      fontSize: 11,
      color: Colors.white,
      fontFamily: fontFamily,
    ),
  ),
  tabBarTheme: TabBarThemeData(indicatorColor: Colors.white),
);
MaterialColor primarSwatch = const MaterialColor(0xFF2C2E65, {
  50: Color(0xFF2C2E65),
  100: Color(0xFF2C2E65),
  200: Color(0xFF2C2E65),
  300: Color(0xFF2C2E65),
  400: Color(0xFF2C2E65),
  500: Color(0xFF2C2E65),
  600: Color(0xFF2C2E65),
  700: Color(0xFF2C2E65),
  800: Color(0xFF2C2E65),
  900: Color(0xFF2C2E65),
});
MaterialColor primarSwatchDark = const MaterialColor(0xff000000, {
  50: Color(0xff000000),
  100: Color(0xff000000),
  200: Color(0xff000000),
  300: Color(0xff000000),
  400: Color(0xff000000),
  500: Color(0xff000000),
  600: Color(0xff000000),
  700: Color(0xff000000),
  800: Color(0xff000000),
  900: Color(0xff000000),
});

@immutable
class AppGradients extends ThemeExtension<AppGradients> {
  final LinearGradient background;
  final LinearGradient verticalFade;
  final LinearGradient card;
  final LinearGradient header;
  final LinearGradient gridWidget;
  const AppGradients({
    required this.background,
    required this.verticalFade,
    required this.card,
    required this.header,
    required this.gridWidget,
  });

  @override
  AppGradients copyWith({
    LinearGradient? background,
    LinearGradient? verticalFade,
    LinearGradient? card,
    LinearGradient? header,
    LinearGradient? gridWidget,
  }) {
    return AppGradients(
      background: background ?? this.background,
      verticalFade: verticalFade ?? this.verticalFade,
      card: card ?? this.card,
      header: header ?? this.header,
      gridWidget: gridWidget ?? this.gridWidget,
    );
  }

  @override
  AppGradients lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;

    return AppGradients(
      background: LinearGradient.lerp(background, other.background, t)!,
      verticalFade: LinearGradient.lerp(verticalFade, other.verticalFade, t)!,
      card: LinearGradient.lerp(card, other.card, t)!,
      header: LinearGradient.lerp(header, other.header, t)!,
      gridWidget: LinearGradient.lerp(gridWidget, other.gridWidget, t)!,
    );
  }
}

class AppShadows extends ThemeExtension<AppShadows> {
  final List<BoxShadow> cardShadow;

  AppShadows({required this.cardShadow});

  @override
  AppShadows copyWith({List<BoxShadow>? cardShadow}) {
    return AppShadows(cardShadow: cardShadow ?? this.cardShadow);
  }

  @override
  AppShadows lerp(ThemeExtension<AppShadows>? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      cardShadow: List.generate(
        cardShadow.length,
        (i) => BoxShadow.lerp(cardShadow[i], other.cardShadow[i], t)!,
      ),
    );
  }
}
