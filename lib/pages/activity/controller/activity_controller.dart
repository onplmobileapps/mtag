import 'package:get/get.dart';
import '/controller/home_controller.dart';
import '/pages/activity/model/activities_model.dart';
import '../../../widgets/dialog/cupertino_dialog.dart';
import '../../../api/api_constants.dart';
import '../../../api/auth_controller.dart';
import '../../../api/user_repo.dart';

class ActivityController extends GetxController implements GetxService {
  final UserRepo userRepo;

  ActivityController(this.userRepo);

  Rx<ActivitiesModel> activitiesModel = ActivitiesModel().obs;

  Future<void> getActivities() async {
    Map<String, dynamic> response = await userRepo.getActivities();
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      activitiesModel.value = ActivitiesModel.fromJson(
        response[APIRESPONSE.SUCCESS],
      );
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
