import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/pages/notification/model/notification_model.dart';
import '/pages/notification/model/delete_notification_model.dart';
import '../../../widgets/dialog/cupertion_dialog.dart';

class NotificationController extends GetxController implements GetxService {
  Rx<NotificationModel> notificationModel = NotificationModel().obs;
  RxBool isSelectionMode = RxBool(false);
  bool isSelectAll = false;
  RxList<String> selectedIds = <String>[].obs;
  Rx<DeleteNotificationModel> deleteNotificationModel =
      DeleteNotificationModel().obs;

  static const String _notificationsKey = 'notifications_data';

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  Future<Map<String, dynamic>> getNotifications() async {
    isSelectionMode(false);
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    if (notificationsJson != null) {
      final Map<String, dynamic> jsonData = jsonDecode(notificationsJson);
      notificationModel.value = NotificationModel.fromJson(jsonData);
      return {'success': true, 'data': jsonData};
    } else {
      notificationModel.value = NotificationModel(
        code: '200',
        message: 'No notifications found',
        cnt: 0,
        data: [],
      );
      await _saveNotifications();
      return {'success': true, 'data': null};
    }
  }

  Future<Map<String, dynamic>> deleteNotifications(
      {List<String>? notificationId}) async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString(_notificationsKey);

    if (notificationsJson != null) {
      final Map<String, dynamic> jsonData = jsonDecode(notificationsJson);
      NotificationModel currentModel = NotificationModel.fromJson(jsonData);

      if (notificationId != null && notificationId.isNotEmpty) {
        currentModel.data?.removeWhere(
            (notification) => notificationId.contains(notification.id));
        currentModel.cnt = currentModel.data?.length ?? 0;

        notificationModel.value = currentModel;
        await _saveNotifications();

        deleteNotificationModel.value = DeleteNotificationModel(
          code: '200',
          message:
              '${notificationId.length} notification(s) deleted successfully',
        );
        selectedIds.clear();
        isSelectAll = false;
        isSelectionMode.value = false;
        showPopDialog(
            '${deleteNotificationModel.value.message}', () => Get.back());
        return {'success': true};
      } else {
        notificationModel.value = NotificationModel(
          code: '200',
          message: 'All notifications cleared',
          cnt: 0,
          data: [],
        );
        await _saveNotifications();

        deleteNotificationModel.value = DeleteNotificationModel(
          code: '200',
          message: 'All notifications cleared',
        );
        selectedIds.clear();
        isSelectAll = false;
        isSelectionMode.value = false;
        showPopDialog(
            '${deleteNotificationModel.value.message}', () => Get.back());
        return {'success': true};
      }
    } else {
      showPopDialog('No notifications to delete', () => Get.back());
      return {'success': false, 'message': 'No notifications found'};
    }
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(notificationModel.value.toJson());
    await prefs.setString(_notificationsKey, jsonString);
  }

  Future<void> addNotification(Data newNotification) async {
    log('called at receive time${newNotification.body}');
    notificationModel.value.data ??= [];
    notificationModel.value.data!.add(newNotification);
    notificationModel.value.cnt = notificationModel.value.data!.length;
    await _saveNotifications();
    notificationModel.refresh();
  }

  @override
  void onClose() {
    isSelectionMode(false);
    super.onClose();
  }

  void toggleSelectionMode() => isSelectionMode.value = !isSelectionMode.value;

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    final item = notificationModel.value.data?.firstWhere((n) => n.id == id);
    if (item != null) item.isSelected = selectedIds.contains(id);
    final isAnySelected =
        notificationModel.value.data?.any((item) => item.isSelected ?? false) ??
            false;
    if (!isAnySelected) isSelectionMode.value = false;
    notificationModel.refresh();
  }

  void selectAll() {
    isSelectAll = !isSelectAll;
    if (isSelectAll) {
      selectedIds.value =
          notificationModel.value.data?.map((d) => d.id!).toList() ?? [];
      notificationModel.value.data?.forEach((item) => item.isSelected = true);
    } else {
      selectedIds.clear();
      notificationModel.value.data?.forEach((item) => item.isSelected = false);
      isSelectionMode.value = false;
    }
    notificationModel.refresh();
  }
}
