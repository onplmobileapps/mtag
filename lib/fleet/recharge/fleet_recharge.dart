import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../api/api_constants.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../pages/payment/model/payment_card_model.dart';

import '../../widgets/dialog/cupertino_dialog.dart';

class FleetRechargePage extends StatefulWidget {
  const FleetRechargePage({super.key});

  @override
  State<FleetRechargePage> createState() => _FleetRechargePageState();
}

class _FleetRechargePageState extends State<FleetRechargePage> {
  final _scrollController = ScrollController();
  final _scrollController1 = ScrollController();
  final _scrollController2 = ScrollController();
  final _scrollController3 = ScrollController();
  final companyId = Get.arguments;
  final _paymentController = Get.find<PaymentCardController>();
  final _amountController = TextEditingController();
  bool _isCardsVisible = false;

  bool isAddCard = false;
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();
  void _scrollLeft(ScrollController controller) {
    controller.animateTo(
      controller.offset - 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight(ScrollController controller) {
    controller.animateTo(
      controller.offset + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String maskString(String value) {
    if (value.isEmpty || value == '') {
      return '';
    }

    if (value.length == 11 || value.length == 19) {
      return value.substring(value.length - 4);
    }

    return '';
  }

  int _selectedCardIndex = -1;

  void _onCardTap(int index) {
    setState(() {
      _selectedCardIndex = index;
      isAddCard = false;
    });
  }

  PaymentCardModel _paymentCardModel = PaymentCardModel();
  Future<void> getPaymentCards(String payId) async {
    isLoading = true;

    if (mounted) setState(() {});
    _paymentCardModel.cardsData?.clear();
    var respones = await _paymentController.getCardDetails(payId);

    _paymentCardModel = PaymentCardModel.fromJson(respones[APIRESPONSE.SUCCESS]);

    if (payId == '0') {
      _isCardsVisible = true;
    }
    if (mounted) setState(() {});
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _scrollController.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recharge '),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController1,
        scrollDirection: Axis.vertical,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Company ID',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.redAccent),
                    ),
                    Text(
                      companyId.toString(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enter Amount',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.redAccent),
                    ),
                    const Text(
                      'Minimum recharge amount is Rs. 50000 ',
                      style: TextStyle(fontSize: 7, color: Colors.black),
                    )
                  ],
                ),
                TextFormField(
                  readOnly: false,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onFieldSubmitted: (value) {
                    if (value.isNotEmpty) {
                      if (double.parse(value) < 50000) {
                        return;
                      }
                    }
                  },
                  maxLength: 7,
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      if (double.parse(value) < 50000) {
                        return '*Minimum recharge amount is Rs. 50000';
                      }
                    }
                    return null;
                  },
                  controller: _amountController,
                  autofocus: true,
                  style: const TextStyle(height: 1),
                  decoration: const InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(fontSize: 17),
                      counterText: '',
                      border: InputBorder.none,
                      disabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: Colors.grey)),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: Colors.grey)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: Colors.grey)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.5, color: Colors.grey))),
                ),
                const SizedBox(
                  height: 5,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ["50,000", "1,00,000", "1,50,000", "2,00,000", "2,500,000", "300,000"]
                        .map((e) => InkWell(
                              onTap: () {
                                _amountController.text = e.toString().replaceAll(',', '');
                                FocusScope.of(context).unfocus();
                                return;
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                width: 70,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Theme.of(context).disabledColor,
                                    border: Border.all(width: 0.3)),
                                child: Center(
                                  child: Text(
                                    e.toString(),
                                    style: Theme.of(context).textTheme.displaySmall,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Recommended Payment Methods',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.redAccent,
                      ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 0.5,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate() && _amountController.text.isNotEmpty) {
                          getPaymentCards('0');

                          _isCardsVisible = true;

                          isAddCard = false;
                          FocusScope.of(context).unfocus();
                          return;
                        }
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/g13.svg',
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          const Text('Credit/Debit Card'),
                          const Spacer(),
                          const CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 9,
                            child: Icon(
                              Icons.done_rounded,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Visibility(
                  visible: _isCardsVisible,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (int.parse('${_paymentCardModel.cardsData?.length ?? 0}') > 1)
                        InkWell(
                          onTap: () => _scrollLeft(_scrollController2),
                          child: const Icon(
                            Icons.keyboard_arrow_left,
                          ),
                        ),
                      Expanded(
                          child: isLoading
                              ? Center(
                                  child: LoadingAnimationWidget.flickr(
                                    leftDotColor: Colors.white,
                                    rightDotColor: Theme.of(context).primaryColor,
                                    size: 30,
                                  ),
                                )
                              : SingleChildScrollView(
                                  padding: EdgeInsets.zero,
                                  controller: _scrollController2,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // New card widget
                                      InkWell(
                                        onTap: () async {
                                          if (_formKey.currentState!.validate() && _amountController.text.isNotEmpty) {
                                            await _paymentController.getRechargeSummary(
                                                isFleet: true,
                                                mtagId: companyId.toString(),
                                                payId: '0',
                                                amount: _amountController.text);

                                            return;
                                          }
                                          showPopDialog(
                                              _amountController.text.isEmpty ? 'Enter Amount' : 'Enter Valid Amount',
                                              () {
                                            Get.back();
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey, width: 0.5),
                                                  borderRadius: BorderRadius.circular(8)),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: SvgPicture.asset(
                                                      'assets/addnew.svg',
                                                      height: 30,
                                                      width: 60,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              'Add New +',
                                              style:
                                                  Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                          ],
                                        ),
                                      ),

                                      ..._paymentCardModel.cardsData?.asMap().entries.map((e) {
                                            return _paymentCardModel.cnt == 0
                                                ? Container()
                                                : Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      InkWell(
                                                        onTap: () async {
                                                          if (_formKey.currentState!.validate() &&
                                                              _amountController.text.isNotEmpty) {
                                                            _onCardTap(e.key);
                                                            await _paymentController.getRechargeSummary(
                                                                isFleet: true,
                                                                token: e.value.tOKEN,
                                                                mtagId: companyId.toString(),
                                                                payId: '0',
                                                                amount: _amountController.text);
                                                            return;
                                                          }
                                                          showPopDialog(
                                                              _amountController.text.isEmpty
                                                                  ? 'Enter Amount'
                                                                  : 'Enter Valid Amount', () {
                                                            Get.back();
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Container(
                                                                  margin: const EdgeInsets.all(10),
                                                                  decoration: BoxDecoration(
                                                                      border:
                                                                          Border.all(color: Colors.grey, width: 0.5),
                                                                      borderRadius: BorderRadius.circular(8)),
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            left: 35, right: 35, top: 18, bottom: 18),
                                                                        child: SvgPicture.asset(
                                                                          e.value.bRAND == 'MASTERCARD'
                                                                              ? 'assets/mastercard.svg' //'assets/g13.svg'
                                                                              : 'assets/visa-logo.svg',
                                                                          fit: BoxFit.fill,
                                                                          height: 25,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "Ends ${maskString(e.value.cARDNUMBER ?? '')}",
                                                                  style: Theme.of(context).textTheme.displaySmall,
                                                                ),
                                                                const SizedBox(
                                                                  height: 3,
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: 80,
                                                              width: 0.5,
                                                              color: Colors.grey,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            _selectedCardIndex == e.key ? Colors.green : Colors.grey,
                                                        radius: 9,
                                                        child: const Icon(
                                                          Icons.done_rounded,
                                                          size: 15,
                                                        ),
                                                      )
                                                    ],
                                                  );
                                          }).toList() ??
                                          [],
                                    ],
                                  ),
                                )),
                      if (int.parse('${_paymentCardModel.cardsData?.length ?? 0}') > 1)
                        InkWell(
                          onTap: () => _scrollRight(_scrollController2),
                          child: const Icon(
                            Icons.keyboard_arrow_right,
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 0.5,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
