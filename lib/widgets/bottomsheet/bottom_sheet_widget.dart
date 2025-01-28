import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/widgets/bottomsheet/build_payment_options_widget.dart';

import 'build_header_widet.dart';
import 'psid_widget.dart';
import 'recharge_amount_card_widget.dart';

final ValueNotifier<Duration> inVoicetimerNotifier = ValueNotifier(Duration(minutes: 0));
final ValueNotifier<Duration> topUptimerNotifier = ValueNotifier(Duration(minutes: 0));

//
class PaymentBottomSheet extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController? psidController;
  static final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> showPSIDField;
  final ValueNotifier<int> selectedPaymentOption;
  final List<int> amountList;
  final VoidCallback onCopyPSID;
  final String? mtagId, regId, jazzCode, creditCode;

  const PaymentBottomSheet({
    super.key,
    required this.amountController,
    required this.showPSIDField,
    required this.selectedPaymentOption,
    required this.amountList,
    required this.onCopyPSID,
    this.psidController,
    this.mtagId,
    this.regId,
    this.creditCode,
    this.jazzCode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        children: [
          buildHandleBar(context),
          BuildPSIDField(
            showPSIDField: showPSIDField,
            psidController: psidController,
            onCopyPSID: onCopyPSID,
          ),
          BuildRechargeSection(
            amountController: amountController,
            showPSIDField: showPSIDField,
            formKey: _formKey,
            amountList: amountList,
            regId: regId,
            mtagId: mtagId,
            jazzCode: jazzCode,
            creditCode: creditCode,
          ),
          BuildPaymentOptionsWidget(mtagId: mtagId,regId: regId,creditCode: creditCode,jazzCode: jazzCode,
            psidController: psidController,
            showPSIDField: showPSIDField,
            selectedPaymentOption: selectedPaymentOption,
            amount: amountController..text,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
