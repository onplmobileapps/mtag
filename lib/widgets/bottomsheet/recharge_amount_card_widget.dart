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
  });
  final TextEditingController amountController;
  final ValueListenable<bool> showPSIDField;
  final List<int> amountList;
  final GlobalKey<FormState> formKey;
  final String? mtagId, regId, jazzCode, creditCode;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: showPSIDField,
      builder: (context, isVisible, child) {
        if (isVisible) return Container();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text('$regId-$mtagId'),
              ],
            ),
            Text(
              "Recharge Amount",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Form(
                key: formKey,
                child: RechargeAmountField(
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  controller: amountController,
                  hintText: "50",
                ),
              ),
            ),
            // 23
            SingleChildScrollView(scrollDirection: Axis.horizontal,
              child: AmountChipSelector(amounts: AmountList.amountList, controller: amountController,
              ),
            ),
          ],
        );
      },
    );
  }
}
