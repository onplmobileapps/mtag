import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import 'package:mtag_flutterapp/widgets/amount_chipselector.dart';

import '../recharge_amount_field.dart';

class BuildRechargeSection extends StatelessWidget {
  const BuildRechargeSection({
    super.key,
    required this.amountController,
    required this.showPSIDField,
    required this.amountList,
    required this.formKey,
    this.creditCode,
    this.jazzCode,
    this.mtagId,
    this.regId,
    required this.blackListRecharge,
    this.recoveryAmount,
  });

  final TextEditingController amountController;
  final ValueListenable<bool> showPSIDField;
  final List<int> amountList;
  final GlobalKey<FormState> formKey;
  final String? mtagId, regId, jazzCode, creditCode;
  final bool blackListRecharge;
  final double? recoveryAmount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showPSIDField,
      builder: (context, isVisible, child) {
        if (isVisible) return Container();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Row(children: [Text('$regId-$mtagId')]),
              SizedBox(height: 15),
            Text(
              blackListRecharge ? "Recovery Amount" : "Recharge Amount",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: .w900,fontSize: 20),
            ),
          
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Form(
                key: formKey,
                child: RechargeAmountField(
                  isEnabled: blackListRecharge ? false : true,
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  controller: amountController,
                  hintText: blackListRecharge == true
                      ? "$recoveryAmount"
                      : "50",
                ),
              ),
            ),

            blackListRecharge
                ? Container()
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: AmountChipSelector(
                      amounts: AmountList.amountList,
                      controller: amountController,
                    ),
                  ),
          ],
        );
      },
    );
  }
}
