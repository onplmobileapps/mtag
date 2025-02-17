import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/other_consts.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../utils/utils.dart';
import '../../widgets/dialog/cupertion_dialog.dart';
import '../dialog/breakdown_dialog.dart';
import 'bottom_sheet_widget.dart';
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
          padding: EdgeInsets.zero,
          children: [
            Text('Select Payment Method'),
            _buildPaymentOption(
              context: context,
              label: "Invoice/Generate PSID",
              value: 2,
              assetPath: 'assets/1linklogo.png',
              timerNotifier: inVoicetimerNotifier,
              onTap: () async {
                var data = await Get.find<PaymentCardController>().generatePSID(
                  mtagID: mtagId,
                  amount: double.parse(amount.text),
                  cnic: OtherConsts().ownerCNIC.value,
                  mobileNum: OtherConsts().mobile.value,
                  isBlocked: false,
                  isInvoice: true,
                );

                if (context.mounted && data.isNotEmpty) {
                  showBreakdownDialog(
                    psid: data['PSID'],
                    context: context,
                    amount: double.parse(amount.text),
                    fee: double.parse(data['charges'].toString()),
                    remaining: double.parse(amount.text) -
                        double.parse(data['charges'].toString()),
                    inVoicetimerNotifier: inVoicetimerNotifier,
                  );
                  inVoicetimerNotifier.value = Duration(minutes: 10);
                  startTimer(inVoicetimerNotifier);
                }
              },
            ),
            _buildPaymentOption(
              context: context,
              label: "Top Up",
              value: 3,
              assetPath: 'assets/1linklogo.png',
              timerNotifier: topUptimerNotifier,
              onTap: () async {
                var data =
                    await Get.find<PaymentCardController>().generatePSIDTOPUP(
                  mtagID: mtagId,
                  cnic: OtherConsts().ownerCNIC.value,
                  mobileNum: OtherConsts().mobile.value,
                  isBlocked: false,
                  isInvoice: false,
                );

                if (data.isNotEmpty) {
                  psidController?.text = data.toString();
                  showPSIDField.value = true;
                  topUptimerNotifier.value = Duration(minutes: 10);
                  startTimer(topUptimerNotifier);
                }
              },
            ),
            _buildPaymentOption(
              context: context,
              label: "JazzCash",
              value: 2,
              assetPath: 'assets/jazzcash.png',
              onTap: () async {
                await Get.toNamed(
                  '/recharge',
                  arguments: [
                    ActiveMtags(
                      tokenno: mtagId,
                      registration: regId,
                      amount: amount.text,
                      payId: '1',
                    )
                  ],
                );
                selectedPaymentOption.value = -1;
              },
            ),
            _buildPaymentOption(
              context: context,
              label: "Credit/Debit Card",
              value: 3,
              assetPath: 'assets/creditcard.png',
              onTap: () async {
                await Get.toNamed(
                  '/recharge',
                  arguments: [
                    ActiveMtags(
                      tokenno: mtagId,
                      registration: regId,
                      amount: amount.text,
                      payId: '0',
                    )
                  ],
                );
                selectedPaymentOption.value = -1;
              },
            ),
            SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String label,
    required int value,
    required String assetPath,
    required VoidCallback onTap,
    ValueNotifier<Duration>? timerNotifier,
  }) {
    return Column(
      children: [
        buildPaymentOption(
          selectedOptionNotifier: selectedPaymentOption,
          onTap: () {
            if (isAmountValid(amount.text)) {
              onTap();
            } else {
              showPopDialog('Enter a minimum amount of 50 PKR.', () {
                selectedPaymentOption.value = -1;
                Get.back();
              });
            }
          },
          context,
          label: label,
          value: value,
          assetPath: assetPath,
          timerNotifier: timerNotifier,
        ),
        Divider(height: 0.5, thickness: 0.3, indent: 10, endIndent: 10),
      ],
    );
  }
}

bool isAmountValid(String amount) {
  final parsedAmount = double.tryParse(amount) ?? 0;
  return parsedAmount >= 50; // Ensure amount is 50 or more
}