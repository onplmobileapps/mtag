import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/api_constants.dart';
import 'package:mtag_flutterapp/api/user_repo.dart';
import 'package:mtag_flutterapp/pages/receipt/model/receipt_model.dart';
import 'package:mtag_flutterapp/widgets/dialog/cupertino_dialog.dart';

class ReceiptController extends GetxController implements GetxService {
  final UserRepo userRepo;
  ReceiptController({required this.userRepo});
  RxBool isTravel = false.obs;
  Rx<ReceiptModel> receiptModel = ReceiptModel().obs;

  Future<void> getrechargeDetails({required String? cr, required String? uID, String? itoken}) async {
    var response = isTravel.value
        ? await userRepo.getTransactionsDetails(cr: cr, uID: uID, itoken: itoken)
        : await userRepo.getRechargeDetails(cr: cr, uID: uID);
    isTravel(false);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      receiptModel.value = ReceiptModel.fromJson(response[APIRESPONSE.SUCCESS]);
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () => Get.back());
    }
  }

  bool chechTravel(bool istravel) {
    return isTravel(istravel);
  }
}
