import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '/api/api_constants.dart';
import '/pages/mtag/model/dlinkoptionsmodel.dart';
import '../../../widgets/dialog/cupertion_dialog.dart';

import '../../../api/user_repo.dart';
import '../model/vehdelinkmodel.dart';

class DelinkController extends GetxController implements GetxService {
  final UserRepo userRepo;
  DelinkController({required this.userRepo});
  RxBool isLoading = false.obs;

  Rx<Dlinkoptions> dlinkOptionsModel = Dlinkoptions().obs;
  Rx<DeLinkVehicleModel> delinkVehicle = DeLinkVehicleModel().obs;

  Future<Map<String, dynamic>> getDlinkOptions() async {
    isLoading(true);
    var response = await userRepo.getDlinkOptions();

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      dlinkOptionsModel.value = Dlinkoptions.fromJson(response[APIRESPONSE.SUCCESS]);
      isLoading(false);
    } else {
      isLoading(false);
      showCupertinoModalPopup(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CupertinoAlertDialog(
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Get.offAllNamed('/pinPage');
                Get.deleteAll();
              },
              child: const Text('Ok'),
            )
          ],
          content: Text('${response['msg']}'),
        ),
      );
    }
    return response;
  }

  Future<Map<String, dynamic>> deLinkVehicle({String? mtagID, String? rDesc, String? rID}) async {
    isLoading(true);
    var response = await userRepo.delinkVehicle(mtagID: mtagID, rDesc: rDesc, rID: rID);

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      dlinkOptionsModel.value = Dlinkoptions.fromJson(response[APIRESPONSE.SUCCESS]);
      isLoading(false);
      showPopDialog('${dlinkOptionsModel.value.message}', () => Get.back());
    } else {
      isLoading(false);
      showPopDialog('${response['msg']}', () {
        Get.offAllNamed('/pinPage');
        Get.deleteAll();
      });
    }
    return response;
  }

  @override
  void onReady() {
    getDlinkOptions();
    super.onReady();
  }
}
