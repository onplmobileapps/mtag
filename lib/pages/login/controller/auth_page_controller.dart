import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthPageController extends GetxController {
  final userName = TextEditingController();
  final phoneController = TextEditingController();
  final cnicController = TextEditingController();
  final authIndex = 0.obs; // Reactive state for Sign In (0) / Sign Up (1)
  final formKey = GlobalKey<FormState>();
  final cnicFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  @override
  void onClose() {
    userName.dispose();
    phoneController.dispose();
    cnicController.dispose();
    cnicFocusNode.dispose();
    phoneFocusNode.dispose();
    super.onClose();
  }
}