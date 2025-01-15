import 'package:get/get.dart';
import '/api/api_constants.dart';
import '/pages/notification/model/delete_notification_model.dart';
import '/pages/notification/model/notification_model.dart';
import '../../../widgets/dialog/cupertion_dialog.dart';

import '../../../api/user_repo.dart';

class NotificationController extends GetxController implements GetxService {
  final UserRepo userRepo;
  NotificationController({required this.userRepo});

  Rx<NotificationModel> notificationModel = NotificationModel().obs;
  RxBool isSelectionMode = RxBool(false);
    bool isSelectAll = false;
  RxList<String> selectedIds = [''].obs;
  Rx<DeleteNotificationModel> deleteNotificationModel = DeleteNotificationModel().obs;

  //delete notification function
  Future<Map<String, dynamic>> deleteNotifications({List<String>? notificationId}) async {
    var response = await userRepo.deleteNotifications(notificationId: notificationId);

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      deleteNotificationModel.value = DeleteNotificationModel.fromJson(response[APIRESPONSE.SUCCESS]);
      showPopDialog('${deleteNotificationModel.value.message}', () => Get.back());
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () => Get.back());
    } else {
      showPopDialog('Something went wrong\nTry again later.', () => Get.offAllNamed('/login'));
    }

    return response;
  }

  Future<Map<String, dynamic>> getNotifications() async {
    isSelectionMode(false);
    var response = await userRepo.getNotifications();

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      notificationModel.value = NotificationModel.fromJson(response[APIRESPONSE.SUCCESS]);
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () => Get.offAllNamed('/login'));
    } else {
      showPopDialog('Something went wrong\nTry again later.', () => Get.offAllNamed('/login'));
    }

    return response;
  }
  @override
  void onClose() {
   isSelectionMode(false);
    super.onClose();
  }
}
