import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/pages/recharge/recharge_page.dart';

import '../../api/api_constants.dart';
import '../../constants/other_consts.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../utils/utils.dart';
import '../dialog/cupertino_dialog.dart';
import '../dialog/breakdown_dialog.dart';
import 'bottom_sheet_widget.dart';
import 'build_payment_card.dart';

class BuildPaymentOptionsWidget extends StatelessWidget {
  BuildPaymentOptionsWidget({
    super.key,
    required this.amount,
    required this.showPSIDField,
    required this.psidController,
    this.mtagId,
    this.regId,
    this.creditCode,
    this.jazzCode,
    this.onChanged,
    this.isfromMainPage = false,
    required this.blackListRecharge,
    this.recoveryAmount,
  });

  final ValueNotifier<bool> showPSIDField;
  final String? mtagId, regId, jazzCode, creditCode;
  final TextEditingController amount;
  final TextEditingController? psidController;
  final Function(int paymentMethod)? onChanged;
  final bool? isfromMainPage;
  final _otherConstants = OtherConsts();
  final bool blackListRecharge;
  final double? recoveryAmount;

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<int>(
      valueListenable: selected1linkOpt,
      builder: (context, selectedOption, child) {
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Text(
              'Recommended Payment Methods',
              style: TextTheme.of(context).labelLarge,
            ),
            const SizedBox(height: 5),
            _buildPaymentOption(
              context: context,
              label: "Invoice/Generate PSID",
              value: 0,
              assetPath: 'assets/1linklogo.png',
              timerNotifier: inVoicetimerNotifier,
              onTap: () async {
                if (mtagId == null || mtagId == '' || mtagId!.length < 8) {
                  showPopDialog('Select M-Tag / Enter M-Tag', () {
                    selected1linkOpt.value = -1;
                    Get.back();
                  });
                  return;
                }
                var data = await Get.find<PaymentCardController>().generatePSID(
                  mtagID: mtagId,
                  amount: blackListRecharge
                      ? recoveryAmount! + calculateCharges(recoveryAmount)
                      : double.parse(amount.text),
                  cnic: OtherConsts().ownerCNIC.value,
                  mobileNum: OtherConsts().mobile.value,
                  isBlocked: blackListRecharge ? true : false,
                  isInvoice: true,
                );

                if (context.mounted && (data.containsKey('PSID'))) {
                  final fee =
                      double.tryParse(data['charges'].toString()) ?? 0.0;
                  final enteredAmount = double.tryParse(amount.text) ?? 0.0;
                  final effectiveAmount = blackListRecharge
                      ? (recoveryAmount ?? 0.0)
                      : enteredAmount;

                  showBreakdownDialog(
                    psid: data['PSID'],
                    context: context,
                    amount: effectiveAmount,
                    fee: fee,
                    remaining: blackListRecharge
                        ? effectiveAmount + fee
                        : effectiveAmount - fee,
                    inVoicetimerNotifier: inVoicetimerNotifier,
                    blackListRecharge: blackListRecharge,
                  );

                  inVoicetimerNotifier.value = Duration(minutes: 10);
                  startTimer(inVoicetimerNotifier);
                  return;
                }
                if (context.mounted && data.containsKey(APIRESPONSE.ERROR)) {
                  log('error data==>$data');
                  showPopDialog(data[APIRESPONSE.ERROR]['Message'], () {
                    selected1linkOpt.value = -1;
                    data[APIRESPONSE.ERROR]['Code'] == 450
                        ? Get.offAllNamed('/pinPage')
                        : Get.back();
                  });
                }
              },
            ),
            blackListRecharge == false
                ? _buildPaymentOption(
                    context: context,
                    label: "Top Up",
                    value: 1,
                    assetPath: 'assets/1linklogo.png',
                    timerNotifier: topUptimerNotifier,
                    onTap: () async {
                      if (mtagId == null ||
                          mtagId == '' ||
                          mtagId!.length < 8) {
                        showPopDialog('Select M-Tag / Enter M-Tag', () {
                          selected1linkOpt.value = -1;
                          Get.back();
                        });
                        return;
                      }
                      var data = await Get.find<PaymentCardController>()
                          .generatePSIDTOPUP(
                            mtagID: mtagId,
                            cnic: OtherConsts().ownerCNIC.value,
                            mobileNum: OtherConsts().mobile.value,
                            isBlocked: blackListRecharge ? true : false,
                            isInvoice: false,
                          );

                      if (context.mounted &&
                          data.containsKey(APIRESPONSE.SUCCESS)) {
                        showTopUpDialog(
                          psid: data[APIRESPONSE.SUCCESS]['Data'],
                          context: context,
                          amount: blackListRecharge
                              ? recoveryAmount
                              : double.parse(amount.text),

                          inVoicetimerNotifier: topUptimerNotifier,
                          blackListRecharge: blackListRecharge,
                        );
                        psidController?.text = data[APIRESPONSE.SUCCESS]['Data']
                            .toString();
                        topUptimerNotifier.value = Duration(minutes: 10);
                        startTimer(topUptimerNotifier);
                        return;
                      }
                      if (data.containsKey(APIRESPONSE.ERROR)) {
                        showPopDialog(data[APIRESPONSE.ERROR]['Message'], () {
                          selected1linkOpt.value = -1;
                          Get.back();
                        });
                      }
                    },
                  )
                : Container(),
            _otherConstants.jazzCode.value == 1 && blackListRecharge == false
                ? _buildPaymentOption(
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
                          ),
                        ],
                      );

                      if (onChanged != null) {
                        onChanged!(1); // Call only if onChanged is not null
                      }

                      selected1linkOpt.value = 2;
                    },
                  )
                : Container(),
            _otherConstants.creditCode.value == 1 && blackListRecharge == false
                ? _buildPaymentOption(
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
                          ),
                        ],
                      );
                      if (onChanged != null) {
                        onChanged!(0);
                      }

                      selected1linkOpt.value = 3;
                    },
                  )
                : Container(),
            
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
          selectedOptionNotifier: selected1linkOpt,
          onTap: () {
            if (blackListRecharge || isAmountValid(amount.text)) {
              onTap();
            } else {
              showPopDialog('Enter a minimum amount of 50 PKR.', () {
                selected1linkOpt.value = -1;
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
        Divider(height: 4, thickness: 0.2, indent: 15, endIndent: 10),
      ],
    );
  }
}

bool isAmountValid(String amount) {
  final parsedAmount = double.tryParse(amount) ?? 0;
  return parsedAmount >= 50;
}

double calculateCharges(double? amount) {
  if (amount! > 0 && amount <= 10000) {
    return 10;
  } else if (amount > 10000 && amount <= 100000) {
    return 25;
  } else if (amount > 100000 && amount <= 250000) {
    return 62.50;
  } else if (amount > 250000 && amount <= 1000000) {
    return 125;
  } else if (amount > 1000000 && amount <= 2500000) {
    return 250;
  } else if (amount > 2500000 && amount <= 5000000) {
    return 375;
  } else if (amount > 5000000) {
    return 375;
  } else {
    return 0;
  }
}
