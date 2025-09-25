import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import 'package:mtag_flutterapp/widgets/bottomsheet/bottom_sheet_widget.dart';

import '../controller/home_controller.dart';
import '../pages/mtag/controller/delink_controller.dart' show DelinkController;
import '../pages/recharge/recharge_page.dart';
import 'dialog/chassis_num.dart';
import 'dialog/delink_dialog.dart';

String getVehCategory(String vehicleType) {
  Map<String, String> vehicleCategories = {
    'Car': 'F1',
    'Wagon': 'F2',
    'Coaster': 'F3',
    'Bus': 'F4',
    'Truck': 'F5',
    'Trailer': 'F6',
  };
  if (vehicleCategories.containsKey(vehicleType)) {
    return vehicleCategories[vehicleType] ?? '';
  } else {
    return '';
  }
}

String getVehicleImage(String vehicleType) {
  // Map containing vehicle types and their corresponding image paths
  Map<String, String> vehicleImages = {
    'Car': 'assets/f1.svg',
    'Wagon': 'assets/f2.svg',
    'Coaster': 'assets/f3.svg',
    'Bus': 'assets/f4.svg',
    'Truck': 'assets/f5.svg',
    'Trailer': 'assets/f6.svg',
  };

  return vehicleImages[vehicleType] ?? '';
}

