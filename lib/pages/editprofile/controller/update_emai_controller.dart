import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '/api/api_constants.dart';
import '/api/user_repo.dart';
import '/constants/other_consts.dart';
import '../../../widgets/dialog/cupertion_dialog.dart';
import '../model/customer_details_model.dart';
import '../model/update_email_model.dart';

class UpdateEmailController extends GetxController implements GetxService {
  final UserRepo userRepo;
  UpdateEmailController({required this.userRepo});
  late TextEditingController nameController = TextEditingController(),
      cnicController = TextEditingController(),
      phoneController = TextEditingController(),
      passwordController = TextEditingController(),
      confirmPassController = TextEditingController(),
      emailController = TextEditingController();
  final _otherConstants = OtherConsts();
  RxBool isLoading = false.obs;
  Rx<UpdateEmailModel> emailModel = UpdateEmailModel().obs;
  Rx<CustomerDetailsModel> customerModel = CustomerDetailsModel().obs;

  Future<Map<String, dynamic>> updateEmail({String? email, String? fullName, String? password}) async {
    isLoading(false);
    var response = await userRepo.updateUserEmail(email: email, fullName: fullName, password: password);
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      _otherConstants.isRefresh(true);
      emailModel.value = UpdateEmailModel.fromJson(response[APIRESPONSE.SUCCESS]);
      showPopDialog(emailModel.value.msg ?? '', () {
        Get.back();
        Get.back();
      });
    }
    return response;
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    var response = await userRepo.getUserDetails();

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      customerModel.value = CustomerDetailsModel.fromJson(response[APIRESPONSE.SUCCESS]);
    }
    return response;
  }

  Future<Map<String, dynamic>> addFeedBack({
    String? email,
    String? fullName,
    String? cnic,
    String? mobileNumber,
    String? remarks,
  }) async {
    var response = await userRepo.addFeedBack(
      email: customerModel.value.data?.customerDetail?.email,
      cnic: cnic,
      mobileNumber: mobileNumber,
      remarks: remarks,
      fullName: fullName,
    );

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      showPopDialog(response[APIRESPONSE.SUCCESS]['Message'], () {
        Get.back();
        Get.back();
      });
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () {
        Get.back();
        Get.back();
      });
    }
    return response;
  }

  String getInitials(String fullName) {
    if (fullName.trim().isNotEmpty) {
      var nameParts = fullName.trim().split(RegExp(r'\s+'));
      if (nameParts.isNotEmpty) {
        var firstNameInitial = nameParts[0][0].toUpperCase();
        var secondNameInitial = nameParts.length > 1 ? nameParts[1][0].toUpperCase() : '';
        if (secondNameInitial.isNotEmpty) {
          return '$firstNameInitial$secondNameInitial';
        } else {
          return firstNameInitial;
        }
      }
    }
    return '';
  }

  @override
  void onReady() async {
    await getUserDetails();
    nameController.text = customerModel.value.data?.customerDetail?.fullName ?? '';
    emailController.text = customerModel.value.data?.customerDetail?.email ?? '';
    phoneController.text = customerModel.value.data?.customerDetail?.mobileNumber ?? '';
    cnicController.text = customerModel.value.data?.customerDetail?.cNIC ?? '';
    passwordController.text = customerModel.value.data?.customerDetail?.password ?? '';
    confirmPassController.text = customerModel.value.data?.customerDetail?.password ?? '';
    super.onReady();
  }
}
