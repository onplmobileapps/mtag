import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/user_repo.dart';
import '../../../api/api_constants.dart';
import '../models/deleteaccountmodel.dart';

class DeleteAccountController extends GetxController implements GetxService {
  final UserRepo userRepo;

  DeleteAccountController({required this.userRepo});

  Rx<DeleteAccountModel> delAccountModel = DeleteAccountModel().obs;

  Future<Map<String, dynamic>> deleteAccount({String? comments}) async {
    var response = await userRepo.deleteAccount(comments: comments);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      // delAccountModel.value = DeleteAccountModel.fromJson(response[APIRESPONSE.SUCCESS]);
      showCupertinoModalPopup(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CupertinoAlertDialog(
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Ok'),
            )
          ],
          content: Text(response[APIRESPONSE.SUCCESS]['Message']),
        ),
      );
    } else {
      showCupertinoModalPopup(
        barrierDismissible: false,
        context: Get.context!,
        builder: (context) => CupertinoAlertDialog(
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Get.offAllNamed('/pinPage');
              },
              child: const Text('Ok'),
            )
          ],
          content: Text('${response['Message']}'),
        ),
      );
    }
    return response;
  }
}
