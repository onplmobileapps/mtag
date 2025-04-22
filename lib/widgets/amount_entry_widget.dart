import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import '../../constants/analytics.dart';

import '../constants/input_formater.dart';
import '../controller/home_controller.dart';

class AmountWidget extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String v) amountChange;
  AmountWidget(
      {super.key, required this.amountChange, required this.controller});
  final _formKey = GlobalKey<FormState>();

  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).disabledColor,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recharge Amount',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Text(
                        'PKR',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      Flexible(
                        child: TextFormField(
                          controller: controller?..text = '0',
                          onTapOutside: (event) {},
                          inputFormatters: numberInputFormatters,
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: (v) {},
                          onFieldSubmitted: (value) {
                            if (value.isNotEmpty) {
                              if (double.parse(value) >
                                      int.parse(
                                          ' ${Get.find<HomeController>().dashboradData.value.rechargeMaxAmount}') ||
                                  double.parse(value) <
                                      int.parse(
                                          ' ${Get.find<HomeController>().dashboradData.value.rechargeMinAmount}')) {
                                return;
                              }
                            }
                            amountChange(value);
                          },
                          validator: validateAmount,
                          focusNode: _focusNode,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: false),
                          textInputAction: TextInputAction.next,
                          maxLength: 8,
                          cursorHeight: 25,
                          style: TextStyle(
                            fontSize:
                                MediaQuery.textScalerOf(context).scale(30),
                            height: 1,
                          ),
                          decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                  fontSize: MediaQuery.textScalerOf(context)
                                      .scale(30)),
                              counterText: '',
                              errorStyle: const TextStyle(
                                height: 1,
                                color: Colors.red,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.only(top: 5, right: 5)),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          //Wrap(

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              children: AmountList.amountList
                  .map((e) => InkWell(
                        onTap: () {
                          Analytics.rechargeAmountSelected(e.toString());
                          controller?.text = e.toString();
                          amountChange(e.toString());
                        },
                        child: Chip(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4), // Adds balanced padding
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          backgroundColor:
                              Colors.transparent, // To show gradient
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                12), // Smooth rounded corners
                            side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 0.5), // Optional border
                          ),
                          labelStyle:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                          label: Text(
                            "$e",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          elevation: 4,
                          avatar: CircleAvatar(
                              radius: 10,
                              backgroundColor: Theme.of(context)
                                  .primaryColor, // Add an avatar or an icon for better aesthetics
                              child: Text(
                                'Rs',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 9),
                              )),
                        ),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '* Note : Enter an amount between PKR 50 and PKR 10000.',
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
