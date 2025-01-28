import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mtag_flutterapp/constants/other_consts.dart';
import 'package:mtag_flutterapp/controller/home_controller.dart';
import 'package:mtag_flutterapp/remoteconfig/firebase_remote_config.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import '../../api/api_constants.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../pages/payment/model/payment_card_model.dart';
import '../../widgets/dialog/cupertion_dialog.dart';
import '../../widgets/mtag_card_widget.dart';
import '../../widgets/textform_widget.dart';
import '../dashboard/model/dashboard_model.dart';

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
  bool _isCardsVisible = false;
  bool _isJazzCashVisible = false;
  final _otherConsts = OtherConsts();

  bool isAddCard = false;
  bool isLoading = false;
  final _jazzCashController = TextEditingController();
  String? _selectedMtag;

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

  int _selectedPayment = -1;
  int _selectedCardIndex = -1;
  int _selectedMtagIndex = -1;
  int _selectedJazzCard = -1;

  void _onCardTap(int index) {
    setState(() {
      _selectedCardIndex = index;
      isAddCard = false;
    });
  }

  void _onMTagTap(int index, String value) {
    _selectedMtagIndex = index;

    _selectedMtag = value;
    setState(() {});
  }

  void _setPayment(int index) {
    _selectedJazzCard = -1;
    _selectedPayment = index;
    setState(() {});
  }

  void _setJazzCash(int index) {
    _selectedJazzCard = index;
    isAddCard = false;
    setState(() {});
  }

  PaymentCardModel _paymentCardModel = PaymentCardModel();
  Future<void> getPaymentCards(String payId) async {
    isLoading = true;

    if (mounted) setState(() {});
    _paymentCardModel.cardsData?.clear();
    var respones = await _paymentController.getCardDetails(payId);
  
    _paymentCardModel = PaymentCardModel.fromJson(respones[APIRESPONSE.SUCCESS]);
    if (payId == '1') {
      _isJazzCashVisible = true;
    }
    if (payId == '0') {
      _isCardsVisible = true;
    }
    if (mounted) setState(() {});
    isLoading = false;
  }

  @override
  void initState() {
    super.initState();
    if (widget.arguments.length == 1) {
      _selectedMtagIndex = 0;
      _selectedMtag = widget.arguments.first.tokenno;
    }
    if (widget.arguments.isNotEmpty) {
      _amountController.text = widget.arguments.first.amount ?? '';
    } else {
      _amountController.text = ''; // Provide a fallback
    }
    if ( widget.arguments.isNotEmpty&& widget.arguments.first.payId != null) {
      _selectedMtagIndex = 0;
      _selectedMtag = widget.arguments.first.tokenno;

      getPaymentCards('${widget.arguments.first.payId}');
      if (widget.arguments.first.payId == '1') {
        _setPayment(2);
      } else if (widget.arguments.first.payId == '0') {       
        _setPayment(1);
      }
    }
    FirebaseRemoteConfigService().fetchRemoteConfig();
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
    return Material(
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
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.redAccent),
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
                        children: widget.arguments.map((item) {
                          return MTagCard(
                            index: widget.arguments.indexOf(item),
                            token: item.tokenno ?? '',
                            registration: item.registration ?? '',
                            isSelected: _selectedMtagIndex == widget.arguments.indexOf(item),
                            onTap: () => _onMTagTap(widget.arguments.indexOf(item), item.tokenno ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (int.parse('${widget.arguments.length}') > 2)
                    InkWell(
                      onTap: () => _scrollRight(_scrollController),
                      child: const Icon(
                        Icons.keyboard_arrow_right,
                      ),
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
                   Text(
                    'Min value is Rs. ${Get.find<HomeController>().dashboradData.value.rechargeMinAmount} & Max is Rs.${Get.find<HomeController>().dashboradData.value.rechargeMaxAmount}',
                    style: TextStyle(fontSize: 7, color: Colors.black),
                  )
                ],
              ),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    if (double.parse(value) > 10000 || double.parse(value) < 50) {
                      return;
                    }
                  }
                },
                maxLength: 8,
                validator:validateAmount,
                controller: _amountController,
          
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
                  children: [50, 200, 500, 1000, 2500, 5000]
                      .map((e) => InkWell(
                            onTap: () {
                              if (_selectedMtag != null) {
                                _amountController.text = e.toString();
                                FocusScope.of(context).unfocus();
                                return;
                              }

                              showPopDialog('Select M-Tag', () {
                                Get.back();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              width: 50,
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
              if (_otherConsts.creditCode.value == 1)
                Column(mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (_formKey.currentState!.validate() &&
                            _selectedMtag != null &&
                            _amountController.text.isNotEmpty) {
                          getPaymentCards('0');
                          _setPayment(1);
                          _isCardsVisible = true;
                          _isJazzCashVisible = false;
                          isAddCard = false;
                          FocusScope.of(context).unfocus();
                          return;
                        }
                        showPopDialog(
                            _selectedMtag == null
                                ? 'Select M-Tag'
                                : _amountController.text.isEmpty
                                    ? 'Enter Amount'
                                    : 'Some details missing', () {
                          Get.back();
                        });
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
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
                          CircleAvatar(
                            backgroundColor: _selectedPayment == 1 ? Colors.green : Colors.grey,
                            radius: 9,
                            child: const Icon(
                              Icons.done_rounded,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 37,top: 0,bottom: 0),
                      child: Obx(() {
                        return Text(
                          _otherConsts.discountText.value,
                          style: const TextStyle(fontSize: 9, color: Colors.redAccent),
                        );
                      }),
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
                                              if (_formKey.currentState!.validate() &&
                                                  _selectedMtag != null &&
                                                  _amountController.text.isNotEmpty) {
                                                await _paymentController.getRechargeSummary(
                                                    isFleet: false,
                                                    mtagId: _selectedMtag.toString(),
                                                    payId: '0',
                                                    amount: _amountController.text);

                                                return;
                                              }
                                              showPopDialog(
                                                  _selectedMtag == null
                                                      ? 'Select M-Tag'
                                                      : _amountController.text.isEmpty
                                                          ? 'Enter Amount'
                                                          : 'Enter Valid Amount', () {
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
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(color: Colors.green),
                                                ),
                                                const SizedBox(
                                                  height: 10,
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
                                                                    _selectedMtag != null &&
                                                                    _amountController.text.isNotEmpty) {
                                                                  _onCardTap(e.key);
                                                                  await _paymentController.getRechargeSummary(
                                                                      isFleet: false,
                                                                      token: e.value.tOKEN,
                                                                      mtagId: _selectedMtag.toString(),
                                                                      payId: '0',
                                                                      amount: _amountController.text);
                                                                  return;
                                                                }
                                                                showPopDialog(
                                                                    _selectedMtag == null
                                                                        ? 'Select M-Tag'
                                                                        : _amountController.text.isEmpty
                                                                            ? 'Enter Amount'
                                                                            : 'Enter Valid Amount', () {
                                                                  Get.back();
                                                                });
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Stack(
                                                                    children: [
                                                                      Column(
                                                                        children: [
                                                                          Container(
                                                                            margin: const EdgeInsets.all(10),
                                                                            decoration: BoxDecoration(
                                                                              border: Border.all(
                                                                                  color: Colors.grey, width: 0.5),
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                            child: Column(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment.start,
                                                                              crossAxisAlignment:
                                                                                  CrossAxisAlignment.start,
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(
                                                                                    left: 35,
                                                                                    right: 35,
                                                                                    top: 18,
                                                                                    bottom: 18,
                                                                                  ),
                                                                                  child: SvgPicture.asset(
                                                                                    e.value.bRAND == 'MASTERCARD'
                                                                                        ? 'assets/mastercard.svg'
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
                                                                            style: Theme.of(context)
                                                                                .textTheme
                                                                                .displaySmall,
                                                                          ),
                                                                          const SizedBox(height: 3),
                                                                        ],
                                                                      ),
                                                                      Positioned(
                                                                        right: 5,
                                                                        top: 1,
                                                                        child: GestureDetector(
                                                                          onTap: () async {
                                                                            showCupertinoModalPopup(
                                                                              context: context,
                                                                              builder: (_) => CupertinoAlertDialog(
                                                                                title: const Text(
                                                                                  'Are you sure you want to delete this card?\n This action cannot be undone.',
                                                                                  style: TextStyle(
                                                                                    fontSize: 14,
                                                                                    fontWeight: FontWeight.normal,
                                                                                  ),
                                                                                ),
                                                                                actions: [
                                                                                  CupertinoDialogAction(
                                                                                    onPressed: () async {
                                                                                      Get.back();
                                                                                      await _paymentController
                                                                                          .deleteCardDetails(
                                                                                              token:
                                                                                                  e.value.tOKEN ?? '',
                                                                                              payId: "0");
                                                                                      _paymentCardModel.cardsData
                                                                                          ?.removeAt(e.key);
                                                                                      if (mounted) setState(() {});
                                                                                    },
                                                                                    child: const Text(
                                                                                      'Confirm',
                                                                                    ),
                                                                                  ),
                                                                                  CupertinoDialogAction(
                                                                                    onPressed: () {
                                                                                      Get.back();
                                                                                    },
                                                                                    child: const Text(
                                                                                      'Cancel',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'Poppins',
                                                                                        color: Colors.redAccent,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            );
                                                                          },
                                                                          child: Container(
                                                                            decoration: const BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.red,
                                                                            ),
                                                                            child: const Padding(
                                                                              padding: EdgeInsets.all(4.0),
                                                                              child: Icon(
                                                                                Icons.close,
                                                                                color: Colors.white,
                                                                                size: 16,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Container(
                                                                    height: 80,
                                                                    width: 0.5,
                                                                    color: Colors.grey,
                                                                  ),
                                                                ],
                                                              )),
                                                          CircleAvatar(
                                                            backgroundColor: _selectedCardIndex == e.key
                                                                ? Colors.green
                                                                : Colors.grey,
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
                  ],
                ),
              const SizedBox(
                height: 10,
              ),
              if (_otherConsts.jazzCode.value == 1)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        _setPayment(2);
                        _isCardsVisible = false;
                        _isJazzCashVisible = true;
                        isAddCard = false;
                        getPaymentCards('1');
                      },
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/jazzcash.svg',
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          const Text('JazzCash'),
                          const Spacer(),
                          CircleAvatar(
                            backgroundColor: _selectedPayment == 2 ? Colors.green : Colors.grey,
                            radius: 9,
                            child: const Icon(
                              Icons.done_rounded,
                              size: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 42),
                      child: Text(
                        'JazzCash Account is required. ',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ),
                    Visibility(
                      visible: _isJazzCashVisible,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (int.parse('${_paymentCardModel.cardsData?.length ?? 0}') > 1)
                            InkWell(
                              onTap: () => _scrollLeft(_scrollController3),
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
                                    controller: _scrollController3,
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  isAddCard = true;
                                                  _isJazzCashVisible = false;
                                                  _selectedJazzCard = -1;
                                                  _scrollController1.animateTo(
                                                    _scrollController.offset - 120,
                                                    duration: const Duration(milliseconds: 100),
                                                    curve: Curves.easeInOut,
                                                  );
                                                  if (mounted) setState(() {});
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey, width: 0.5),
                                                      borderRadius: BorderRadius.circular(8)),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            left: 35, right: 35, top: 18, bottom: 18),
                                                        child: SvgPicture.asset(
                                                          'assets/jazzcash.svg',
                                                          height: 25,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'Add New +',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displaySmall
                                                    ?.copyWith(color: Colors.green),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                          ..._paymentCardModel.cardsData
                                                  ?.asMap()
                                                  .entries
                                                  .map(
                                                    (e) => _paymentCardModel.cnt == 0
                                                        ? Container()
                                                        : Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              InkWell(
                                                                onTap: () async {
                                                                  if (_formKey.currentState!.validate() &&
                                                                      _selectedMtag != null &&
                                                                      _amountController.text.isNotEmpty) {
                                                                    _setJazzCash(e.key);
                                                                    await _paymentController.getRechargeSummary(
                                                                        isFleet: false,
                                                                        token: e.value.tOKEN,
                                                                        mtagId: _selectedMtag.toString(),
                                                                        payId: '1',
                                                                        amount: _amountController.text);
                                                                    return;
                                                                  }
                                                                  showPopDialog(
                                                                      _selectedMtag == null
                                                                          ? 'Select M-Tag'
                                                                          : _amountController.text.isEmpty
                                                                              ? 'Enter Amount'
                                                                              : 'Enter Valid Amount', () {
                                                                    Get.back();
                                                                  });
                                                                },
                                                                child: Row(
                                                                  children: [
                                                                    Stack(
                                                                      children: [
                                                                        Column(
                                                                          children: [
                                                                            Container(
                                                                              margin: const EdgeInsets.all(10),
                                                                              decoration: BoxDecoration(
                                                                                  border: Border.all(
                                                                                      color: Colors.grey, width: 0.5),
                                                                                  borderRadius:
                                                                                      BorderRadius.circular(8)),
                                                                              child: Column(
                                                                                mainAxisAlignment:
                                                                                    MainAxisAlignment.start,
                                                                                crossAxisAlignment:
                                                                                    CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(
                                                                                        left: 35,
                                                                                        right: 35,
                                                                                        top: 18,
                                                                                        bottom: 18),
                                                                                    child: SvgPicture.asset(
                                                                                      'assets/jazzcash.svg',
                                                                                      height: 20,
                                                                                      width: 40,
                                                                                      fit: BoxFit.fill,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              "Ends ${maskString(e.value.cARDNUMBER ?? '')}",
                                                                              style: Theme.of(context)
                                                                                  .textTheme
                                                                                  .displaySmall,
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 3,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Positioned(
                                                                          right: 5,
                                                                          top: 1,
                                                                          child: GestureDetector(
                                                                            onTap: () async {
                                                                              showCupertinoModalPopup(
                                                                                context: context,
                                                                                builder: (_) => CupertinoAlertDialog(
                                                                                  title: const Text(
                                                                                    'Are you sure you want to delete this card?\n This action cannot be undone.',
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                      fontWeight: FontWeight.normal,
                                                                                    ),
                                                                                  ),
                                                                                  actions: [
                                                                                    CupertinoDialogAction(
                                                                                      onPressed: () async {
                                                                                        Get.back();
                                                                                        await _paymentController
                                                                                            .deleteCardDetails(
                                                                                                token: e.value
                                                                                                        .cARDNUMBER ??
                                                                                                    '',
                                                                                                payId: "1");

                                                                                        _paymentCardModel.cardsData
                                                                                            ?.removeWhere((card) =>
                                                                                                e.value == card);

                                                                                        if (mounted) setState(() {});
                                                                                      },
                                                                                      child: const Text(
                                                                                        'Confirm',
                                                                                      ),
                                                                                    ),
                                                                                    CupertinoDialogAction(
                                                                                      onPressed: () {
                                                                                        Get.back();
                                                                                      },
                                                                                      child: const Text(
                                                                                        'Cancel',
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Poppins',
                                                                                          color: Colors.redAccent,
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            },
                                                                            child: Container(
                                                                              decoration: const BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: Colors.red,
                                                                              ),
                                                                              child: const Padding(
                                                                                padding: EdgeInsets.all(2.0),
                                                                                child: Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.white,
                                                                                  size: 12,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
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
                                                                backgroundColor: _selectedJazzCard == e.key
                                                                    ? Colors.green
                                                                    : Colors.grey,
                                                                radius: 9,
                                                                child: const Icon(
                                                                  Icons.done_rounded,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  )
                                                  .toList() ??
                                              [],
                                        ]),
                                  ),
                          ),
                          if (int.parse('${_paymentCardModel.cardsData?.length ?? 0}') > 1)
                            InkWell(
                              onTap: () => _scrollRight(_scrollController3),
                              child: const Icon(
                                Icons.keyboard_arrow_right,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isAddCard) ...[
                      const SizedBox(
                        height: 16,
                      ),
                      const Text(
                        'Pay with JazzCash Account. Enter the mobile number which is registered to Jazz Cash',
                        style: TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Note: Ensure your JazzCash account is Active and has sufficient balance. ',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'JazzCash Account Number',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.redAccent,
                            ),
                      ),
                      CustomTExtField(
                        onTapOutside: (p0) => FocusScope.of(context).unfocus(),
                        autoFocus: true,
                        onEditingComplete: () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedMtag != null &&
                              _amountController.text.isNotEmpty) {
                            return _paymentController.getRechargeSummary(
                                isFleet: false,
                                mtagId: _selectedMtag.toString(),
                                payId: '1',
                                amount: _amountController.text,
                                token: _jazzCashController.text);
                          }
                          return showPopDialog(
                              _selectedMtag == null
                                  ? 'Select M-Tag'
                                  : _amountController.text.isEmpty
                                      ? 'Enter Amount'
                                      : 'Enter Valid Amount', () {
                            Get.back();
                          });
                        },
                        hintStyle: const TextStyle(fontSize: 14),
                        style: const TextStyle(fontSize: 17, height: 1),
                        maxLength: 11,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 11 || !value.startsWith('03')) {
                            return 'Enter valid Jazzcash Number';
                          }
                          return null;
                        },
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                        controller: _jazzCashController,
                        hint: 'Enter JazzCash Account Number',
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ]
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
