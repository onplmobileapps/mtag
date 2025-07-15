import 'package:get/get.dart';
import '../../../controller/home_controller.dart';
import '../../../widgets/dialog/cupertino_dialog.dart';
import '/api/user_repo.dart';
import '/pages/tollhistory/model/toll_history_model.dart';
import '../../../api/api_constants.dart';

class TollController extends GetxController implements GetxService {
  final UserRepo userRepo;
  TollController({required this.userRepo});
  RxList<AllTransactions>? searchList = <AllTransactions>[].obs;
  var tollHistoryModel = Rx<TollHistoryModel?>(null);
  final RxInt isSlected = 0.obs;
  Future<Map<String, dynamic>> geTollHistory(
      {String? startDate, String? endDate, String? mtagID, int? pageNo, bool? isLoading}) async {
    var respone = await userRepo.getTollHistory(
      startDate: startDate ?? '',
      endDate: endDate ?? '',
      mtagID: mtagID ?? '',
      pageNo: 1,
    );
    if (respone.containsKey(APIRESPONSE.SUCCESS)) {
      var data = TollHistoryModel.fromJson(respone[APIRESPONSE.SUCCESS]);
      tollHistoryModel.value = data;
      searchList?.value = data.data?.allTransactions ?? RxList();
    } else if (respone.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(respone[APIRESPONSE.ERROR]['Message'], () {
        if (respone[APIRESPONSE.ERROR]['Code'] == 450) {
          Get.delete<HomeController>(force: true);
          Get.offAllNamed('/pinPage');
        } else {
          Get.back();
        }
      });
    }
    return respone;
  }

 void serchData(String cr) {
    if (cr == '') {
      searchList?.value = tollHistoryModel.value?.data?.allTransactions ?? [];
    } else {
      var data = tollHistoryModel.value?.data?.allTransactions?.where((element) => element.cR == cr).toList();
      searchList?.value = data ?? RxList();
    }
  }
}