Widget mtagDataWidget(
  BuildContext context, {
  String? vehType,
  double? height,
  Size? size,
  String? userName,
  String? ball,
  String? mtagId,
  String? regId,
  String? creditCode,
  String? jazzCode,
  double? blockStatus,
  double? blockAmount,
  String? cnic,
  String? mobileNum,
  double? isBlock,
  bool? showTransferButton,
}) {
  log('$mtagId,$regId,$creditCode,$jazzCode');
  final controller = Get.find<HomeController>();
  final dlinkOptionsController = Get.find<DelinkController>();

  final double screenWidth = MediaQuery.sizeOf(context).width;
  final double screenHeight = MediaQuery.sizeOf(context).height;
  final double containerHeight = height ?? screenHeight * 0.22;

  final double horizontalPadding = screenWidth * 0.03;
  final double containerPadding = containerHeight * 0.055;
  final double elementSpacing = containerHeight * 0.080;
  final double buttonSpacing = containerHeight * 0.02;
  final double iconSize = containerHeight * 0.12;
  final double vehicleImageWidth = containerHeight * 0.45;
  final double fontSizeSmall = containerHeight * 0.075;
  final double fontSizeMedium = containerHeight * 0.085;

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Center(
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Container(
                  width: screenWidth - (horizontalPadding * 2),
                  padding: EdgeInsets.all(containerPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor,
                    borderRadius: BorderRadius.circular(
                      containerHeight * 0.045,
                    ),
                    border: Border.all(
                      width: 0.5,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: elementSpacing * 0.5),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      regId ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: fontSizeSmall,
                                            height: 0.5,
                                            color: Theme.of(
                                              context,
                                            ).primaryColorLight,
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: elementSpacing * 1.1),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'M-TAG ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: fontSizeSmall,
                                                  height: 0.5,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColorLight,
                                                ),
                                          ),
                                          TextSpan(
                                            text: mtagId ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: fontSizeSmall,
                                                  height: 0.5,
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColorLight,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: elementSpacing * 0.5),
                                  Row(
                                    children: [
                                      Text(
                                        'Balance',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: fontSizeSmall,
                                              height: 1.0,
                                              color: Theme.of(
                                                context,
                                              ).primaryColorLight,
                                            ),
                                      ),
                                      SizedBox(width: elementSpacing * 0.50),
                                      Obx(() {
                                        final id = mtagId ?? '';
                                        final isHidden =
                                            controller.hiddenStates[id] ?? true;
                                        final rawBalance =
                                            controller.balances[id];
                                        final displayBalance =
                                            (rawBalance != null &&
                                                rawBalance.isNotEmpty &&
                                                rawBalance.toLowerCase() !=
                                                    'null')
                                            ? rawBalance
                                            : '0.00';
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                isHidden
                                                    ? '••••••'
                                                    : 'PKR $displayBalance',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: Colors.red,
                                                      height: 0.5,
                                                      fontSize:
                                                          fontSizeMedium * 1.1,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(width: elementSpacing),
                                            InkWell(
                                              onTap: () async {
                                                if (isHidden) {
                                                  await controller
                                                      .sendCheckBalance([id]);
                                                  controller.hiddenStates[id] =
                                                      false;
                                                } else {
                                                  controller.hiddenStates[id] =
                                                      true;
                                                }
                                                controller.hiddenStates
                                                    .refresh();
                                              },
                                              child: Icon(
                                                isHidden
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                                size: iconSize,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SvgPicture.asset(
                              getVehicleImage(vehType ?? '').toString(),
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).primaryColorLight,
                                BlendMode.srcIn,
                              ),
                              width: vehicleImageWidth,
                              height: vehicleImageWidth * 0.60,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: elementSpacing * 0.5),
                      Column(
                        children: [
                          const Divider(thickness: 0.3, height: 0.1),
                          SizedBox(height: elementSpacing * 0.8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              showTransferButton == true
                                  ? Expanded(
                                      child: InkWell(
                                        onTap: () => (),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: containerHeight * 0.025,
                                            vertical: containerHeight * 0.02,
                                          ),
                                          margin: EdgeInsets.only(
                                            right: buttonSpacing,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              containerHeight * 0.035,
                                            ),
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                            border: Border.all(
                                              color: Theme.of(
                                                context,
                                              ).primaryColorLight,
                                              width: 0.7,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.send_outlined,
                                                color: Theme.of(
                                                  context,
                                                ).primaryColorLight,
                                                size: iconSize * 0.9,
                                              ),
                                              SizedBox(
                                                width: containerHeight * 0.012,
                                              ),
                                              Flexible(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    'Transfer',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Theme.of(
                                                            context,
                                                          ).primaryColorLight,
                                                          fontSize:
                                                              fontSizeSmall,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              Expanded(
                                child: InkWell(
                                  onTap: () => showPaymentBottomSheet(
                                    context,
                                    mtagId: mtagId,
                                    regId: regId,
                                    jazzCode: jazzCode,
                                    creditCode: creditCode,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: containerHeight * 0.025,
                                      vertical: containerHeight * 0.02,
                                    ),
                                    margin: EdgeInsets.symmetric(
                                      horizontal: buttonSpacing,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        containerHeight * 0.035,
                                      ),
                                      color: Theme.of(context).disabledColor,
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_outlined,
                                          color: Colors.green,
                                          size: iconSize * 0.9,
                                        ),
                                        SizedBox(
                                          width: containerHeight * 0.012,
                                        ),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Recharge',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.green,
                                                    fontSize: fontSizeSmall,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return DeLinkVehicleDialog(
                                          regId: regId ?? '',
                                          onCancel: () => Get.back(),
                                          onConfirm: () {
                                            Get.back();
                                            dlinkOptionsController.deLinkVehicle(
                                              mtagID: mtagId ?? '',
                                              rDesc:
                                                  "${0}--${"Vehicle has been sold out."}",
                                              rID: "1",
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: containerHeight * 0.025,
                                      vertical: containerHeight * 0.02,
                                    ),
                                    margin: EdgeInsets.only(
                                      left: buttonSpacing,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        containerHeight * 0.035,
                                      ),
                                      color: Theme.of(context).disabledColor,
                                      border: Border.all(
                                        color: Colors.redAccent,
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_forever_outlined,
                                          color: Colors.redAccent,
                                          size: iconSize * 0.9,
                                        ),
                                        SizedBox(
                                          width: containerHeight * 0.012,
                                        ),
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Delete',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Colors.redAccent,
                                                    fontSize: fontSizeSmall,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: elementSpacing * 0.3,
                          ), // Small bottom spacing
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isBlock == 0.0)
                Positioned(
                  top: 0,
                  right: horizontalPadding,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: containerHeight * 0.035,
                      vertical: containerHeight * 0.018,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(77),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Blocked',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: containerHeight * 0.065,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

              Positioned(
                top: 0,
                right: horizontalPadding,
                child: InkWell(
                  onTap: () async {
                    final chassisNumber = await showDialog<String>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return ChassisNumberDialog(
                          registration: regId ?? '',
                          tokenNo: mtagId ?? '',
                          balance: ball ?? '',
                        );
                      },
                    );

                    if (chassisNumber != null && chassisNumber.isNotEmpty) {
                      print("Entered Chassis Number: $chassisNumber");
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: containerHeight * 0.035,
                      vertical: containerHeight * 0.018,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(77),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Add Chassis Number',
                      style: TextStyle(
                        color: Colors.white,

                        fontSize: containerHeight * 0.05,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

void showPaymentBottomSheet(
  BuildContext context, {
  String? mtagId,
  String? regId,
  String? jazzCode,
  String? creditCode,
}) {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController psidController = TextEditingController();

  final ValueNotifier<bool> showPSIDField = ValueNotifier(false);
  final ValueNotifier<int> selectedPaymentOption = ValueNotifier(-1);
  selected1linkOpt.value = -1;
  Get.bottomSheet(
    PaymentBottomSheet(
      mtagId: mtagId,
      regId: regId,
      jazzCode: jazzCode,
      creditCode: creditCode,
      amountController: amountController,
      psidController: psidController,
      showPSIDField: showPSIDField,
      selectedPaymentOption: selectedPaymentOption,
      amountList: AmountList.amountList,
      onCopyPSID: () {
        showPSIDField.value = true;

        Clipboard.setData(ClipboardData(text: psidController.text));
      },
    ),
    isScrollControlled: true,
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
  );
}
