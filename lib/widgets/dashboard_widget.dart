import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? userName,
  String? ball,
  dynamic balanceDashboard,
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
  String? chassisNumber,
  bool? showChassisBadge,
  VoidCallback? onTapBack,
  VoidCallback? onTapForward,
}) {
  final controller = Get.find<HomeController>();

  return LayoutBuilder(
    builder: (context, constraints) {
      final maxW = constraints.maxWidth;
      final isSmall = maxW < 330;
      final fontLarge = isSmall ? 15.0 : 18.0;

      final fontSmall = isSmall ? 10.0 : 12.0;

      /// Car Image Size
      final carSize = isSmall ? 80.0 : 80.0;

      /// Other MTAGs list
      final allCars = controller.dashboradData.value.activeMtags!
          .where((car) => car.registration != regId)
          .map(
            (car) => {
              "carNumber": car.registration,
              "balance": double.tryParse(car.balance ?? '0.0') ?? 0.0,
              "mtagID": car.tokenno,
            },
          )
          .toList();

      return Container(
        width: MediaQuery.sizeOf(context).width,

        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              padding: .all(26),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: .only(bottomLeft: .circular(28)),
              ),
              child: Column(
                spacing: 10,
                mainAxisAlignment: .start,
                crossAxisAlignment: .start,

                children: [
                  SizedBox(height: 26),
                  Text(
                    'M-TAG',
                    style: TextTheme.of(context).titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: .w800,
                      fontSize: 20,
                    ),
                  ),
                  mtadDetailsWidget(
                    context,
                    icon: Icons.folder_outlined,
                    label: 'M-TAG',
                    value: mtagId,
                  ),
                  mtadDetailsWidget(
                    context,
                    icon: Icons.delivery_dining,
                    label: 'Vehicle No',
                    value: regId,
                  ),
                  mtadDetailsWidget(
                    context,
                    icon: Icons.description,
                    label: 'Chassis No',
                    value: chassisNumber,
                    ischassis: true,
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (_) => ChassisNumberDialog(
                          registration: regId ?? '',
                          tokenNo: mtagId ?? '',
                          mobileNumber: mobileNum ?? '',
                          balance: ball ?? '',
                          cnicNumber: cnic ?? '',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.sizeOf(context).height * 0.045),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  InkWell(
                    onTap: onTapBack,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: Icon(Icons.arrow_back_ios_rounded, size: 20),
                    ),
                  ),
                  Transform.scale(
                    scaleY: 2.0,
                    scaleX: 2.4,
                    // scale: 3, // enlarge visually but keeps original size in layout
                    child: Image.asset(
                      "assets/honda.png",
                      width: carSize, // keeps parent constraints safe
                      fit: BoxFit.fill,
                    ),
                  ),
                  InkWell(
                    onTap: onTapForward,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: Icon(Icons.arrow_forward_ios_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(flex: 3),

            Row(
              mainAxisAlignment: .center,
              children: [
                Text(
                  "Balance  ",
                  style: TextTheme.of(
                    context,
                  ).bodyLarge?.copyWith(fontWeight: .w500),
                ),
                BalanceWidget(
                  balance: ball ?? '',
                  fontSize: fontLarge,
                  iconSize: fontLarge,
                ),
              ],
            ),
            Spacer(),
            // SizedBox(height: 10),

            /// 🔹 Bottom Action Buttons (Transfer / Recharge / Delete)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showTransferButton == false)
                  actionBtn(
                    context,
                    label: "Transfer",
                    icon: 'assets/send.png',

                    fontSize: fontSmall,

                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BalanceTransferSheet(
                          carRegistration: regId,
                          balance: balanceDashboard,
                          cnicNumber: cnic,
                          mobileNumber: mobileNum,
                          mtagid: mtagId,
                          dropDownCars: allCars,
                        ),
                      );
                    },
                  )
                else
                  const SizedBox(width: 0),

                actionBtn(
                  context,
                  label: "Recharge",
                  icon: 'assets/plus1.png',

                  fontSize: fontSmall,

                  onTap: () {
                    showPaymentBottomSheet(
                      context,
                      mtagId: mtagId,
                      regId: regId,
                      jazzCode: jazzCode,
                      creditCode: creditCode,
                      blackListRecharge: false,
                    );
                  },
                ),

                actionBtn(
                  context,
                  label: "Delete",
                  icon: 'assets/delete.png',

                  fontSize: fontSmall,

                  onTap: () {
                    Get.dialog(
                      DeLinkVehicleDialog(
                        regId: regId ?? '',
                        onCancel: () => Get.back(),
                        onConfirm: () {
                          Get.back();
                          Get.find<DelinkController>().deLinkVehicle(
                            mtagID: mtagId ?? '',
                            rDesc: "0--Vehicle has been sold out.",
                            rID: "1",
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
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
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: ColorScheme.of(context).surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false, // Prevents full screen expansion
        builder: (context, scrollController) {
          return PaymentBottomSheet(
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
            // Pass the scroll controller
          );
        },
      );
    },
  );
}

/// Reusable button widget
Widget actionBtn(
  BuildContext context, {
  required String label,
  required String icon,

  required double fontSize,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(backgroundColor: Get.isDarkMode?Colors.white: ColorScheme.of(context).surfaceContainerLowest,
            child: Image.asset(icon, height: 30, width: 30)),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget mtadDetailsWidget(
  BuildContext context, {
  IconData? icon,
  String? label,
  String? value,
  bool ischassis = false,
  void Function()? onTap,
}) {
  return Row(
    children: [
      Icon(icon, color: Color(0xff9E9EAD)),
      SizedBox(width: 5),
      Expanded(
        flex: 2,
        child: Text('$label :', style: TextStyle(color: Color(0xff9E9EAD))),
      ),
      Expanded(
        flex: 3,
        child: Text(
          '$value',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      if (ischassis)
        InkWell(
          onTap: onTap,
          child: Icon(Icons.edit_square, size: 16, color: Colors.white),
        ),
    ],
  );
}
