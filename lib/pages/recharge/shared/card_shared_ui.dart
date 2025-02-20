import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '/pages/payment/controller/payment_card_controller.dart';
import '/utils/utils.dart';
import '/widgets/textform_widget.dart';
import '../../payment/model/payment_card_model.dart';

ValueNotifier<bool> isJazzShown = ValueNotifier<bool>(false);
ValueNotifier isCardsVisible = ValueNotifier<bool>(false);

class CardSharedUi extends StatelessWidget {
  CardSharedUi({
    super.key,
    this.paymentHead,
    this.cardListData,
    this.loading,
    this.payId,
    this.amount,
    this.mtagId,
  });
  final String? paymentHead;
  final String? mtagId;
  final String? amount;
  final bool? loading;

  final int? payId;
  final List<CardsData>? cardListData;
  void _scrollLeft({ScrollController? controller}) {
    controller?.animateTo(
      controller.offset - 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight({ScrollController? controller}) {
    controller?.animateTo(
      controller.offset + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  final _jazzCashController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: isCardsVisible,
          builder: (context, value, child) => Visibility(
            visible: value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(paymentHead ?? ''),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -8),
                      child: InkWell(
                        onTap: () => _scrollLeft(),
                        child: const Icon(
                          Icons.keyboard_arrow_left,
                        ),
                      ),
                    ),
                    Expanded(
                      child: loading == true
                          ? Center(
                              child: LoadingAnimationWidget.flickr(
                                leftDotColor: Colors.white,
                                rightDotColor: Theme.of(context).primaryColor,
                                size: 30,
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildAddNewCard(
                                    mtagId: mtagId,
                                    amount: amount,
                                    payId: payId,
                                  ), // First widget in the Row
                                  ...?cardListData?.map(
                                    (e) => _buildCard(
                                      e,
                                      payId: payId,
                                      onDelete: () {
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
                                                  await Get.find<
                                                          PaymentCardController>()
                                                      .deleteCardDetails(
                                                          token: e.tOKEN ?? '',
                                                          payId: payId == 1
                                                              ? '0'
                                                              : '1');
                                                  cardListData?.remove(e);
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
                                      onTap: () async {
                                        await Get.find<PaymentCardController>()
                                            .getRechargeSummary(
                                          isFleet: false,
                                          token: e.tOKEN,
                                          mtagId: mtagId ?? '',
                                          payId: payId == 1 ? '0' : '1',
                                          amount: amount ?? '0',
                                        );
                                      },
                                    ),
                                  ), // Render other cards
                                ],
                              ),
                            ),
                    ),
                    InkWell(
                      onTap: () => _scrollRight(),
                      child: Transform.translate(
                        offset: Offset(0, -5), // Move icon 5 pixels up
                        child: const Icon(
                          Icons.keyboard_arrow_right,
                          // Adjust size if needed
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isJazzShown,
          builder: (context, value, child) => Visibility(
            visible: value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/jazzcash.svg',
                      height: 10,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('JazzCash'),
                          Text(
                            'JazzCash Account is required',
                            style: Theme.of(context).textTheme.displaySmall,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                CustomTExtField(
                  hint: 'Enter JazzCash Account Number',
                  maxLength: 11,
                  validator: validateJazzcashNumber,
                  controller: _jazzCashController,
                  onTapOutside: (p0) => FocusScope.of(context).unfocus(),
                  onEditingComplete: () async =>
                      validateJazzcashNumber(_jazzCashController.text) == null||mtagId==null||mtagId!.length<8
                          ? await Get.find<PaymentCardController>()
                              .getRechargeSummary(
                              isFleet: false,
                              mtagId: mtagId ?? '',
                              payId: '1',
                              amount: amount ?? '',
                              token: _jazzCashController.text.trim(),
                            )
                          : null,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

Widget _buildAddNewCard({
  int? payId,
  String? mtagId,
  String? amount,
}) {
  return GestureDetector(
    onTap: () async {
      log('payid$payId');

      if (payId == 2) {
        toggleBooleans();
      } else {
        await Get.find<PaymentCardController>().getRechargeSummary(
            isFleet: false,
            mtagId: mtagId ?? '',
            payId: payId == 1 ? '0' : '1',
            amount: amount ?? '0');
        isJazzShown.value = false;
      }
    },
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
  width: 100,
  height: 50,
  margin: EdgeInsets.symmetric(horizontal: 2),
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(width: 0.2),
  ),
  child: Center( // Ensures proper centering
    child: SvgPicture.asset(
      payId == 2 ? 'assets/jazzcash.svg' : 'assets/addnew.svg',
      height: 15,
      fit: BoxFit.contain, // Prevents distortion and ensures proper alignment
      alignment: Alignment.center, // Keeps it centered
    ),
  ),
),

        Padding(
          padding: const EdgeInsets.all(1.0),
          child: Text(
            'Add New +',
            style: TextStyle(fontSize: 11, color: Colors.green),
          ),
        )
      ],
    ),
  );
}

Widget _buildCard(CardsData e,
    {Function()? onTap, Function()? onDelete, int? payId}) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip
          .none, // Allows the delete button to be placed outside the container
      children: [
        // Card Container
        Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              width: 100,
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 0.2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2), // Slight shadow for depth
                  ),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(
                  payId == 2
                      ? 'assets/jazzcash.svg'
                      : e.bRAND == 'MASTERCARD'
                          ? 'assets/mastercard.svg'
                          : 'assets/visa-logo.svg',
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Text(
                'Ends ${maskString(e.cARDNUMBER ?? '')}',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            )
          ],
        ),

        // Delete Button Positioned in the Top-Right
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

void toggleBooleans() {
  log('called');
  isJazzShown.value = true;
  isCardsVisible.value = false;
}
