import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/notification/controller/notificationcontroller.dart';
import '../../widgets/notification_card_widget.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar:AppBar(
  elevation: 0,
  title: const Text("Notifications"),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 8.0), // Add padding if needed
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (v) {},
          ),
          Text(
            'Mark All',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ),
  ],
)
,
      body: Container(
        constraints: const BoxConstraints.expand(),
        height: size.height,
        width: size.width,
        color: Theme.of(context).primaryColor,
        child: Container(
          height: size.height,
          width: size.width,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: NotificationCard(),
          ),
        ),
      ),
    );
  }
}
