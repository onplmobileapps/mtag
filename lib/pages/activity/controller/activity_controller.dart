import 'package:get/get.dart';
import '/controller/home_controller.dart';
import '/pages/activity/model/activities_model.dart';
import '../../../widgets/dialog/cupertion_dialog.dart';
import '../../../api/api_constants.dart';
import '../../../api/auth_controller.dart';
import '../../../api/user_repo.dart';

class ActivityContorller extends GetxController implements GetxService {
  final UserRepo userRepo;
  ActivityContorller(this.userRepo);
  Rx<ActivitiesModel> activitiesModel = ActivitiesModel().obs;
  getActivities() async {
    Map<String, dynamic> response = await userRepo.getActivities();
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      activitiesModel.value = ActivitiesModel.fromJson(response[APIRESPONSE.SUCCESS]);
      return;
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () {
        Get.delete<HomeController>(force: true);
        Get.find<AuthController>().clearSharedData();
        Get.offAllNamed('/pinPage');
      });
    }
  }

  @override
  void onReady() async {
    await getActivities();
    super.onReady();
  }
}
