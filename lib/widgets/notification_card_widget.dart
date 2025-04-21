import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/notification/controller/notificationcontroller.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({super.key});

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
        final data = notificationController.notificationModel.value.data;
        if (data == null || data.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                size: 100.0,
                Icons.notifications_off_outlined,
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                'No notifications yet!',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final notificationItem = data[index];

            return InkWell(
              onLongPress: () {
                if (!notificationController.isSelectionMode.value) {
                  notificationController.isSelectionMode.value = true;
                  notificationController.toggleSelection(notificationItem.id!);
                }
              },
              onTap: () {
                if (notificationController.isSelectionMode.value) {
                  notificationController.toggleSelection(notificationItem.id!);
                } else {
                  Get.toNamed('/notificationsExpandScreen',
                      arguments: notificationItem);
                }
              },
              child: Container(
                key: UniqueKey(),
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsets.only(left: 4, right: 8, top: 4),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset('assets/logolight.png'),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            notificationItem.title ?? '',
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            notificationItem.body ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displaySmall,
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
                            notificationItem.datetimeSmall ?? '',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: const Color(0XffE73B3E),
                                  fontStyle: FontStyle.italic,
                                ),
                            softWrap: false,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          notificationController.isSelectionMode.value
                              ? Checkbox(
                                  activeColor: Colors.blue,
                                  value: notificationItem.isSelected ?? false,
                                  onChanged: (v) {
                                    notificationController
                                        .toggleSelection(notificationItem.id!);
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
                                                Navigator.of(context).pop(),
                                          ),
                                          CupertinoDialogAction(
                                            child: const Text('Ok'),
                                            onPressed: () async {
                                              Get.back();
                                              await notificationController
                                                  .deleteNotifications(
                                                notificationId: [
                                                  notificationItem.id!
                                                ],
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: const Icon(Icons.more_vert_outlined),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
