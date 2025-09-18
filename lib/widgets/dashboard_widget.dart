import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import 'package:mtag_flutterapp/widgets/bottomsheet/bottom_sheet_widget.dart';

import '../controller/home_controller.dart';
import '../pages/dashboard/model/dashboard_model.dart';
import '../pages/recharge/recharge_page.dart';
import 'dialog/d_link_dialog.dart';

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

RxBool _obscured = false.obs;

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
}) {
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
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
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
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
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
                              Theme.of(context).hintColor,
                              BlendMode.srcIn,
                            ),
                            width: 120,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Divider(thickness: 0.2, height: 0.7),
                    const SizedBox(height: 8),
                    // Modified section: Balance and buttons in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Balance',
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 14),
                              Obx(
                                () => Row(
                                  children: [
                                    Text(
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
                                    ),
                                    const SizedBox(width: 12),
                                    // Reduced spacing
                                    InkWell(
                                      onTap: () async {
                                        if (!_obscured.value) {
                                          await Get.find<HomeController>()
                                              .updateBalance();
                                          _obscured(!_obscured.value);
                                        } else {
                                          _obscured(!_obscured.value);
                                        }
                                      },
                                      child: Icon(
                                        _obscured.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20, // Slightly smaller icon
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            SizedBox(
                              width: 100,
                              child: InkWell(
                                onTap: () => showPaymentBottomSheet(
                                  context,
                                  mtagId: mtagId,
                                  regId: regId,
                                  jazzCode: jazzCode,
                                  creditCode: creditCode,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Theme.of(context).disabledColor,
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_outlined,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Recharge',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 100,
                              child: InkWell(
                                onTap: () => showDialog(
                                  context: Get.context!,
                                  builder: (ctx) {
                                    return DelinkVehicleDialog(
                                      argument: ActiveMtags(
                                        tokenno: mtagId,
                                        balance: ball,
                                        registration: regId,
                                      ),
                                    );
                                  },
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Theme.of(context).disabledColor,
                                    border: Border.all(
                                      color: Colors.redAccent,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.delete_forever_outlined,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Delete\t\t\t\t\t',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.redAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            if (isBlock == 0.0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Blocked',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

//
