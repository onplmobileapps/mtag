import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import '../../widgets/bottomsheet/build_payment_options_widget.dart';

import 'build_header_widet.dart';
import 'psid_widget.dart';
import 'recharge_amount_card_widget.dart';

final ValueNotifier<Duration> inVoicetimerNotifier = ValueNotifier(
  Duration(minutes: 0),
);
final ValueNotifier<Duration> topUptimerNotifier = ValueNotifier(
  Duration(minutes: 0),
);

class PaymentBottomSheet extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController? psidController;
  static final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> showPSIDField;
  final ValueNotifier<int> selectedPaymentOption;
  final List<int> amountList;
  final VoidCallback onCopyPSID;
  final String? mtagId, regId, jazzCode, creditCode;
  final bool blackListRecharge;
  final double? recoveryAmount;

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
    required this.blackListRecharge,
    this.recoveryAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(12),
        gradient: Theme.of(context).extension<AppGradients>()!.background,
      ),
      padding: .symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHandleBar(context),
          
          BuildPSIDField(
            key: ValueKey('PSID'),
            showPSIDField: showPSIDField,
            psidController: psidController,
            onCopyPSID: onCopyPSID,
          ),
          BuildRechargeSection(
            key: ValueKey('Recharge Key'),
            amountController: amountController,
            showPSIDField: showPSIDField,
            formKey: _formKey,
            amountList: amountList,
            regId: regId,
            mtagId: mtagId,
            jazzCode: jazzCode,
            creditCode: creditCode,
            blackListRecharge: blackListRecharge,
            recoveryAmount: recoveryAmount,
          ),
          BuildPaymentOptionsWidget(
            key: ValueKey('payment options'),
            mtagId: mtagId,
            regId: regId,
            creditCode: creditCode,
            jazzCode: jazzCode,
            psidController: psidController,
            showPSIDField: showPSIDField,
            amount: amountController..text,
            blackListRecharge: blackListRecharge,
            recoveryAmount: recoveryAmount,
          ),
          
        ],
      ),
    );
  }
}
