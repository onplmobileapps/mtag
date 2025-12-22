import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/notification/controller/notificationcontroller.dart';
import '../../widgets/notification_card_widget.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.isSelectAll = false;
        controller.selectedIds.clear();
        controller.isSelectionMode(false);
      },
      child: Scaffold(
   
        appBar: AppBar(
          elevation: 0,centerTitle: true,
          title: const Text("Notifications"),
          actions: [
            Obx(
              () => Visibility(
                visible: controller.isSelectionMode.value,
                child: InkWell(
                  onTap: controller.selectedIds.isNotEmpty
                      ? () async {
                          log('Deleting IDs: ${controller.selectedIds}');
                          await controller.deleteNotifications(
                              notificationId: controller.selectedIds.toList());
                          controller.notificationModel.refresh();
                        }
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.delete_outline),
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: controller.isSelectionMode.value,
                child: InkWell(
                  onTap: () {
                    controller.selectAll();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      controller.isSelectAll
                          ? Icons.deselect
                          : Icons.select_all_outlined,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          constraints: const BoxConstraints.expand(),
          height: size.height,
          width: size.width,
          color: Theme.of(context).primaryColor,
          child: Container(
            height: size.height,
            width: size.width,
         
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: NotificationCard(),
            ),
          ),
        ),
      ),
    );
  }
}
