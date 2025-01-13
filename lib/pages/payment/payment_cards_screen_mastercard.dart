import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../api/api_constants.dart';
import '../../api/application_url.dart';
import '../../pages/alfawebview/alfla_webview_mastercard.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../pages/payment/model/payment_card_model.dart';
import '../../widgets/dialog/cupertion_dialog.dart';
import '/../widgets/jazz_card_widget.dart';
import '../../widgets/dialog/jazzcash_dialog.dart';
import '../../widgets/master_card.dart';

// ignore: must_be_immutable
class PaymentCardsScreen2 extends StatefulWidget {
  const PaymentCardsScreen2({
    super.key,
  });

  @override
  State<PaymentCardsScreen2> createState() => _PaymentCardsScreenState();
}

class _PaymentCardsScreenState extends State<PaymentCardsScreen2> {
  var payID = (Get.arguments != null && Get.arguments['payId'] != null) ? Get.arguments['payId'] : '';
  var mtagId = (Get.arguments != null && Get.arguments['mtagId'] != null) ? Get.arguments['mtagId'] : '';
  var amount = (Get.arguments != null && Get.arguments['amount'] != null) ? Get.arguments['amount'] : '';
  final cardList = <DebitCard>[].obs;
  final jazzCardList = <JazzCardWidget>[].obs;
  var data = PaymentCardModel().obs;
  final jazznumberController = TextEditingController();
  final cvvController = TextEditingController();

  final _paymentcontroller = Get.find<PaymentCardController>();

  getPaymentCards() async {
    try {
      var data1 = await _paymentcontroller.getCardDetails1(payID.toString());
      if (data1.containsKey(APIRESPONSE.SUCCESS)) {
        data.value = PaymentCardModel.fromJson(data1[APIRESPONSE.SUCCESS]);
        if (data.value.cnt == 0 && payID == '0') {
          var result = await Get.find<PaymentCardController>().getPayUUID(
            mtagId: mtagId,
            amount: amount,
            isFleet: false,
          );
          log(result.toString());
          if (result.isNotEmpty && result.containsKey(APIRESPONSE.SUCCESS)) {
            Get.to(() => AlfaWebView2(
                  url: "${ApplicationUrl.IMAGE_ULR}/payment/${result[APIRESPONSE.SUCCESS]['key']}",
                ));
          } else if (result.containsKey(APIRESPONSE.ERROR)) {
            showPopDialog(result[APIRESPONSE.ERROR]['Message'], () => Get.back());
          }
        } else if (data.value.cnt == 0 && payID == '1') {
          showDialog(
              useRootNavigator: false,
              barrierDismissible: false,
              context: Get.context!,
              builder: (_) => JazzCashDialog(
                    amount: amount.toString(),
                    mtagId: mtagId.toString(),
                    accountController: jazznumberController,
                  ));
        }
      }
    } catch (e) {
      throw Exception(e);
    }

    return;
  }

  @override
  void initState() {
    getPaymentCards();
    super.initState();
  }

