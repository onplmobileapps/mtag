import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
                  hintText: "0",
                ),
              ),
            ),
            // 23
            Wrap(
              spacing: 4,
              children: amountList
                  .map((amount) => GestureDetector(
                        onTap: () => amountController.text = amount.toString(),
                        child: Chip(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4), // Adds balanced padding
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          backgroundColor: Colors.transparent, // To show gradient
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Smooth rounded corners
                            side: BorderSide(color: Theme.of(context).primaryColor, width: 0.5), // Optional border
                          ),
                          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                          label: Text(
                            "$amount",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          elevation: 4,
                          avatar: CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  Theme.of(context).primaryColor, // Add an avatar or an icon for better aesthetics
                              child: Text(
                                'Rs',
                                style: TextStyle(color: Colors.white, fontSize: 9),
                              )),
                        ),
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
