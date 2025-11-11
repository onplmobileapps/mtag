
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late TextEditingController amountController;
  final selectedCar = RxnString();
  final selectedCarMtag = RxnString();

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.balance);

    if (widget.dropDownCars.isNotEmpty) {
      selectedCar.value = widget.dropDownCars.first["carNumber"] as String?;
      selectedCarMtag.value = widget.dropDownCars.first["mtagID"] as String?;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Widget _buildActionButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback? onPressed,
    required bool isPrimary,
    required double width,
  }) {
    final fontSize = width >= 600 ? 16.0 : (width < 360 ? 12.0 : 14.0);
    final height = width >= 600 ? 52.0 : 48.0;
    final iconSize = width < 360 ? 16.0 : 20.0;
    final spacing = width < 360 ? 4.0 : 8.0;
    final horizontalPadding = width < 360 ? 8.0 : 16.0;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: isPrimary
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: bgColor,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
              ),
              onPressed: onPressed,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: iconSize),
                  SizedBox(width: spacing),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              ),
              onPressed: onPressed,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
    );
  }

  Future<void> _confirmTransfer() async {
    final balance = double.tryParse(widget.balance ?? '0') ?? 0.0;

    if (balance <= 0.0) {
      if (!mounted) return;
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

  Widget _buildCarBalanceCard({
    required BuildContext context,
    required double cardPadding,
    required double iconPadding,
    required double iconSize,
    required double textSize,
    required double smallFontSize,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColorLight,
          width: 0.5,
        ),
      ),
      padding: EdgeInsets.all(cardPadding),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withAlpha(51),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/suv.png',
              width: iconSize,
              height: iconSize,
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.carRegistration ?? "",
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColorLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  "Available Balance",
                  style: TextStyle(
                    fontSize: smallFontSize,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Rs.${widget.balance}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: textSize,
                color: Theme.of(context).disabledColor,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDropdown({
    required BuildContext context,
    required double textSize,
    required double badgeFontSize,
  }) {
    if (widget.dropDownCars.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).disabledColor,
        ),
        child: Text(
          "No other vehicles available",
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColorLight,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCar.value,
          icon: const Icon(Icons.keyboard_arrow_down),
          isExpanded: true,
          dropdownColor: Theme.of(context).disabledColor,
          style: TextStyle(
            color: Theme.of(context).primaryColorLight,
            fontSize: textSize,
            fontWeight: FontWeight.w600,
          ),
          menuMaxHeight: 300,
          items: widget.dropDownCars.map((car) {
            return DropdownMenuItem<String>(
              value: car["carNumber"],
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      car["carNumber"] ?? "",
                      style: TextStyle(fontSize: textSize),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColorLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Rs.${car["balance"] ?? "0"}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: badgeFontSize,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            selectedCar.value = value;
            final selectedCarData = widget.dropDownCars.firstWhere(
              (c) => c["carNumber"] == value,
              orElse: () => <String, dynamic>{},
            );
            selectedCarMtag.value = selectedCarData["mtagID"] as String?;
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final size = MediaQuery.of(context).size;

        // Responsive sizing
        final hPad = width >= 600 ? 32.0 : (width >= 360 ? 20.0 : 16.0);
        final vPad = width >= 600 ? 24.0 : 16.0;
        final labelSize = width >= 600 ? 18.0 : 16.0;
        final textSize = width >= 600 ? 16.0 : 14.0;
        final iconSize = width < 360 ? 24.0 : 28.0;
        final iconPadding = width < 360 ? 10.0 : 12.0;
        final cardPadding = width < 360 ? 12.0 : 16.0;
        final handleWidth = width < 360 ? 36.0 : 48.0;
        final smallFontSize = width < 360 ? 11.0 : 12.0;
        final badgeFontSize = width < 360 ? 12.0 : 13.0;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).bottomSheetTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(
            maxHeight: size.height * 0.9,
            maxWidth: width >= 600 ? 600 : double.infinity,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: handleWidth,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // Title
                    Text(
                      "Balance Transfer",
                      style: TextStyle(
                        fontSize: labelSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                    SizedBox(height: vPad),

                    // Car Balance Card
                    _buildCarBalanceCard(
                      context: context,
                      cardPadding: cardPadding,
                      iconPadding: iconPadding,
                      iconSize: iconSize,
                      textSize: textSize,
                      smallFontSize: smallFontSize,
                    ),
                    SizedBox(height: vPad),

                    // Select Vehicle Section
                    Text(
                      "Select Vehicle",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: labelSize,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildVehicleDropdown(
                      context: context,
                      textSize: textSize,
                      badgeFontSize: badgeFontSize,
                    ),
                    SizedBox(height: vPad),

                    // Transfer Amount Section
                    Text(
                      "Transfer Amount",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: labelSize,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).primaryColorLight,
                          width: 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: TextField(
                        enabled: false,
                        controller: amountController,
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).hintColor,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(height: vPad),

                    // Action Buttons
                    SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildActionButton(
                              label: "Confirm Transfer",
                              bgColor: Theme.of(context).primaryColorDark,
                              textColor: Colors.white,
                              isPrimary: true,
                              width: width,
                              onPressed: (selectedCarMtag.value == null)
                                  ? null
                                  : _confirmTransfer,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildActionButton(
                              label: "Cancel",
                              bgColor: Colors.white,
                              textColor: Theme.of(context).primaryColorLight,
                              isPrimary: false,
                              width: width,
                              onPressed: () => Get.back(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
