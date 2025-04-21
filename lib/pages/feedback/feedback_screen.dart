import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/analytics.dart';
import '../../constants/other_consts.dart';
import '../../pages/editprofile/controller/update_emai_controller.dart';
import '../../constants/call_helper.dart';
import '../../widgets/elevated_button.dart';
import '../../constants/input_formater.dart';
import '../../widgets/textform_widget.dart';

class FeedBackScreen extends StatelessWidget {
  FeedBackScreen({super.key});
  final _nameFocusNode = FocusNode(),
      _cnicFocusNode = FocusNode(),
      _phoneFocusNode = FocusNode(),
      _remarksFocusNode = FocusNode();
  final _nameController = TextEditingController(),
      _cnicController = TextEditingController(),
      _phoneController = TextEditingController(),
      _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _otherConstants = OtherConsts();
  @override
  Widget build(BuildContext context) {
    Analytics.feedbackTapped();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Analytics.call1313Tapped();
          CallWhatsappUtil.openCall1313();
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.call,
              size: 20,
            ),
            SizedBox(
              width: 1.0,
            ),
            Text(
              '1313',
              style: TextStyle(fontSize: 13, fontFamily: "Poppins"),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Add Feedback'),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTExtField(
                    validator: (value) {
                      if (value!.isEmpty || value.length < 3) {
                        return 'Enter valid name';
                      }
                      return null;
                    },
                    isReadOnly: true,
                    controller: _nameController..text = _otherConstants.ownerName.value,
                    focusNode: _nameFocusNode,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'))],
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_cnicFocusNode),
                    label: 'FULL NAME',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTExtField(
                    validator: (p0) {
                      if (p0!.isEmpty || p0.isCnpj) {
                        return 'Enter valid CNIC';
                      }
                      return null;
                    },
                    isReadOnly: true,
                    controller: _cnicController..text = _otherConstants.ownerCNIC.value,
                    focusNode: _cnicFocusNode,
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_phoneFocusNode),
                    inputFormatters: [
                      CnicMaskTextInputFormatter(),
                      FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]'))
                    ],
                    label: 'CNIC',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTExtField(
                    validator: (p0) {
                      if (p0!.isEmpty || !p0.isPhoneNumber) {
                        return 'Enter valid phone';
                      }
                      return null;
                    },
                    isReadOnly: true,
                    maxLength: 11,
                    controller: _phoneController..text = _otherConstants.mobile.value,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    focusNode: _phoneFocusNode,
                    onEditingComplete: () => FocusScope.of(context).requestFocus(_remarksFocusNode),
                    label: 'MOBILE NUMBER',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomTExtField(
                    filled: true,
                    fillColor: Theme.of(context).disabledColor,
                    contentPadding: const EdgeInsets.only(left: 0),
                    validator: (p0) {
                      if (p0!.isEmpty || p0.length.isLowerThan(3)) {
                        return 'Enter remarks';
                      }
                      return null;
                    },
                    controller: _remarksController,
                    focusNode: _remarksFocusNode,
                    inputFormatters: const [],
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    maxLines: 4,
                    label: 'REMARKS',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Spacer(
                    flex: 6,
                  ),
                  ElevatedButton1(
                      backgroundColor: Theme.of(context).primaryColor,
                      width: MediaQuery.sizeOf(context).width,
                      onclick: () async {
                        Analytics.submitFeedbackTapped();
                        if (_formKey.currentState!.validate()) {
                          await Get.find<UpdateEmailController>().addFeedBack(
                              cnic: _cnicController.text,
                              mobileNumber: _phoneController.text,
                              fullName: _nameController.text,
                              remarks: _remarksController.text.trim());
                          _remarksController.clear();
                        }
                      },
                      text: 'Submit'),
                  const Spacer(
                    flex: 4,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
