import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../pages/recharge/recharge_page.dart';
import '../utils/utils.dart';
import 'bottomsheet/bottom_sheet_widget.dart';

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
    'Car': 'assets/vehicles/car.png',
    'Wagon': 'assets/vehicles/wagon.png',
    'Coaster': 'assets/vehicles/coaster.png',
    'Bus': 'assets/vehicles/bus.png',
    'Truck': 'assets/vehicles/truck.png',
    'Trailer': 'assets/vehicles/trailer.png',
  };

  return vehicleImages[vehicleType] ?? '';
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
    enableDrag: true,
    useSafeArea: true,
    backgroundColor: ColorScheme.of(context).surface,

    builder: (context) {
      return DraggableScrollableSheet(
        shouldCloseOnMinExtent: true,
        initialChildSize: 0.58,
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
          CircleAvatar(
            backgroundColor: Get.isDarkMode
                ? Colors.white
                : ColorScheme.of(context).surfaceContainerLowest,
            child: Image.asset(icon, height: 30, width: 30),
          ),
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
