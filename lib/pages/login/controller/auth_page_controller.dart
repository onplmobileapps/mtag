import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthPageController extends GetxController {
  final userName = TextEditingController();
  final phoneController = TextEditingController();
  final cnicController = TextEditingController();
  final authIndex = 0.obs;
  final cnicFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final fullNameFocusNode = FocusNode();
  final selectedOperator = Rxn<Map<String, dynamic>>();

  @override
  void onClose() {
    userName.dispose();
    phoneController.dispose();
    cnicController.dispose();
    cnicFocusNode.dispose();
    phoneFocusNode.dispose();
    fullNameFocusNode.dispose();
    super.onClose();
  }
}
