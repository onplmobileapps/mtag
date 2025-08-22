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

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({super.key});

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  late final FocusNode _nameFocusNode;
  late final FocusNode _cnicFocusNode;
  late final FocusNode _phoneFocusNode;
  late final FocusNode _remarksFocusNode;

  late final TextEditingController _nameController;
  late final TextEditingController _cnicController;
  late final TextEditingController _phoneController;
  late final TextEditingController _remarksController;

  final _formKey = GlobalKey<FormState>();
  final _otherConstants = OtherConsts();

  @override
  void initState() {
    super.initState();
    _nameFocusNode = FocusNode();
    _cnicFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _remarksFocusNode = FocusNode();

    _nameController = TextEditingController(text: _otherConstants.ownerName.value);
    _cnicController = TextEditingController(text: _otherConstants.ownerCNIC.value);
    _phoneController = TextEditingController(text: _otherConstants.mobile.value);
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _cnicFocusNode.dispose();
    _phoneFocusNode.dispose();
    _remarksFocusNode.dispose();

    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _remarksController.dispose();

    super.dispose();
  }

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
            Icon(Icons.call, size: 20),
            SizedBox(width: 1.0),
            Text(
              '1313',
              style: TextStyle(fontSize: 13, fontFamily: "Poppins"),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Add Feedback')),
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
                  const SizedBox(height: 10),
                  CustomTextField(
                    validator: (value) {
                      if (value!.isEmpty || value.length < 3) {
                        return 'Enter valid name';
                      }
                      return null;
                    },
                    readOnly: true,
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    ],
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_cnicFocusNode),
                    label: 'FULL NAME',
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    validator: (p0) {
                      if (p0!.isEmpty || p0.isCnpj) {
                        return 'Enter valid CNIC';
                      }
                      return null;
                    },
                    readOnly: true,
                    controller: _cnicController,
                    focusNode: _cnicFocusNode,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_phoneFocusNode),
                    inputFormatters: [
                      CnicMaskTextInputFormatter(),
                      FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]')),
                    ],
                    label: 'CNIC',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    validator: (p0) {
                      if (p0!.isEmpty || !p0.isPhoneNumber) {
                        return 'Enter valid phone';
                      }
                      return null;
                    },
                    readOnly: true,
                    maxLength: 11,
                    controller: _phoneController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    focusNode: _phoneFocusNode,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_remarksFocusNode),
                    label: 'MOBILE NUMBER',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    style: const TextStyle(height: 1, fontSize: 12),
                    maxLines: 4,
                    focusNode: _remarksFocusNode,
                    controller: _remarksController,
                    validator: (p0) {
                      if (p0!.isEmpty || p0.length.isLowerThan(3)) {
                        return 'Enter remarks';
                      }
                      return null;
                    },
                    onEditingComplete: () => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).disabledColor,
                      labelText: 'REMARKS',
                      border: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Spacer(flex: 6),
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
                          remarks: _remarksController.text.trim(),
                        );
                        _remarksController.clear();
                      }
                    },
                    text: 'Submit',
                  ),
                  const Spacer(flex: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
