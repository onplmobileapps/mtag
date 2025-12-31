import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../pages/editprofile/controller/update_emai_controller.dart';
import '../../constants/call_helper.dart';
import '../../widgets/elevated_button.dart';
import '../../constants/input_formater.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({super.key});

  @override
  State<FeedBackScreen> createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  late final FocusNode _remarksFocusNode;

  late final TextEditingController _nameController;
  late final TextEditingController _cnicController;
  late final TextEditingController _phoneController;
  late final TextEditingController _remarksController;

  final _formKey = GlobalKey<FormState>();
  final homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();

    _remarksFocusNode = FocusNode();

    _nameController = TextEditingController(
      text: homeController.dashboradData.value.customerDetail?.fullName,
    );
    _cnicController = TextEditingController(
      text: homeController.dashboradData.value.customerDetail?.cNIC,
    );
    _phoneController = TextEditingController(
      text: homeController.dashboradData.value.customerDetail?.mobileNumber,
    );
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _remarksFocusNode.dispose();
    _nameController.dispose();
    _cnicController.dispose();
    _phoneController.dispose();
    _remarksController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        onPressed: () {
          CallWhatsappUtil.openCall1313();
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call, size: 20),
            SizedBox(width: 1.0),
            Text(
              '1313',
              style: TextStyle(fontSize: 13),
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
                mainAxisAlignment: .start,
                crossAxisAlignment: .start,
                spacing: 4,
                children: [
                  Text("Name", style: TextTheme.of(context).labelMedium),
                  const SizedBox(height: 4),
                  CupertinoTextField(
                    readOnly: true,
                    controller: _nameController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    ],

                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 4),
                  Text("CNIC", style: TextTheme.of(context).labelMedium),
                  CupertinoTextField(
                    readOnly: true,
                    controller: _cnicController,

                    inputFormatters: [
                      CnicMaskTextInputFormatter(),
                      FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z]')),
                    ],

                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Mobile Number",
                    style: TextTheme.of(context).labelMedium,
                  ),
                  CupertinoTextField(
                    readOnly: true,
                    maxLength: 11,
                    controller: _phoneController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  Text("Remarks", style: TextTheme.of(context).labelMedium),
                  CupertinoTextFormFieldRow(
                    autofocus: true,
                    validator: validateRemarks,
                    decoration: BoxDecoration(
                      border: .all(width: 0.3, color: Colors.grey),
                      borderRadius: .circular(4),
                    ),
                    padding: .zero,
                    onEditingComplete: () =>
                        FocusScope.of(context).requestFocus(_remarksFocusNode),
                    smartDashesType: SmartDashesType.enabled,
                    maxLines: 6,
                    focusNode: _remarksFocusNode,
                    controller: _remarksController,
                    placeholder: 'Enter details......',
                  ),
                  const SizedBox(height: 10),
                  const Spacer(flex: 6),
                  ElevatedButton1(isShowIcon: false,
                    backgroundColor: Theme.of(context).primaryColor,
                    width: MediaQuery.sizeOf(context).width,
                    onclick: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        await Get.find<UpdateEmailController>().addFeedBack(
                          cnic: _cnicController.text,
                          mobileNumber: _phoneController.text,
                          fullName: _nameController.text,
                          remarks: _remarksController.text.trim(),
                        );
                        _remarksController.clear();
                      }
                      return;
                    },
                    text: 'Submit Feedback',
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

String? validateRemarks(String? value) =>
    value == null || value.trim().isEmpty ? 'Enter details here' : null;
