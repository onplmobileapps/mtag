import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import '../pages/notification/controller/notificationcontroller.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    super.key,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  final notificationController = Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationController.getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        // If no items are selected and selection mode is false, set isSelectionMode to false

        return (notificationController.notificationModel.value.data == null ||
                (notificationController.notificationModel.value.data?.isEmpty ??
                    false) ||
                notificationController.notificationModel.value.cnt == 0)
            ? Center(
                child: Text(
                  'No Data Found',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              )
            : ListView.builder(
                itemCount:
                    notificationController.notificationModel.value.data?.length,
                itemBuilder: (context, index) {
                  final notificationItem = notificationController
                      .notificationModel.value.data?[index];

                  return InkWell(
                    onLongPress: () {
                      notificationController.isSelectionMode(true);
                      log(notificationController.isSelectionMode.value
                          .toString());
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    onTap: () {
                      if (!notificationController.isSelectionMode.value) {
                        Get.toNamed(
                          '/notificationsExpandScreen',
                          arguments: notificationController
                              .notificationModel.value.data?[index],
                        );
                      }

                      if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Container(
                      key: UniqueKey(),
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            margin: const EdgeInsets.only(left: 4,right: 8,top: 4),
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Image.asset('assets/logolight.png'),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  notificationItem?.title ?? '',
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  notificationItem?.body ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notificationItem?.datetimeSmall ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: const Color(0XffE73B3E),
                                          fontStyle: FontStyle.italic),
                                  softWrap: false,
                                  maxLines: 1,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                notificationController.isSelectionMode.value ==
                                        true
                                    ? Checkbox(activeColor: primarSwatch,
                                        value: notificationItem?.isSelected,
                                        onChanged: (v) {
                                          notificationItem?.isSelected = v;
                            
                                          for (var item in notificationController
                                              .notificationModel.value.data!) {
                                            if (item.isSelected ?? false) {
                                              // Check if item.id is NOT already in the list before adding
                                              if (!notificationController
                                                  .selectedIds
                                                  .contains(item.id.toString())) {
                                                notificationController.selectedIds
                                                    .add(item.id.toString());
                                                log("ids: ${notificationController.selectedIds}");
                                              }
                                            }
                                          }
                            
                                          // Check if any item is selected, if none, disable selection mode
                                          bool isAnyItemSelected =
                                              notificationController
                                                      .notificationModel
                                                      .value
                                                      .data
                                                      ?.any((item) =>
                                                          item.isSelected ==
                                                          true) ??
                                                  false;
                            
                                          if (!isAnyItemSelected) {
                                            notificationController
                                                .isSelectionMode.value = false;
                                          }
                            
                                          setState(() {});
                                        },
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          showCupertinoModalPopup(
                                            context: context,
                                            builder: (_) => CupertinoAlertDialog(
                                              content: const Text(
                                                  'Do you want to delete?'),
                                              actions: [
                                                CupertinoDialogAction(
                                                  isDestructiveAction: true,
                                                  child: const Text('Cancel'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                ),
                                                CupertinoDialogAction(
                                                  child: const Text('Ok'),
                                                  onPressed: () async {
                                                    Get.back();
                                                    await notificationController
                                                        .deleteNotifications(
                                                            notificationId: [
                                                          "${notificationItem?.id}"
                                                        ]);
                                                    notificationController
                                                        .notificationModel
                                                        .value
                                                        .data
                                                        ?.removeAt(index);
                                                    notificationController
                                                        .notificationModel
                                                        .refresh();
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.more_vert_outlined,
                                        ))
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
      },
    );
  }
}
