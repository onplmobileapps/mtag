import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/controller/home_controller.dart';
import 'package:mtag_flutterapp/pages/recharge/shared/card_shared_ui.dart';
import 'package:mtag_flutterapp/remoteconfig/firebase_remote_config.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import 'package:mtag_flutterapp/widgets/amount_chipselector.dart';
import 'package:mtag_flutterapp/widgets/bottomsheet/build_payment_options_widget.dart';
import 'package:mtag_flutterapp/widgets/dialog/cupertion_dialog.dart';
import '../../api/api_constants.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../pages/payment/model/payment_card_model.dart';
import '../../widgets/mtag_card_widget.dart';
import '../../widgets/textform_widget.dart';
import '../dashboard/model/dashboard_model.dart';

ValueNotifier<String> psidnumber = ValueNotifier<String>('');
final ValueNotifier<int> selected1linkOpt = ValueNotifier(-1);

class RechargeSelfPage extends StatefulWidget {
  RechargeSelfPage({super.key});

  final List<ActiveMtags> arguments = Get.arguments is List<ActiveMtags>
      ? Get.arguments as List<ActiveMtags>
      : Get.arguments is ActiveMtags
          ? [Get.arguments as ActiveMtags]
          : [ActiveMtags()];

  @override
  State<RechargeSelfPage> createState() => _RechargeSelfPageState();
}

class _RechargeSelfPageState extends State<RechargeSelfPage> {
  final _scrollController = ScrollController();
  final _scrollController1 = ScrollController();
  final _scrollController2 = ScrollController();
  final _scrollController3 = ScrollController();

  final _paymentController = Get.find<PaymentCardController>();
  final _amountController = TextEditingController();

  final ValueNotifier<bool> _showPsidFiled = ValueNotifier(false);

  bool _isRechargeOtherTextFieldVisible = false;
  final TextEditingController _textController = TextEditingController();

  bool isAddCard = false;
  bool isLoading = false;
  final _jazzCashController = TextEditingController();
  String? _selectedMtag;

  final _formKey = GlobalKey<FormState>();

  void _toggleTextField() {
    setState(() {
      _isRechargeOtherTextFieldVisible = true;
    });
  }

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

  int _selectedPayment = -1;

  int _selectedMtagIndex = -1;

  void _onMTagTap(int index, String value, bool otherMtagField) {
    _selectedMtagIndex = index;
    _selectedMtag = value;
    setState(() {});
  }

  void _setPayment(int index) {
    _selectedPayment = index;
    setState(() {});
  }

