import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import '../controller/home_controller.dart';
import '../pages/mtag/controller/delink_controller.dart';
import '../pages/recharge/recharge_page.dart';
import '../utils/utils.dart';
import 'balance_widget.dart';
import 'bottomsheet/balance_transfer_bs.dart';
import 'bottomsheet/bottom_sheet_widget.dart';
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
  balanceDashboard,
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
  bool? showChassisBadge,
  String? chassisNumber,
}) {
  final controller = Get.find<HomeController>();
  final dlinkVehicleController = Get.find<DelinkController>();

  return LayoutBuilder(
    builder: (context, constraints) {
      final double screenWidth = MediaQuery.sizeOf(context).width;
      final double screenHeight = MediaQuery.sizeOf(context).height;

      final double availableWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : screenWidth;

      final double containerHeight = height ?? screenHeight * 0.22;

      // === EXACT SAME RATIOS AS mtagRecoveryWidget ===
      final double horizontalPadding = availableWidth * 0.04;
      final double containerPadding = containerHeight * 0.06;
      final double elementSpacing = containerHeight * 0.04;
      final double fontSizeBase = containerHeight * 0.055;
      final double borderRadius = containerHeight * 0.05;
      final double iconSize = containerHeight * 0.08;
      final double buttonHeight = containerHeight * 0.20;


      // Define buttonSpacing (was missing!)
      final double buttonSpacing = containerHeight * 0.02;

      final List<Map<String, dynamic>> allCars = controller
          .dashboradData
          .value
          .activeMtags!
          .where((car) => car.registration != regId)
          .map(
            (car) => {
              "carNumber": car.registration,
              "balance": double.tryParse(car.balance ?? '0.0') ?? 0.0,
              "mtagID": car.tokenno,
            },
          )
          .toList();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(
              width: availableWidth - (horizontalPadding * 2),
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Theme.of(context).primaryColorLight,
                  width: availableWidth * 0.0013,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    regId ?? '',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: fontSizeBase * 1.3,
                                          fontWeight: FontWeight.w800,
                                          color: Theme.of(
                                            context,
                                          ).primaryColorLight,
                                        ),
                                  ),
                                ),
                                SizedBox(height: elementSpacing * 0.5),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'M-TAG : ',
                                          style: TextStyle(
                                            fontSize: fontSizeBase * 1.3,
                                            color: Theme.of(
                                              context,
                                            ).primaryColorLight,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextSpan(
                                          text: mtagId ?? '',
                                          style: TextStyle(
                                            fontSize: fontSizeBase * 1.3,
                                            color: Theme.of(
                                              context,
                                            ).primaryColorLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: elementSpacing * 0.3),
                                Row(
                                  children: [
                                    Text(
                                      'Balance',
                                      style: TextStyle(
                                        fontSize: fontSizeBase * 1.3,
                                        color: Theme.of(
                                          context,
                                        ).primaryColorLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: elementSpacing * 0.3),
                                    BalanceWidget(
                                      balance: ball,
                                      fontSize: fontSizeBase * 1.3,
                                      iconSize: fontSizeBase * 2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Transform.translate(
                                offset: const Offset(-3, -3),
                                child: SvgPicture.asset(
                                  getVehicleImage(vehType ?? ''),
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).primaryColorLight,
                                    BlendMode.srcIn,
                                  ),
                                  width: containerHeight * 0.45,
                                  height: containerHeight * 0.45 * 0.60,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(-3, -3),
                                child: InkWell(
                                  onTap: () async {
                                    final chassis = await showDialog<String>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => ChassisNumberDialog(
                                        registration: regId ?? '',
                                        mobileNumber: mobileNum ?? '',
                                        tokenNo: mtagId ?? '',
                                        balance: ball ?? '',
                                        cnicNumber: cnic ?? '',
                                      ),
                                    );
                                    if (chassis != null &&
                                        chassis.isNotEmpty) {}
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: containerHeight * 0.035,
                                      vertical: containerHeight * 0.018,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).disabledColor,
                                      borderRadius: BorderRadius.circular(
                                        containerHeight * 0.035,
                                      ),
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).primaryColorLight,
                                        width: 0.7,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (chassisNumber == null ||
                                            chassisNumber.isEmpty)
                                          Icon(
                                            Icons.add,
                                            color: Theme.of(
                                              context,
                                            ).primaryColorLight,
                                            size: containerHeight * 0.07,
                                          )
                                        else
                                          const SizedBox.shrink(),
                                        SizedBox(
                                          width: containerHeight * 0.015,
                                        ),
                                        Text(
                                          chassisNumber == null ||
                                                  chassisNumber.isEmpty
                                              ? 'Add Chassis Number'
                                              : 'Chassis : $chassisNumber',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).primaryColorLight,
                                            fontSize: containerHeight * 0.04,
                                          ),
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

                      SizedBox(height: elementSpacing * 0.8),

                      Column(
                        children: [
                          const Divider(thickness: 0.3, height: 0.1),
                          SizedBox(height: elementSpacing * 0.6),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (showTransferButton == true)
                                Expanded(
                                  child: InkWell(
                                    onTap: () => showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => BalanceTransferSheet(
                                        carRegistration: regId,
                                        balance: balanceDashboard,
                                        cnicNumber: cnic,
                                        mobileNumber: mobileNum,
                                        mtagid: mtagId,
                                        dropDownCars: allCars,
                                      ),
                                    ),
                                    child: Container(
                                      height: buttonHeight,
                                      margin: EdgeInsets.only(
                                        right: buttonSpacing,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          borderRadius * 0.6,
                                        ),
                                        color: Theme.of(context).disabledColor,
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
                                        children: [
                                          CircleAvatar(
                                            radius: 10,
                                            backgroundColor: Theme.of(
                                              context,
                                            ).primaryColor,
                                            child: const Text(
                                              'Rs',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: elementSpacing * 0.6),
                                          Flexible(
                                            child: Text(
                                              'Transfer',
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).primaryColorLight,
                                                fontSize: fontSizeBase * 1.2,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const SizedBox.shrink(),

                              Expanded(
                                child: InkWell(
                                  onTap: () => showPaymentBottomSheet(
                                    context,
                                    mtagId: mtagId,
                                    regId: regId,
                                    jazzCode: jazzCode,
                                    creditCode: creditCode,
                                    blackListRecharge: false,
                                  ),
                                  child: Container(
                                    height: buttonHeight,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: buttonSpacing,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        borderRadius * 0.6,
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
                                      children: [
                                        Icon(
                                          Icons.add_outlined,
                                          color: Colors.green,
                                          size: iconSize * 1.2,
                                        ),
                                        SizedBox(width: elementSpacing * 0.3),
                                        Flexible(
                                          child: Text(
                                            'Recharge',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: fontSizeBase * 1.2,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
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
                                      builder: (_) => DeLinkVehicleDialog(
                                        regId: regId ?? '',
                                        onCancel: () => Get.back(),
                                        onConfirm: () {
                                          Get.back();
                                          dlinkVehicleController.deLinkVehicle(
                                            mtagID: mtagId ?? '',
                                            rDesc:
                                                "${0}--${"Vehicle has been sold out."}",
                                            rID: "1",
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: buttonHeight,
                                    margin: EdgeInsets.only(
                                      left: buttonSpacing,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        borderRadius * 0.4,
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
                                      children: [
                                        Icon(
                                          Icons.delete_forever_outlined,
                                          color: Colors.redAccent,
                                          size: iconSize * 1.2,
                                        ),
                                        SizedBox(width: elementSpacing * 0.6),
                                        Flexible(
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: fontSizeBase * 1.2,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: elementSpacing * 0.5),
                        ],
                      ),
                    ],
                  ),

                  if (isBlock == 0.0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: containerHeight * 0.035,
                          vertical: containerHeight * 0.018,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withAlpha(77),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'Blocked',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeBase * 1.1,
                            letterSpacing: 0.5,
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
    },
  );
}

void showPaymentBottomSheet(
  BuildContext context, {
  String? mtagId,
  String? regId,
  String? jazzCode,
  String? creditCode,
  required bool blackListRecharge,
  double? recoveryAmount,
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
      blackListRecharge: blackListRecharge,
      recoveryAmount: recoveryAmount,
      onCopyPSID: () {
        showPSIDField.value = true;
        Clipboard.setData(ClipboardData(text: psidController.text));
      },
    ),
    isScrollControlled: true,
    backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
  );
}
