import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mtag_flutterapp/api/api_constants.dart';
import 'package:mtag_flutterapp/constants/other_consts.dart';

import 'package:mtag_flutterapp/pages/payment/controller/payment_card_controller.dart';
import 'package:mtag_flutterapp/pages/payment/model/payment_card_model.dart';
import '../alfawebview/alfla_webview.dart';
import '/../widgets/jazz_card_widget.dart';
import '../../widgets/dialog/jazzcash_dialog.dart';
import '../../widgets/master_card.dart';

// ignore: must_be_immutable
class PaymentCardsScreen extends StatefulWidget {
  const PaymentCardsScreen({
    super.key,
  });

  @override
  State<PaymentCardsScreen> createState() => _PaymentCardsScreenState();
}

class _PaymentCardsScreenState extends State<PaymentCardsScreen> {
  var payID = (Get.arguments != null && Get.arguments['payId'] != null) ? Get.arguments['payId'] : '';
  var mtagId = (Get.arguments != null && Get.arguments['mtagId'] != null) ? Get.arguments['mtagId'] : '';
  var amount = (Get.arguments != null && Get.arguments['amount'] != null) ? Get.arguments['amount'] : '';
  final cardList = <DebitCard>[].obs;
  final jazzCardList = <JazzCardWidget>[].obs;
  var data = PaymentCardModel().obs;
  final jazznumberController = TextEditingController();
  final _paymentcontroller = Get.find<PaymentCardController>();
  final _otherContants = OtherConsts();

  getPaymentCards() async {
    var data1 = await _paymentcontroller.getCardDetails(payID.toString());
    if (data1.containsKey(APIRESPONSE.SUCCESS)) {
      data.value = PaymentCardModel.fromJson(data1[APIRESPONSE.SUCCESS]);
      if (data.value.cnt == 0 && payID == '0') {
        Get.to(() => AlfaWebView(
              url:
                  "https://fwosmartmotorways.com/PaymentApi/alfa/index.php?order_id=RVP00$mtagId${DateTime.now().millisecondsSinceEpoch}&amount=$amount&itokenno=$mtagId&currency=PKR&cnicno=${_otherContants.ownerCNIC.value}&mobilenumber=${_otherContants.mobile.value}&mobiletype=1",
            ));
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

    return;
  }

  @override
  void initState() {
    getPaymentCards();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {},
      canPop: false,
      child: Scaffold(
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
                                                  await Get.to(() => AlfaWebView(
                                                        url:
                                                            "https://fwosmartmotorways.com/PaymentApi/alfa/main_stored_trans.php?order_id=RVP00$mtagId${DateTime.now().millisecondsSinceEpoch}&itokenno=$mtagId&amount=$amount&cnicno=${_otherContants.ownerCNIC}&mobileno=${_otherContants.mobile}&token=${data.value.cardsData?[index].tOKEN}&mobiletype=0",
                                                      ));
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
          backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
          shape: const CircleBorder(),
          mini: false,
          enableFeedback: true,
          onPressed: () {
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
              Get.to(() => AlfaWebView(
                    url:
                        "https://fwosmartmotorways.com/PaymentApi/alfa/index.php?order_id=RVP00$mtagId${DateTime.now().millisecondsSinceEpoch}&amount=$amount&itokenno=$mtagId&currency=PKR&cnicno=${_otherContants.ownerCNIC.value}&mobilenumber=${_otherContants.mobile.value}&mobiletype=1",
                  ));
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
