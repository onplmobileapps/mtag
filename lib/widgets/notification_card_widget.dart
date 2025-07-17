import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/notification/controller/notificationcontroller.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NotificationController>(
      init: NotificationController(), // Initialize controller
      builder: (controller) {
        // Fetch notifications when the widget is built
        controller.getNotifications();

        return Obx(
          () {
            final data = controller.notificationModel.value.data;
            if (data == null || data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80.0,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'No Notifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final notification = data.reversed.toList()[index];

                return Card(
                  elevation: 0.1,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: notification.isSelected ?? false
                      ? Theme.of(context).colorScheme.primary.withAlpha(80)
                      : null,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.0),
                    onLongPress: () {
                      if (!controller.isSelectionMode.value) {
                        controller.isSelectionMode.value = true;
                        controller.toggleSelection(notification.id!);
                      }
                    },
                    onTap: () {
                      if (controller.isSelectionMode.value) {
                        controller.toggleSelection(notification.id!);
                      } else {
                        Get.toNamed('/notificationsExpandScreen',
                            arguments: notification);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            margin: const EdgeInsets.only(right: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Image.asset(
                              'assets/logolight.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  notification.body ?? '',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              controller.isSelectionMode.value
                                  ? Checkbox(
                                      value: notification.isSelected ?? false,
                                      onChanged: (_) => controller
                                          .toggleSelection(notification.id!),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () {
                                        showCupertinoModalPopup(
                                          context: context,
                                          builder: (_) => CupertinoAlertDialog(
                                            title:
                                                const Text('Delete Notification'),
                                            content: const Text(
                                                'Are you sure you want to delete this notification?'),
                                            actions: [
                                              CupertinoDialogAction(
                                                isDestructiveAction: true,
                                                child: const Text('Cancel'),
                                                onPressed: () => Get.back(),
                                              ),
                                              CupertinoDialogAction(
                                                child: const Text('Delete'),
                                                onPressed: () async {
                                                  Get.back();
                                                  await controller
                                                      .deleteNotifications(
                                                    notificationId: [
                                                      notification.id!
                                                    ],
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                              Text(
                                notification.datetimeSmall ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.redAccent,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}