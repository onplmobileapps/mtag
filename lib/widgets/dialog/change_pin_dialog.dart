import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/auth_controller.dart';
import '../../base/app_data.dart';

void showChangePinDialog({
  required Function(String oldPin, String newPin) onSubmit,
}) {
  Get.put(ChangePinController());
  Get.dialog(
    ChangePinDialog(onSubmit: onSubmit),
    barrierDismissible: false,
  ).then((_) => Get.delete<ChangePinController>());
}

class ChangePinController extends GetxController {
  final oldPinController = TextEditingController();
  final newPinController = TextEditingController();
  final reenterPinController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final oldPinFocusNode = FocusNode();
  final newPinFocusNode = FocusNode();
  final reenterPinFocusNode = FocusNode();

  var obscureOldPin = true.obs;
  var obscureNewPin = true.obs;
  var obscureReenterPin = true.obs;

  bool isPinsMatching() {
    return newPinController.text == reenterPinController.text;
  }

  Future<void> submit(Function(String, String) onSubmit) async {
    if (formKey.currentState!.validate()) {
      onSubmit(oldPinController.text, newPinController.text);
      await Get.find<AuthController>().createPIN(
        cnic: AppData.getPinData()?['cnic'],
        mobileNum: AppData.getPinData()?['mobile'],
        isResetPin: 1,
        isCreatePin: 0,
        isForgetPin: 0,
        pin: oldPinController.text,
        newPin: newPinController.text,
      );
      Get.back();
    }
  }

  @override
  void onClose() {
    oldPinController.dispose();
    newPinController.dispose();
    reenterPinController.dispose();
    oldPinFocusNode.dispose();
    newPinFocusNode.dispose();
    reenterPinFocusNode.dispose();
    super.onClose();
  }
}

class PinTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final RxBool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final Function(String)? onFieldSubmitted;

  const PinTextField({
    super.key,
    required this.labelText,
    required this.controller,
    required this.focusNode,
    required this.obscureText,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          obscureText: obscureText.value,
          maxLength: 4,
          decoration: InputDecoration(
            counterText: "",
            labelText: labelText,
            labelStyle: const TextStyle(fontSize: 14), // Smaller label size for unfocused state
            floatingLabelStyle: Theme.of(context).inputDecorationTheme.floatingLabelStyle, // Use theme for focused
            border: Theme.of(context).inputDecorationTheme.border,
            suffixIcon: IconButton(
              icon: Icon(
                obscureText.value ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => obscureText.value = !obscureText.value,
            ),
          ),
          validator: validator,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
        ));
  }
}

class ChangePinDialog extends StatelessWidget {
  final Function(String oldPin, String newPin) onSubmit;

  const ChangePinDialog({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChangePinController>();

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
        surfaceTintColor: Theme.of(context).dialogTheme.surfaceTintColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/padlock.png', height: 64, width: 64),
                  const SizedBox(height: 20),
                  Text(
                    'Change PIN',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: ctrl.formKey,
                    child: Column(
                      children: [
                        PinTextField(
                          labelText: 'Old PIN',
                          controller: ctrl.oldPinController,
                          focusNode: ctrl.oldPinFocusNode,
                          obscureText: ctrl.obscureOldPin,
                          validator: (value) =>
                              value == null || value.isEmpty || value.length < 4
                                  ? 'Please enter your old PIN'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        PinTextField(
                          labelText: 'New Pin',
                          controller: ctrl.newPinController,
                          focusNode: ctrl.newPinFocusNode,
                          obscureText: ctrl.obscureNewPin,
                          validator: (value) =>
                              value == null || value.isEmpty || value.length < 4
                                  ? 'Please enter a new PIN'
                                  : null,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(ctrl.reenterPinFocusNode);
                          },
                        ),
                        const SizedBox(height: 12),
                        PinTextField(
                          labelText: 'Re-Enter New PIN',
                          controller: ctrl.reenterPinController,
                          focusNode: ctrl.reenterPinFocusNode,
                          obscureText: ctrl.obscureReenterPin,
                          validator: (value) {
                            if (value == null || value.isEmpty || value.length < 4) {
                              return 'Please re-enter your new PIN';
                            } else if (!ctrl.isPinsMatching()) {
                              return "New Pin & Re-Enter Pin doesn't match";
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => ctrl.submit(onSubmit),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ctrl.submit(onSubmit),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Submit'.toUpperCase(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 16,
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}