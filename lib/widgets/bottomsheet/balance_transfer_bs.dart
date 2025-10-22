import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';

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
  String? selectedCar;
  String? selectedCarMtag;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.balance);
    selectedCar = widget.dropDownCars.first["carNumber"]; 
    selectedCarMtag = widget.dropDownCars.first["mtagID"];
  }

  Widget _actionButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback? onPressed,
    required bool isPrimary,
    required double fontSize,
    required bool isLarge,
  }) {
    final button = isPrimary
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            onPressed: onPressed,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
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
            ),
            onPressed: onPressed,
            child: Text(
              label,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            ),
          );

    return SizedBox(
      height: isLarge ? 52 : 48,
      width: double.infinity,
      child: button,
    );
  }

  Future<void> _confirmTransfer() async {
    final balance = double.tryParse(widget.balance ?? '0') ?? 0.0;

    if (balance <= 0.0) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            "Insufficient Balance",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "You don't have enough balance to perform this transfer.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Get.back(),
              isDefaultAction: true,
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    Get.back();
    await Get.find<HomeController>().transferBalanceCall(
      cnicNumber: widget.cnicNumber,
      mobileNumber: widget.mobileNumber,
      fromMtag: widget.mtagid,
      toMtag: selectedCarMtag!,
      amount: balance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final isSmall = width < 360;
    final isMedium = width < 600 && width >= 360;
    final isLarge = width >= 600;

    final hPad = isLarge ? 32.0 : (isMedium ? 20.0 : 16.0);
    final vPad = isLarge ? 24.0 : 16.0;
    final labelSize = isLarge ? 18.0 : 16.0;
    final textSize = isLarge ? 16.0 : 14.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: size.height * 0.9,
        maxWidth: isLarge ? 600 : double.infinity,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isSmall ? 36 : 48,
              height: 5,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// --- Title ---
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Balance Transfer",
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: vPad),

            /// --- Current Vehicle Info ---
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).primaryColorLight,
                  width: 0.5,
                ),
              ),
              padding: EdgeInsets.all(isSmall ? 12 : 16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmall ? 10 : 12),
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
                      width: isSmall ? 24 : 28,
                      height: isSmall ? 24 : 28,
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
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Available Balance",
                          style: TextStyle(
                            fontSize: isSmall ? 11 : 12,
                            color: Theme.of(context).primaryColorLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: vPad),

            /// --- Select Vehicle ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Select Vehicle",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: labelSize,
                  color: Theme.of(context).primaryColorLight,
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCar,
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                car["carNumber"],
                                style: TextStyle(fontSize: textSize),
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
                                ).primaryColorLight.
                                withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Rs.${car["balance"]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: isSmall ? 12 : 13,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCar = value;
                      selectedCarMtag = widget.dropDownCars.firstWhere(
                        (c) => c["carNumber"] == value,
                      )["mtagID"];
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: vPad),

            /// --- Transfer Amount ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transfer Amount",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: labelSize,
                  color: Theme.of(context).primaryColorLight,
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: vPad),

            /// --- Buttons ---
            SafeArea(
              top: false,
              child: isSmall
                  ? Column(
                      children: [
                        _actionButton(
                          label: "Confirm Transfer",
                          bgColor: Theme.of(context).canvasColor,
                          textColor: Colors.white,
                          isPrimary: true,
                          fontSize: textSize,
                          isLarge: isLarge,
                          onPressed: _confirmTransfer,
                        ),
                        const SizedBox(height: 12),
                        _actionButton(
                          label: "Cancel",
                          bgColor: Colors.white,
                          textColor: Theme.of(context).primaryColorLight,
                          isPrimary: false,
                          fontSize: textSize,
                          isLarge: isLarge,
                          onPressed: () => Get.back(),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _actionButton(
                            label: "Confirm Transfer",
                            bgColor: Theme.of(context).primaryColorDark,
                            textColor: Colors.white,
                            isPrimary: true,
                            fontSize: textSize,
                            isLarge: isLarge,
                            onPressed: _confirmTransfer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _actionButton(
                            label: "Cancel",
                            bgColor: Colors.white,
                            textColor: Theme.of(context).primaryColorLight,
                            isPrimary: false,
                            fontSize: textSize,
                            isLarge: isLarge,
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
