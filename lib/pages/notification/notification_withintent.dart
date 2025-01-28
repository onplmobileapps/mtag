import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/utils/utils.dart';


import 'model/notification_model.dart';

class NotificationWithintent extends StatelessWidget {
  NotificationWithintent({super.key});
  final Data expandData = Get.arguments ?? Data();

  @override
  Widget build(BuildContext context) {
    log(expandData.dateTime.toString());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Notification"),
        centerTitle: true,
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
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).primaryColor),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        expandData.title ?? '',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).focusColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expandData.body ?? '',
                              textDirection: TextDirection.ltr,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                            Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  formatDateTime(expandData.dateTime ?? ''),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.black),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 100, 
                    child: FloatingActionButton.extended(
                      elevation: 0,
                      backgroundColor: Colors.red.shade800,
                      onPressed: () {
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else if (Platform.isIOS) {
                          exit(0);
                        }
                      },
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Close",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16, // Adjust font size as needed
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}