import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/utils.dart';
import 'model/notification_model.dart';

class NotificationsExpandScreen extends StatelessWidget {
  NotificationsExpandScreen({super.key});
  final Data expandData = Get.arguments ?? Data();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Notification Details"),centerTitle: true,
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
                
                const SizedBox(height: 16),
                Container(padding: EdgeInsets.all(10),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).primaryColor),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        expandData.title ?? '',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration:
                            BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).focusColor),
                        child: Column(mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expandData.body ?? '',
                              textDirection: TextDirection.ltr,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            Align(alignment: Alignment.bottomRight,
                              child: Text(formatDateTime(expandData.dateTime??''),style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black),))
                          ],
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
