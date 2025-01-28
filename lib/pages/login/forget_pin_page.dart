import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/auth_controller.dart';

import 'package:mtag_flutterapp/constants/input_formater.dart';

import '../../utils/utils.dart';



class ForgetPinPage extends StatelessWidget {
  ForgetPinPage({super.key});


  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final ValueNotifier<int> _authNotifier = ValueNotifier<int>(0);
final _formKey=GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Scaffold(
          appBar: AppBar(title: Text("Forgot PIN"),),
          resizeToAvoidBottomInset: false,
          backgroundColor: colorScheme.surface,
          body: Padding(
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.09,
            ),
            child: ValueListenableBuilder(
              valueListenable: _authNotifier,
              builder: (context, value, child) => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              

                 Form(key: _formKey,
                   child: Column(children: [ if (value == 1)
                      
                   
                    SizedBox(height: screenHeight * 0.02),
                   
                    TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CnicMaskTextInputFormatter()],
                      style: const TextStyle(height: 1),
                       validator: (v) {
                                 if (v == null || v.isEmpty||v.length<15) {
                                   return 'Please enter your CNIC';
                                 }
                                 return null; // No error
                               },
                      controller: _cnicController,
                      decoration: InputDecoration(
                        hintText: 'CNIC',
                      ),
                    ),
                   
                    SizedBox(height: screenHeight * 0.02),
                   
                    TextFormField(autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: numberInputFormatters,
                      maxLength: 11, validator: (v) {
                                 if (v == null || v.isEmpty||!v.startsWith('03')||v.length<11) {
                                   return 'Please enter your mobile number';
                                 }
                                 return null; // No error3740557163921
                               },
                      style: const TextStyle(height: 1),
                      controller: _phoneController,
                      decoration: InputDecoration(
                          hintText: 'Mobile Number', counterText: ""),
                    ),
                   
                    SizedBox(height: screenHeight * 0.02),  
                   
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: ()async {
                       if(_formKey.currentState?.validate()??false){
                          var release = await DeviceInfo.getDeviceInfo();
                      Get.find<AuthController>().login(cnic: _cnicController.text.trim(), mobileNumber: _phoneController.text.trim(),isForgetPin: 1, metaData: '"${Platform.isAndroid ? "Android" : 'iOS'} ""__"${release['release']} "__"${release['manufacturer']}""${release['model']} "__"android_id"__"fcmToken"__"3.1.4');

                       }
                          
                        },
                        child: CircleAvatar(
                          radius: 25,
                        
                          child: Icon(
                            Icons.keyboard_arrow_right_outlined,
                            size: 25,
                           
                          ),
                        ),
                      ),
                    )],),
                 ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
