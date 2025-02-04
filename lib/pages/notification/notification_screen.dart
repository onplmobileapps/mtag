import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../pages/notification/controller/notificationcontroller.dart';
import '../../widgets/notification_card_widget.dart';

// ignore: must_be_immutable
class NotificationScreen extends GetView<NotificationController> {
  NotificationScreen({super.key});
  Function(bool value)? onChange;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        controller.isSelectAll = false;
        controller.selectedIds.clear();
        Get.find<NotificationController>().isSelectionMode(false);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text("Notifications"),
          actions: [
            Obx(
              () => Visibility(
                visible:
                    Get.find<NotificationController>().isSelectionMode.value,
                child: InkWell(
                  onTap: controller.selectedIds.isNotEmpty
                      ? () {
                          final notificationController =
                              Get.find<NotificationController>();

                          for (var item in notificationController
                              .notificationModel.value.data!) {
                            if (item.isSelected ?? false) {
                              controller.selectedIds.add(item.id.toString());
                            }
                          }
                          if (controller.selectedIds.isNotEmpty) {
                            log(controller.selectedIds.toString());

                            notificationController.deleteNotifications(
                                notificationId: controller.selectedIds);
                            notificationController.notificationModel.value.data
                                ?.removeWhere(
                              (item) =>
                                  controller.selectedIds.contains(item.id),
                            );

                            notificationController.isSelectionMode(false);
                            notificationController.notificationModel.refresh();
                          } else {
                            log(controller.selectedIds.toString());
                            return;
                          }
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.delete_outline),
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible:
                    (Get.find<NotificationController>().isSelectionMode.value),
                child: InkWell(
                  onTap: () {
                    final notificationController =
                        Get.find<NotificationController>();
                    controller.isSelectAll = !controller.isSelectAll;
                    for (var item in notificationController
                        .notificationModel.value.data!) {
                      item.isSelected = controller.isSelectAll;
                      controller.selectedIds.add(item.id.toString());
                    }
                    if (!controller.isSelectAll) {
                      notificationController.isSelectionMode(false);
                    }
                    notificationController.notificationModel.refresh();
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
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: NotificationCard(),
            ),
          ),
        ),
      ),
    );
  }
}