  @override
  void dispose() {
    jazznumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {},
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: InkWell(onTap: () => Get.back(), child: const Icon(Icons.arrow_back_ios)),
          automaticallyImplyLeading: true,
          title: const Text('Payment Cards'),
        ),
        body: Container(
          constraints: const BoxConstraints.expand(),
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Obx(
              () => _paymentcontroller.isLoading.value
                  ? LoadingAnimationWidget.flickr(
                      leftDotColor: Theme.of(context).primaryColor, rightDotColor: Colors.white, size: 20)
                  : data.value.cnt == 0
                      ? const Center(
                          child: Text(
                            'No cards available',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return Dismissible(
                                        crossAxisEndOffset: 0.0,
                                        onResize: () {},
                                        onUpdate: (details) {},
                                        confirmDismiss: (direction) {
                                          return showCupertinoModalPopup(
                                            context: context,
                                            builder: (_) => CupertinoAlertDialog(
                                              title: const Text(
                                                'Do you want to Delete Card ?',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              actions: [
                                                CupertinoDialogAction(
                                                  onPressed: () async {
                                                    Get.back();
                                                    await _paymentcontroller.deleteCardDetails(
                                                        token: data.value.cardsData?[index].tOKEN ?? '',
                                                        payId: payID.toString());
                                                    data.value.cardsData?.removeAt(index);
                                                    data.refresh();
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
                                        key: UniqueKey(),
                                        direction: DismissDirection.endToStart,
                                        movementDuration: const Duration(seconds: 1),
                                        onDismissed: (direction) {},
                                        background: Container(),
                                        secondaryBackground: Container(
                                          margin: const EdgeInsets.all(8),
                                          padding: const EdgeInsets.only(right: 50),
                                          decoration:
                                              BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                'Delete Card',
                                                style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                        child: payID == '1'
                                            ? InkWell(
                                                onTap: () async {
                                                  await Get.find<PaymentCardController>().jazzCashRecharge(
                                                      mobile: data.value.cardsData?[index].cARDNUMBER.toString(),
                                                      amount: amount.toString(),
                                                      mtagId: mtagId.toString());
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: JazzCardWidget(
                                                    jazzcardNumber: data.value.cardsData?[index].cARDNUMBER,
                                                    isActive: data.value.cardsData?[index].iSACTIVE,
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () async {
                                                  var response = await Get.find<PaymentCardController>().getPayUUID(
                                                      isFleet: false,
                                                      mtagId: mtagId,
                                                      amount: amount,
                                                      token: data.value.cardsData?[index].tOKEN);
                                                  // token: data.value.cardsData?[index].tOKEN);
                                                  if (response.containsKey(APIRESPONSE.SUCCESS)) {
                                                    Get.to(() => AlfaWebView2(
                                                          url:
                                                              // "https://fwosmartmotorways.com/PaymentApi/alfa/index.php?order_id=RVP00$mtagId${DateTime.now().millisecondsSinceEpoch}&amount=$amount&itokenno=$mtagId&currency=PKR&cnicno=${ownerCNIC.value}&mobilenumber=${mobile.value}&mobiletype=1",
                                                              // "http://115.186.175.106:8005/payment/f98f9c65-8166-4e20-98c9-4bf956d0064b",
                                                              "${ApplicationUrl.IMAGE_ULR}/payment/${response[APIRESPONSE.SUCCESS]['key']}",
                                                        ));
                                                    log('uuid==::${response[APIRESPONSE.SUCCESS]['key']}');
                                                  }
                                                },
                                                child: Center(
                                                  child: DebitCard(
                                                    brandName: data.value.cardsData?[index].bRAND,
                                                    isActivity: false,
                                                    cardNumber: data.value.cardsData?[index].cARDNUMBER,
                                                    issuer: data.value.cardsData?[index].iSSUER,
                                                    expire: data.value.cardsData?[index].eXPIRY,
                                                    fundinMethod: data.value.cardsData?[index].fUNDINGMETHOD,
                                                    key: UniqueKey(),
                                                  ),
                                                ),
                                              ));
                                  },
                                  childCount: data.value.cardsData?.length ?? 0,
                                ),
                              )
                            ],
                          ),
                        ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
          shape: const CircleBorder(),
          mini: false,
          enableFeedback: true,
          onPressed: () async {
            if (payID == '1') {
              showDialog(
                  context: context,
                  builder: (_) => JazzCashDialog(
                        mtagId: mtagId.toString(),
                        amount: amount.toString(),
                        accountController: jazznumberController,
                      ),
                  barrierDismissible: false);
            } else {
              var result =
                  await Get.find<PaymentCardController>().getPayUUID(mtagId: mtagId, amount: amount, isFleet: false);
              if (result.isNotEmpty && result.containsKey(APIRESPONSE.SUCCESS)) {
                Get.to(() => AlfaWebView2(
                      url:
                          // "https://fwosmartmotorways.com/PaymentApi/alfa/index.php?order_id=RVP00$mtagId${DateTime.now().millisecondsSinceEpoch}&amount=$amount&itokenno=$mtagId&currency=PKR&cnicno=${ownerCNIC.value}&mobilenumber=${mobile.value}&mobiletype=1",
                          // "http://115.186.175.106:8005/payment/f98f9c65-8166-4e20-98c9-4bf956d0064b",
                          "${ApplicationUrl.IMAGE_ULR}/payment/${result[APIRESPONSE.SUCCESS]['key']}",
                    ));
                log("result==::${result[APIRESPONSE.SUCCESS]['key'].toString()}");
              }
            }
          },
          child: const Icon(
            Icons.add,
          ),
        ),
      ),
    );
  }
}
