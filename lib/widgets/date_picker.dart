import 'package:flutter/material.dart';

Future<DateTime?> showDatePickerDialog(BuildContext context) async {
  return showDatePicker(
    context: context,
    initialDatePickerMode: DatePickerMode.day,
    currentDate: DateTime.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.indigo.shade900, // Header color
            onPrimary: Colors.white, // Text color in header buttons
            surface: Colors.white, // Background color of the calendar
            onSurface: Colors.black, // Default text color in the calendar
          ), // Background of the dialog
          textTheme: const TextTheme(
            headlineSmall: TextStyle(color: Colors.indigo), // Header title text style
          ),
          datePickerTheme: DatePickerThemeData(
            headerForegroundColor: Colors.indigo, // Color for header text
            headerBackgroundColor: Colors.white, // Header background
            yearStyle: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
            headerHelpStyle: TextStyle(color: Colors.indigo.shade600),
            yearBackgroundColor: WidgetStateProperty.all(Colors.white),
            yearForegroundColor: WidgetStateProperty.all(Colors.indigo),
            todayForegroundColor: WidgetStateProperty.all(Colors.white),
            todayBackgroundColor: WidgetStateProperty.all(Colors.indigo),
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white; // Text color for selected day
              }
              return Colors.black; // Default day text color
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.indigo; // Background color for selected day
              }
              return null; // Default (transparent) background
            }),
          ),
          iconTheme: IconThemeData(
            color: Colors.indigo.shade900, // Arrow icon color
          ), dialogTheme: DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child!,
      );
    },
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    firstDate: DateTime(2000, 1, 1),
    lastDate: DateTime.now(),
    initialDate: DateTime.now(),
    anchorPoint: Offset.fromDirection(2, 5),
    helpText: '',
  );
}
