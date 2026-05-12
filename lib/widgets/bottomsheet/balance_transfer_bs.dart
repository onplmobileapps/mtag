import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:mtag_flutterapp/widgets/bottomsheet/build_header_widet.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';
import '../../controller/home_controller.dart';
import '../dialog/cupertino_dialog.dart';

class BalanceTransferSheet extends StatelessWidget {
  final String? carRegistration;
  final String? balance;
  final String? cnicNumber;
  final String? mobileNumber;
  final String? mtagid;
  final List<Map<String, dynamic>> dropDownCars;

  BalanceTransferSheet({
    super.key,
    required this.carRegistration,
    required this.balance,
    required this.cnicNumber,
    required this.mobileNumber,
    required this.mtagid,
    required this.dropDownCars,
  }) {
    /// ✅ Set first car as default (only if list is not empty)
    if (dropDownCars.isNotEmpty) {
      selectedCar.value = dropDownCars.first["carNumber"]?.toString();
      selectedCarMtag.value = dropDownCars.first["mtagID"]?.toString();
    }
  }

  final ValueNotifier<String?> selectedCar = ValueNotifier(null);
  final ValueNotifier<String?> selectedCarMtag = ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: .all(16),
      decoration: BoxDecoration(
        borderRadius: .circular(12),
        gradient: Theme.of(context).extension<AppGradients>()!.background,
      ),
      child: Column(
        spacing: 10,
        mainAxisSize: .min,
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,
        children: [
          buildHandleBar(context),
          Text('Balance Transfer', style: TextTheme.of(context).bodyLarge),
          builBalanceWidget(context),
          Text(
            'Select Vehicle',
            style: TextTheme.of(context).bodyLarge?.copyWith(fontWeight: .w600),
          ),
          buildVehicleDropdown(context: context),
          Text(
            'Transfer Amount',
            style: TextTheme.of(context).bodyLarge?.copyWith(fontWeight: .w600),
          ),
          Container(
            width: double.infinity,
            padding: .all(12),

            decoration: BoxDecoration(
              color: ColorScheme.of(context).surface,
              borderRadius: .circular(12),
              border: .all(width: 0.15),
            ),
            clipBehavior: Clip.none,
            child: Text(balance ?? ''),
          ),
          ValueListenableBuilder(
            valueListenable: selectedCarMtag,
            builder: (context, value, child) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton1(
                      onclick: (selectedCarMtag.value == null)
                          ? null
                          : () => _confirmTransfer(balance),
                      text: 'Confirm',
                      icon: Icon(Icons.check_circle),
                      isShowIcon: true,
                      iconAlignment: .start,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text('Cancel'),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _confirmTransfer(String? matagBalance) async {
    final balance = double.tryParse(matagBalance ?? '0') ?? 0.0;

    if (balance <= 0.0) {
      showPopDialog(
        "You don't have enough balance to perform this transfer.",
        () => Get.back(),
      );
      return;
    }

    Get.back();

    try {
      await Get.find<HomeController>().transferBalanceCall(
        cnicNumber: cnicNumber,
        mobileNumber: mobileNumber,
        fromMtag: mtagid,
        toMtag: selectedCarMtag.value,
        amount: balance,
      );
    } catch (e) {
      // Error handling is assumed to be done in the controller
      debugPrint('Transfer error: $e');
    }
  }

  Widget buildVehicleDropdown({required BuildContext context}) {
    if (dropDownCars.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: ColorScheme.of(context).surface,
        ),
        child: Text(
          "No other vehicles available",
          style: TextTheme.of(context).displayMedium,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColorLight,
          width: 0.15,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: ValueListenableBuilder<String?>(
        valueListenable: selectedCar,
        builder: (context, value, child) {
          return DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).iconTheme.color, // dynamic icon color
              ),
              isExpanded: true,
              elevation: 0,
              // dynamic background
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                // ensures correct text color
              ),
              items: dropDownCars.map((car) {
                return DropdownMenuItem<String>(
                  value: car["carNumber"],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        clipBehavior: Clip.none,
                        decoration: BoxDecoration(
                          color: ColorScheme.of(context).surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          car["carNumber"] ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface, // dynamic background
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Rs.${car["balance"] ?? "0"}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                selectedCar.value = value;

                // 🔒 PROD SAFE LOOKUP (NO GENERICS, NO firstWhere)
                for (final car in dropDownCars) {
                  if (car["carNumber"] == value) {
                    selectedCarMtag.value = car["mtagID"]?.toString();
                    return;
                  }
                }

                // Fallback (never crash)
                selectedCarMtag.value = null;
              },
            ),
          );
        },
      ),
    );
  }

  Widget builBalanceWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).extension<AppShadows>()!.cardShadow,
      ),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            padding: .all(12),
            decoration: BoxDecoration(
              color: ColorScheme.of(context).surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [],
            ),
            child: Image.asset(
              'assets/delivery.png',
              color: Theme.of(context).primaryColor,
              height: 35,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carRegistration ?? '',
                  style: TextTheme.of(
                    context,
                  ).bodyLarge?.copyWith(fontWeight: .w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  "Available Balance",
                  style: TextTheme.of(context).bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ColorScheme.of(context).surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Rs.$balance",
              style: TextTheme.of(context).displayMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
