import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/controller/home_controller.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import 'package:mtag_flutterapp/widgets/bottomsheet/bottom_sheet_widget.dart';

String getVehCategory(String vehicleType) {
  Map<String, String> vehicleCategories = {
    'Car': 'F1',
    'Wagon': 'F2',
    'Coaster': 'F3',
    'Bus': 'F4',
    'Truck': 'F5',
    'Trailer': 'F6'
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

  // Return the corresponding image path if the vehicle type exists in the map
  return vehicleImages[vehicleType] ?? '';
}

RxBool _obscured = false.obs;

Widget mtagDataWidget(BuildContext context,
    {String? vehType,
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
    double? isBlock}) {
  log('$mtagId,$regId,$creditCode,$jazzCode');

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Center(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                width: MediaQuery.sizeOf(context).width - 20,
                height: height,
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(width: 0.3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              userName?.toUpperCase() ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'M-TAG ',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              TextSpan(
                                text: mtagId ?? '',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          regId ?? '',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Baseline(
                            baseline: 10,
                            baselineType: TextBaseline.alphabetic,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Vehicle Type: $vehType (${getVehCategory(vehType ?? '')})',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ),
                          ),
                        ),
                        Baseline(
                          baseline: 18,
                          baselineType: TextBaseline.alphabetic,
                          child: SvgPicture.asset(
                            getVehicleImage(vehType ?? '').toString(),
                            colorFilter: ColorFilter.mode(
                                Theme.of(context).hintColor, BlendMode.srcIn),
                            width: 120,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Divider(
                      thickness: 0.2,
                      height: 0.7,
                    ),
                    // const Spacer(),
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Flexible(
                            flex: 1,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Available Balance',
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                            ),
                          ),
                          Obx(
                            () => Row(
                              children: [
                                Expanded(
                                  child: FittedBox(
                                    alignment: Alignment.topLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      _obscured.value
                                          ? 'PKR ${ball ?? '0.00'}'
                                          : 'PKR ••••••',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.red,
                                            height: 1,
                                          ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),
                                Baseline(
                                  baseline: 20,
                                  baselineType: TextBaseline.ideographic,
                                  child: InkWell(
                                    onTap: () async {
                                      if (!_obscured.value) {
                                        await Get.find<HomeController>()
                                            .pullrefreshDashBoardData();
                                        _obscured(!_obscured.value);
                                      } else {
                                        _obscured(!_obscured.value);
                                      }
                                    },
                                    child: Icon(
                                      _obscured.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  flex: 1,
                                  child: InkWell(
                                    onTap: () => showPaymentBottomSheet(context,
                                        mtagId: mtagId,
                                        regId: regId,
                                        jazzCode: jazzCode,
                                        creditCode: creditCode),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Theme.of(context).disabledColor,
                                        border: Border.all(
                                            color: Colors.green, width: 0.5),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add_outlined,
                                            color: Colors.green,
                                            size: 25,
                                          ),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              'Recharge',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      color: Colors.green),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isBlock == 0.0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      'Blocked',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

// Use this in your widget to show the bottom sheet:
void showPaymentBottomSheet(BuildContext context,
    {String? mtagId, String? regId, String? jazzCode, String? creditCode}) {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController psidController = TextEditingController();

  final ValueNotifier<bool> showPSIDField = ValueNotifier(false);
  final ValueNotifier<int> selectedPaymentOption = ValueNotifier(-1);

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

//
