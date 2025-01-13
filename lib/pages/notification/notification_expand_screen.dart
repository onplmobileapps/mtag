import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'model/notification_model.dart';

class NotificationsExpandScreen extends StatelessWidget {
  NotificationsExpandScreen({super.key});
  final Data expandData = Get.arguments ?? Data();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Notification Details"),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    expandData.dateTime ?? '',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).primaryColor),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        expandData.title ?? '',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).focusColor),
                        child: Text(
                          expandData.body ?? '',
                          textDirection: TextDirection.ltr,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.normal,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
