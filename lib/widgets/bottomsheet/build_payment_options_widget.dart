// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/utils.dart';
import '../../widgets/dialog/cupertion_dialog.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import 'build_payment_card.dart';

class BuildPaymentOptionsWidget extends StatelessWidget {
   const BuildPaymentOptionsWidget({
    super.key,
    required this.selectedPaymentOption,
    required this.amount,
    required this.showPSIDField,
    required this.psidController,
    this.mtagId,
    this.regId,
    this.creditCode,
    this.jazzCode,
  });
  final ValueNotifier<int> selectedPaymentOption;
  final ValueNotifier<bool> showPSIDField;
  final String? mtagId, regId, jazzCode, creditCode;
  final TextEditingController amount;
  final TextEditingController? psidController;

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<int>(
      valueListenable: selectedPaymentOption,
      builder: (context, selectedOption, child) {

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero, // Align content to the left with zero padding
          children: [
            Text('Select Payment Method'),
            buildPaymentOption(
              selectedOptionNotifier: selectedPaymentOption,
              onTap: () async{
               if (validateAmount(amount.text) == null) {
                  log('Credit/Debit Card');
                   await      Get.toNamed(
                    '/recharge',
                    arguments: [ActiveMtags(tokenno: mtagId, registration: regId, amount: amount.text, payId: '0')],
                  );
                  selectedPaymentOption.value = -1;
                } else {
                  showPopDialog('Enter minimum  amount 50PKR', () {
                      selectedPaymentOption.value = -1;
                    Get.back();
                  });
                }
              },
              context,
              label: "Credit/Debit Card",
              value: 1,
              assetPath: 'assets/creditcard.png',
            ),
            Divider(
              height: 0.5,
              thickness: 0.3,
              indent: 10,
              endIndent: 10,
            ),
            buildPaymentOption(
  selectedOptionNotifier: selectedPaymentOption,
  onTap: () async {
    if (validateAmount(amount.text) == null) {
      log('JazzCash');
      await Get.toNamed(
        '/recharge',
        arguments: [ActiveMtags(tokenno: mtagId, registration: regId, amount: amount.text, payId: '1')],
      );
      // Reset the selection when returning back
      selectedPaymentOption.value = -1; // Reset to an unselected state
    } else {
      showPopDialog('Enter minimum amount 50PKR', () {
          selectedPaymentOption.value = -1;
        Get.back();
      });
    }
  },
  context,
  label: "JazzCash",
  value: 0,
  assetPath: 'assets/jazzcash.png',
),

            // Divider(
            //   height: 0.5,
            //   thickness: 0.3,
            //   indent: 10,
            //   endIndent: 10,
            // ),
            // buildPaymentOption(selectedOptionNotifier: selectedPaymentOption, onTap: () async {
            //   if (validateAmount(amount.text) == null) {
            //     log('Invoice/Generate PSID');
            //    var data = await Get.find<PaymentCardController>().generatePSID(
            //             mtagID: mtagId,
            //             amount: amount.text.isNotEmpty ? double.parse(amount.text) : 0,
            //             cnic: OtherConsts().ownerCNIC.value,
            //             mobileNum: OtherConsts().mobile.value,
            //             isBlocked: false,
            //             isInvoice: true,
            //           );

            //     if (context.mounted&&data.isNotEmpty) {
            //       showBreakdownDialog(psid:data['PSID'] ,
            //         context: context,
            //         amount: double.parse(amount.text),
            //         fee: double.parse(data['charges'].toString()),
            //         remaining: double.parse(amount.text) - double.parse(data['charges'].toString()),inVoicetimerNotifier: inVoicetimerNotifier
            //       );
            //        inVoicetimerNotifier.value = Duration(minutes: 10); // Set timer
            //           startTimer( inVoicetimerNotifier); 
            //     }
            //   } else {
            //     showPopDialog('Enter minimum  amount 50PKR.', () {
            //       selectedPaymentOption.value = -1;
            //       Get.back();
            //     });
            //   }
            // }, context,
            //     label: "Invoice/Generate PSID",
            //     value: 2,
            //     assetPath: 'assets/1linklogo.png',
            //      timerNotifier: inVoicetimerNotifier,
            //     ),
            // Divider(
            //   height: 0.5,
            //   thickness: 0.3,
            //   indent: 10,
            //   endIndent: 10,
            // ),
            // buildPaymentOption(
            //   selectedOptionNotifier: selectedPaymentOption,
            //   onTap: () async {
            //     var data = await Get.find<PaymentCardController>().generatePSIDTOPUP(
            //       mtagID: "14508105",
            //       cnic: OtherConsts().ownerCNIC.value,
            //       mobileNum: OtherConsts().mobile.value,
            //       isBlocked: false,
            //       isInvoice: false,
            //     );
            //     psidController?.text = data.toString();
            //     showPSIDField.value = true;
            //     topUptimerNotifier.value = Duration(minutes: 10); // Set timer
            //     startTimer( topUptimerNotifier); // Start countdown
            //     log('Top Up');
            //   },
            //   context,
            //   label: "Top Up",
            //   value: 3,
            //   assetPath: 'assets/1linklogo.png',
            //   timerNotifier:  topUptimerNotifier,
            // ),
            SizedBox(
              height: 20,
            ),
          ],
        );
      },
    );
  }
}
