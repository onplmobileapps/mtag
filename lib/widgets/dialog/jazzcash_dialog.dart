import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:mtag_flutterapp/widgets/elevated_button.dart';

import '../../pages/payment/controller/payment_card_controller.dart';

class JazzCashDialog extends StatelessWidget {
  JazzCashDialog({
    super.key,
    this.onConfirm,
    this.accountController,
    required this.amount,
    required this.mtagId,
  });
  final String amount;
  final String mtagId;
  final Function()? onConfirm;
  final TextEditingController? accountController;
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/jazzcash1.png',
                  width: 200.0,
                  height: 200.0,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Please enter a valid Jazz Cash account number using format 03XXXXXXXXX.\n\n2. Make sure you have sufficient balance in your Jazz Cash account.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.0, color: Color(0xFFF1AB16), fontFamily: "Poppins"),
                    ),
                    const SizedBox(height: 10.0),
                    // Add the TextInputLayout widget here

                    const Text(
                      'Press Yes to Continue , No to Cancel',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.0, color: Color(0xFFF1AB16), fontFamily: "Poppins"),
                    ),
                    const SizedBox(height: 15.0),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value!.isEmpty || value.length < 11 || !value.startsWith('03')) {
                          return 'Enter valid Jazzcash Number';
                        }
                        return null;
                      },
                      controller: accountController,
                      onTapOutside: (event) {
                        FocusScope.of(context).unfocus();
                      },
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          color: Colors.black, fontSize: 16.0, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                      maxLines: 1,
                      maxLength: 11,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          enabled: true,
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          hintText: 'Enter Jazz Cash Number',
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14.0, fontFamily: "Poppins")),
                    )
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton1(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      width: 100,
                      text: 'No',
                      onclick: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 20.0),
                    ElevatedButton1(
                        width: 100,
                        onclick: () async {
                          if (formKey.currentState!.validate()) {
                            Get.back();
                            await Get.find<PaymentCardController>().jazzCashRecharge(
                                mobile: accountController?.text, amount: amount.toString(), mtagId: mtagId);
                          }
                        },
                        text: 'Yes'),
                    const SizedBox(width: 20.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
