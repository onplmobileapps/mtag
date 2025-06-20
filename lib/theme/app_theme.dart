import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData appTheme = ThemeData(tabBarTheme: TabBarThemeData(labelStyle: TextStyle(fontSize: 11,fontFamily: 'Poppins')),
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
  colorScheme: const ColorScheme.light(
      primary: Color(0xFF2C2E65),
      onPrimary: Colors.white,scrim: Colors.white,
      secondary: Colors.grey),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      fixedSize: const WidgetStatePropertyAll(
        Size(300, 35),
      ),
      maximumSize: const WidgetStatePropertyAll(
        Size(300, 35),
      ),
      minimumSize: const WidgetStatePropertyAll(
        Size(300, 35),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      backgroundColor: const WidgetStatePropertyAll(
        Color(0xFF2C2E65),
      ),
      foregroundColor: const WidgetStatePropertyAll(
        Colors.white,
      ),
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
      )),
  dialogTheme:  DialogThemeData(
    surfaceTintColor: Colors.white,
    backgroundColor: Colors.white,
    contentTextStyle:
        TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black),
    titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Colors.black),
  ),
  useMaterial3: true,
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: primarSwatch),
        ),
      ),
      foregroundColor: WidgetStatePropertyAll(primarSwatch),
      fixedSize: const WidgetStatePropertyAll(Size(90, 35)),
      maximumSize: const WidgetStatePropertyAll(Size(90, 35)),
      minimumSize: const WidgetStatePropertyAll(Size(90, 35)),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500, fontFamily: 'Poppins'),
      ),
    ),
  ),
  fontFamily: 'Poppins',
  disabledColor: const Color(0xfff5f5f5),
  datePickerTheme: const DatePickerThemeData(
    dayForegroundColor: WidgetStatePropertyAll(Colors.black),
    shape: RoundedRectangleBorder(),
    cancelButtonStyle: ButtonStyle(
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black),
      ),
    ),
    confirmButtonStyle: ButtonStyle(
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Colors.black,
        ),
      ),
    ),
    todayForegroundColor: WidgetStatePropertyAll(
      Colors.white,
    ),
    headerForegroundColor: Colors.white,
    todayBackgroundColor: WidgetStatePropertyAll(
      Color(0xFF2C2E65),
    ),
    headerHeadlineStyle: TextStyle(
      fontSize: 16,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w700,
    ),
    yearStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11,
    ),
    weekdayStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 11,
    ),
    dayStyle: TextStyle(
      fontSize: 11,
      fontFamily: 'Poppins',
    ),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    headerBackgroundColor: Color(0xFF2C2E65),
  ),
  listTileTheme: const ListTileThemeData(
    iconColor: Color(0xFF2C2E65),
    minLeadingWidth: 20,
    style: ListTileStyle.list,
    horizontalTitleGap: 0,
    minVerticalPadding: 0,
    titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        color: Colors.black),
    subtitleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w400,
      color: Colors.grey,
      fontSize: 8,
    ),
    leadingAndTrailingTextStyle:
        TextStyle(fontFamily: 'Poppins', color: Colors.black),
  ),
  inputDecorationTheme: InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        width: 0.3,
      ),
    ),
    focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
      width: 0.3,
    )),
    labelStyle: TextStyle(color: primarSwatch),
    hintStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 13,
      color: Colors.grey,
    ),
    contentPadding: const EdgeInsets.only(left: 4, top: 0, bottom: 0),
  ),
  expansionTileTheme: ExpansionTileThemeData(
    backgroundColor: Colors.white,
    collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
    collapsedTextColor: primarSwatch,
    tilePadding: EdgeInsets.zero,
    childrenPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
        side: BorderSide.none, borderRadius: BorderRadius.circular(0)),
    textColor: primarSwatch,
    expandedAlignment: Alignment.topLeft,
  ),
  focusColor: const Color(0XffEFF3F6),
  iconTheme: const IconThemeData(
    color: Color(0xFF2C2E65),
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    scrolledUnderElevation: 0.0,
    systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: primarSwatch,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light),
    iconTheme: const IconThemeData(color: Colors.white),
    backgroundColor: const Color(0xFF2C2E65),
    titleTextStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 18,
    ),
  ),
  primaryColor: primarSwatch,
  primarySwatch: primarSwatch,
  textTheme: TextTheme(
    displayLarge: TextStyle(
      fontSize: 18,
      color: primarSwatch,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    ),
    labelLarge: const TextStyle(
      fontSize: 15,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    labelMedium: const TextStyle(
      fontSize: 14,
      color: Color(0xFF2C2E65),
      fontFamily: 'Poppins',
    ),
    labelSmall: const TextStyle(
      fontSize: 10,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    displayMedium: TextStyle(
      fontSize: 15,
      color: primarSwatch,
      overflow: TextOverflow.ellipsis,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
    ),
    displaySmall: const TextStyle(
      fontSize: 11,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    titleLarge: const TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    titleMedium: const TextStyle(
      fontSize: 16,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    titleSmall: const TextStyle(
      fontSize: 11,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
    bodyLarge: const TextStyle(
      fontSize: 18,
      color: Colors.black,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: const TextStyle(
      fontSize: 15,
      color: Color(0xFF2C2E65),
      fontFamily: 'Poppins',
    ),
    bodySmall: const TextStyle(
      fontSize: 10,
      color: Colors.black,
      fontFamily: 'Poppins',
    ),
  ),
  chipTheme: const ChipThemeData(
    labelStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  bannerTheme: const MaterialBannerThemeData(
    padding: EdgeInsets.zero,
    leadingPadding: EdgeInsets.zero,
  ),
  brightness: Brightness.dark,
  hintColor: Colors.grey,
  dividerTheme: const DividerThemeData(color: Colors.white),
  dividerColor: Colors.white70,
  dialogTheme: const DialogThemeData(
    backgroundColor: Colors.black,
    contentTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontFamily: 'Poppins',
    ),
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      color: Colors.white,
      fontSize: 16,
    ),
  ),
  datePickerTheme: const DatePickerThemeData(
      dayForegroundColor: WidgetStatePropertyAll(Colors.black)),
  outlinedButtonTheme: const OutlinedButtonThemeData(),
  primaryColorDark: Colors.black,
  primaryColorLight: Colors.white,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      fixedSize: const WidgetStatePropertyAll(
        Size(300, 35),
      ),
      maximumSize: const WidgetStatePropertyAll(
        Size(300, 35),
      ),
      minimumSize: const WidgetStatePropertyAll(
        Size(300, 35),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      backgroundColor: const WidgetStatePropertyAll(
        Color(0xff000000),
      ),
      foregroundColor: const WidgetStatePropertyAll(
        Colors.white,
      ),
    ),
  ),
  useMaterial3: true,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  listTileTheme: ListTileThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    textColor: Colors.white,
    iconColor: Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), side: BorderSide.none),
    titleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        color: Colors.white),
    subtitleTextStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
        color: Colors.white),
    leadingAndTrailingTextStyle:
        const TextStyle(fontFamily: 'Poppins', color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 0.3,
          color: Colors.white,
        ),
      ),
      disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 0.3, color: Colors.white)),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(width: 0.3, color: Colors.white),
      ),
      
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Colors.white,
      ),
      contentPadding: EdgeInsets.only(left: 8, top: 0, bottom: 0)),
  expansionTileTheme: ExpansionTileThemeData(
      collapsedTextColor: primarSwatchDark,
      tilePadding: EdgeInsets.zero,
      textColor: Colors.white,
      expandedAlignment: Alignment.topLeft),
  focusColor: const Color(0XffEFF3F6),
  iconTheme: const IconThemeData(color: Colors.white),
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light),
    iconTheme: const IconThemeData(color: Colors.white),
    backgroundColor: primarSwatch,
    titleTextStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 18,
    ),
  ),
  
  chipTheme: const ChipThemeData(
    brightness: Brightness.dark,
    disabledColor: Colors.black,
    backgroundColor: Colors.black,
    surfaceTintColor: Colors.black,
    labelStyle: TextStyle(color: Colors.white),
  ),
  bottomNavigationBarTheme:
      BottomNavigationBarThemeData(backgroundColor: primarSwatch),
  disabledColor: const Color(0xff212121),
  floatingActionButtonTheme:
      const FloatingActionButtonThemeData(backgroundColor: Colors.white),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xff212121),
    surfaceTintColor: Color(0xff212121),
    modalBackgroundColor: Color(0xff212121),
  ),
  colorScheme: ColorScheme.dark(
      surface: Colors.black,
      onPrimary: Colors.white,
      primary: Colors.white,
      secondary: Colors.grey),
  primaryColor: const Color(0xff212121),
  primarySwatch: primarSwatchDark,
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 18,
      color: Colors.white,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
    ),
    displayMedium:
        TextStyle(fontSize: 13, color: Colors.white, fontFamily: 'Poppins'),
    displaySmall:
        TextStyle(fontSize: 11, color: Colors.white, fontFamily: 'Poppins'),
    titleLarge:
        TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Poppins'),
    titleMedium:
        TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Poppins'),
    titleSmall:
        TextStyle(fontSize: 11, color: Colors.black, fontFamily: 'Poppins'),
    bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500),
    bodyMedium:
        TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'Poppins'),
    bodySmall:
        TextStyle(fontSize: 11, color: Colors.white, fontFamily: 'Poppins'),
  ), tabBarTheme: TabBarThemeData(indicatorColor: Colors.white),
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
  900: Color(0xFF2C2E65)
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
  900: Color(0xff000000)
});
