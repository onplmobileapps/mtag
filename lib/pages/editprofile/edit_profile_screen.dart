import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../api/api_constants.dart';
import '../../constants/analytics.dart';
import '../../constants/other_consts.dart';
import '../../pages/editprofile/controller/update_emai_controller.dart';
import '../../constants/input_formater.dart';
import '../../widgets/elevated_button.dart';
import '../../widgets/textform_widget.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final customerDetailsController = Get.find<UpdateEmailController>();

  final _nameFocusNode = FocusNode(),
      _passwordFocusNode = FocusNode(),
      _confirmPassFocusNode = FocusNode(),
      _emailFocusNode = FocusNode();

  static final _formKey = GlobalKey<FormState>();
  final _otherConstants = OtherConsts();

  @override
  Widget build(BuildContext context) {
    Analytics.profileScreenDisplayed();
    var size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile Details'),
      ),
      body: Obx(
        () => Container(
          constraints: const BoxConstraints.expand(),
          width: size.width,
          height: size.height,
          color: Theme.of(context).primaryColor,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadiusDirectional.only(
                topEnd: Radius.circular(15),
                topStart: Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      customerDetailsController
                          .getInitials(_otherConstants.ownerName.value)
                          .toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 50,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: CustomScrollView(
                    shrinkWrap: true,
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate(
                          addRepaintBoundaries: false,
                          [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.sizeOf(context).width / 9),
                              child: Form(
                                key: _formKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      onTapOutside: (p0) =>
                                          FocusScope.of(context).unfocus(),
                                      autoFocus: true,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[a-zA-Z ]'))
                                      ],
                                      controller: customerDetailsController
                                          .nameController,
                                      focusNode: _nameFocusNode,
                                      label: 'FULL NAME',
                                      keyboardType: TextInputType.name,
                                      validator: (value) {
                                        if (value!.isEmpty ||
                                            value.length < 3) {
                                          return 'Please enter FULL NAME';
                                        } else if (RegExp(r'\s{2,}')
                                            .hasMatch(value)) {
                                          return 'Username must not have multiple spaces';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      textInputAction: TextInputAction.next,
                                      controller: customerDetailsController
                                          .cnicController,
                                      inputFormatters: [
                                        CnicMaskTextInputFormatter(),
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'[a-zA-Z]'))
                                      ],
                                      label: 'CNIC',
                                      keyboardType: TextInputType.number,
                                      enabled: false,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      textInputAction: TextInputAction.next,
                                      maxLength: 11,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      controller: customerDetailsController
                                          .phoneController,
                                      label: 'MOBILE NUMBER',
                                      enabled: false,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      controller: customerDetailsController
                                          .emailController,
                                      focusNode: _emailFocusNode,
                                      label: 'EMAIL',
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter EMAIL';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      textInputAction: TextInputAction.next,
                                      controller: customerDetailsController
                                          .passwordController,
                                      focusNode: _passwordFocusNode,
                                      label: 'PASSWORD',
                                      obscure: true,
                                      keyboardType:
                                          TextInputType.visiblePassword,
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      textInputAction: TextInputAction.done,
                                      onTapOutside: (p0) {
                                        FocusScope.of(context).unfocus();
                                      },
                                      controller: customerDetailsController
                                          .confirmPassController,
                                      focusNode: _confirmPassFocusNode,
                                      validator: (v) {
                                        if (v !=
                                            customerDetailsController
                                                .passwordController.text) {
                                          return 'Password and Confirm Password is not same.';
                                        }
                                        return null;
                                      },
                                      label: 'CONFIRM PASSWORD',
                                      obscure: true,
                                      keyboardType: TextInputType.text,
                                    ),
                                    const SizedBox(height: 50),
                                    ElevatedButton1(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      width: double.infinity,
                                      onclick: () async {
                                        if (_formKey.currentState!.validate()) {
                                          var response = await Get.find<
                                                  UpdateEmailController>()
                                              .updateEmail(
                                            email: customerDetailsController
                                                .emailController.text
                                                .trim(),
                                            fullName: customerDetailsController
                                                .nameController.text
                                                .trim(),
                                            password: customerDetailsController
                                                .passwordController.text
                                                .trim(),
                                          );
                                          if (response.containsKey(
                                              APIRESPONSE.SUCCESS)) {
                                            _otherConstants.ownerName.value =
                                                customerDetailsController
                                                    .nameController.text
                                                    .trim();
                                          }
                                        }
                                      },
                                      text: 'Update',
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
