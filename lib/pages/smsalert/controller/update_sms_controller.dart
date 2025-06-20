import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/api_constants.dart';
import 'package:mtag_flutterapp/pages/smsalert/model/update_sms_status.dart';
import 'package:mtag_flutterapp/widgets/dialog/cupertion_dialog.dart';
import '../../../api/user_repo.dart';

class UpdateSmsStatusController extends GetxController implements GetxService {
  final UserRepo userRepo;
  UpdateSmsStatusController({required this.userRepo});
  RxBool isLoading = false.obs;
  Rx<UpdateSmsStatusModel> updateSmsModel = UpdateSmsStatusModel().obs;

  Future<Map<String, dynamic>> getSmsStatus({String? newValue, String? mtagID}) async {
    isLoading(true);

    var response = await userRepo.getSmsStatus(newValue: newValue, mtagID: mtagID);

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      updateSmsModel.value = UpdateSmsStatusModel.fromJson(response[APIRESPONSE.SUCCESS]);
      isLoading(false);
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      isLoading(false);
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () {
        Get.offAllNamed('/pinPage');
        Get.deleteAll();
      });
    } else {
      showPopDialog('We couldn’t complete your request\n Try again or contact assistance.\nTry again later.', () {
        Get.offAllNamed('/pinPage');
        Get.deleteAll();
      });
    }
    return response;
  }
}
