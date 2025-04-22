import 'dart:io';
import 'package:flutter/material.dart';

void showExitDialog(BuildContext context) {
  showDialog( barrierDismissible: false,
    useRootNavigator: false,
    context: context,
    builder: (BuildContext context) {
      return PopScope(onPopInvokedWithResult: (didPop, result) {
        
      },canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  "Exit Application",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to exit the app?",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Future.delayed(const Duration(milliseconds: 300), () {
                            // Exit the app programmatically
                            Future.delayed(const Duration(milliseconds: 200), () {
                             exit(0);
                            });
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text("Exit"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}