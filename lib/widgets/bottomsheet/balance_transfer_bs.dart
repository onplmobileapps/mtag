import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:mtag_flutterapp/widgets/bottomsheet/build_header_widet.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';
import '../../controller/home_controller.dart';
import '../dialog/cupertino_dialog.dart';

class BalanceTransferSheet extends StatefulWidget {
  final String? carRegistration;
  final String? balance;
  final String? cnicNumber;
  final String? mobileNumber;
  final String? mtagid;
  final List<Map<String, dynamic>> dropDownCars;

  const BalanceTransferSheet({
    super.key,
    required this.carRegistration,
    required this.balance,
    required this.cnicNumber,
    required this.mobileNumber,
    required this.mtagid,
    required this.dropDownCars,
  });

  @override
  State<BalanceTransferSheet> createState() => _BalanceTransferSheetState();
}

class _BalanceTransferSheetState extends State<BalanceTransferSheet> {
  late final ValueNotifier<String?> selectedCar;
  late final ValueNotifier<String?> selectedCarMtag;

  @override
  void initState() {
    super.initState();
    selectedCar = ValueNotifier(null);
    selectedCarMtag = ValueNotifier(null);

    /// ✅ Set first car as default (only if list is not empty)
    if (widget.dropDownCars.isNotEmpty) {
      selectedCar.value = widget.dropDownCars.first["carNumber"]?.toString();
      selectedCarMtag.value = widget.dropDownCars.first["mtagID"]?.toString();
    }
  }

  @override
  void dispose() {
    selectedCar.dispose();
    selectedCarMtag.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        gradient: Theme.of(context).extension<AppGradients>()!.background,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHandleBar(context),
          const SizedBox(height: 10),
          Text('Balance Transfer', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          builBalanceWidget(context),
          const SizedBox(height: 10),
          Text(
            'Select Vehicle',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          buildVehicleDropdown(context: context),
          const SizedBox(height: 10),
          Text(
            'Transfer Amount',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(width: 0.15),
            ),
            clipBehavior: Clip.none,
            child: Text(widget.balance ?? ''),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<String?>(
            valueListenable: selectedCarMtag,
            builder: (context, value, child) {
              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton1(
                      onclick: (value == null)
                          ? null
                          : () => _confirmTransfer(widget.balance),
                      text: 'Confirm',
                      icon: const Icon(Icons.check_circle),
                      isShowIcon: true,
                      iconAlignment: IconAlignment.start,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
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
        cnicNumber: widget.cnicNumber,
        mobileNumber: widget.mobileNumber,
        fromMtag: widget.mtagid,
        toMtag: selectedCarMtag.value,
        amount: balance,
      );
    } catch (e) {
      // Error handling is assumed to be done in the controller
      debugPrint('Transfer error: $e');
    }
  }

  Widget buildVehicleDropdown({required BuildContext context}) {
    if (widget.dropDownCars.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Text(
          "No other vehicles available",
          style: Theme.of(context).textTheme.displayMedium,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
              style: Theme.of(context).textTheme.bodyMedium,
              items: widget.dropDownCars.map((car) {
                return DropdownMenuItem<String>(
                  value: car["carNumber"],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        clipBehavior: Clip.none,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          car["carNumber"] ?? "",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Rs.${car["balance"] ?? "0"}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue == null) return;

                setState(() {
                  selectedCar.value = newValue;

                  // 🔒 PROD SAFE LOOKUP (NO GENERICS, NO firstWhere)
                  for (final car in widget.dropDownCars) {
                    if (car["carNumber"] == newValue) {
                      selectedCarMtag.value = car["mtagID"]?.toString();
                      return;
                    }
                  }

                  // Fallback (never crash)
                  selectedCarMtag.value = null;
                });
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
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        boxShadow: Theme.of(context).extension<AppShadows>()!.cardShadow,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [],
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
                  widget.carRegistration ?? '',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  "Available Balance",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Rs.${widget.balance}",
              style: Theme.of(context).textTheme.displayMedium,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