  PaymentCardModel _paymentCardModel = PaymentCardModel();
  Future<void> getPaymentCards(String payId) async {
    isLoading = true;

    if (mounted) setState(() {});
    _paymentCardModel.cardsData?.clear();
    var respones = await _paymentController.getCardDetails(payId);

    _paymentCardModel =
        PaymentCardModel.fromJson(respones[APIRESPONSE.SUCCESS]);
    if (payId == '1') {}
    if (payId == '0') {}
    if (mounted) setState(() {});
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isCardsVisible.value = false;
      isJazzShown.value = false;
      if (widget.arguments.length == 1) {
        _selectedMtagIndex = 0;
        _selectedMtag = widget.arguments.first.tokenno;
      }
      if (widget.arguments.isNotEmpty) {
        _amountController.text = widget.arguments.first.amount ?? '';
      } else {
        _amountController.text = ''; // Provide a fallback
      }
      if (widget.arguments.isNotEmpty && widget.arguments.first.payId != null) {
        _selectedMtagIndex = 0;
        _selectedMtag = widget.arguments.first.tokenno;
        log('here');
        getPaymentCards('${widget.arguments.first.payId}');
        if (widget.arguments.first.payId == '1') {
          isCardsVisible.value = true;
          _setPayment(2);
        } else if (widget.arguments.first.payId == '0') {
          isCardsVisible.value = true;
          _setPayment(1);
        }
      }
      FirebaseRemoteConfigService().fetchRemoteConfig();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _jazzCashController.dispose();
    _scrollController.dispose();
    _scrollController2.dispose();
    _scrollController3.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        selected1linkOpt.value = -1;

        // Close bottom sheet if it's open
        Navigator.of(context).canPop();

        return;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Recharge M-Tag'),
        ),
        body: Container(
          constraints: const BoxConstraints.expand(),
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          color: Theme.of(context).primaryColor,
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                controller: _scrollController1,
                scrollDirection: Axis.vertical,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Mtag/Vehicle',
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.redAccent),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (int.parse('${widget.arguments.length}') > 2)
                            InkWell(
                              onTap: () => _scrollLeft(_scrollController),
                              child: const Icon(
                                Icons.keyboard_arrow_left,
                              ),
                            ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...widget.arguments.map((item) {
                                    int itemIndex =
                                        widget.arguments.indexOf(item);
                                    return MTagCard(
                                      index: itemIndex,
                                      token: item.tokenno ?? '',
                                      registration: item.registration ?? '',
                                      isSelected:
                                          _selectedMtagIndex == itemIndex,
                                      onTap: () {
                                        _onMTagTap(itemIndex,
                                            item.tokenno ?? '', false);
                                        _isRechargeOtherTextFieldVisible =
                                            false;
                                      },
                                    );
                                  }),
                                  MTagCard(
                                    index: widget.arguments.length,
                                    token: 'Other M-TAG',
                                    registration: 'Recharge',
                                    isSelected: _selectedMtagIndex ==
                                        widget.arguments.length,
                                    onTap: () {
                                      _onMTagTap(
                                          widget.arguments.length, '', true);
                                      _toggleTextField();
                                    },
                                  ),
                                  if (int.parse('${widget.arguments.length}') >
                                      2)
                                    InkWell(
                                      onTap: () =>
                                          _scrollRight(_scrollController),
                                      child: const Icon(
                                        Icons.keyboard_arrow_right_outlined,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isRechargeOtherTextFieldVisible) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: CustomTExtField(
                                  controller: _textController,
                                  hint: "Enter M-Tag Id",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  textInputAction: TextInputAction.done,
                                  fillColor: Theme.of(context).primaryColorDark,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: false),
                                  maxLength: 8,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9]'))
                                  ],
                                  validator: validateMtag,
                                  onChanged: (v) {
                                    _selectedMtag = _textController.text.trim();
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: _showPsidFiled,
                        builder: (context, value, child) => (!value)
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Enter Amount',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(color: Colors.redAccent),
                                      ),
                                      Text(
                                        'Min value is Rs. ${Get.find<HomeController>().dashboradData.value.rechargeMinAmount} & Max is Rs.${Get.find<HomeController>().dashboradData.value.rechargeMaxAmount}',
                                        style: const TextStyle(
                                            fontSize: 7, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  CustomTExtField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            signed: true, decimal: false),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onFieldSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        if (double.parse(value) > 10000 ||
                                            double.parse(value) < 50) {
                                          return;
                                        }
                                      }
                                    },
                                    maxLength: 8,
                                    validator: validateAmount,
                                    controller: _amountController,
                                    style: const TextStyle(height: 1),
                                    hint: '50',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: AmountChipSelector(
                                          amounts: AmountList.amountList,
                                          controller: _amountController)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                      ),
                      BuildPaymentOptionsWidget(
                        onChanged: (paymentMethod) {
                          if (_selectedMtag == null ||
                              _selectedMtag == '' ||
                              _selectedMtag!.length < 8) {
                            showPopDialog('Select M-Tag / Enter M-Tag', () {
                              Get.back();
                            });
                            return;
                          }
                          _selectedPayment = paymentMethod;
                          _setPayment(paymentMethod == 1 ? 2 : 1);
                          getPaymentCards(paymentMethod.toString());
                          isCardsVisible.value =
                              paymentMethod == 0 || paymentMethod == 1
                                  ? true
                                  : false;
                          isCardsVisible.value == true
                              ? isJazzShown.value = false
                              : false;

                          setState(() {});
                        },
                        amount: _amountController,
                        showPSIDField: _showPsidFiled,
                        psidController: TextEditingController(),
                        creditCode: '',
                        jazzCode: '',
                        mtagId: _selectedMtag,
                      ),
                      CardSharedUi(
                        cardListData: _paymentCardModel.cnt == 0
                            ? []
                            : _paymentCardModel.cardsData,
                        loading: isLoading,
                        payId: _selectedPayment,
                        paymentHead: _selectedPayment == 2
                            ? 'JazzCash'
                            : _selectedPayment == 1
                                ? 'Credit/Debit Card'
                                : '',
                        mtagId: _selectedMtag,
                        amount: _amountController.text,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
