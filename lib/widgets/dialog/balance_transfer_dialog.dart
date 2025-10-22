import 'package:flutter/material.dart';
import '../elevated_button.dart';

class BalanceTransferDialog extends StatefulWidget {
  final List<Map<String, String>> vehicles;
  // Each map: {"registration": "...", "tokenNo": "...", "balance": "..."}

  const BalanceTransferDialog({super.key, required this.vehicles});

  @override
  State<BalanceTransferDialog> createState() => _BalanceTransferDialogState();
}

class _BalanceTransferDialogState extends State<BalanceTransferDialog> {
  Map<String, String>? fromVehicle;
  Map<String, String>? toVehicle;
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    final double containerPadding = isSmallScreen ? 10 : 12;

    Widget vehicleCard(Map<String, String> vehicle) {
      return Container(
        padding: EdgeInsets.all(containerPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: isSmallScreen ? 18 : 20,
              backgroundColor: Colors.white24,
              child: Image.asset(
                'assets/suv.png',
                width: isSmallScreen ? 20 : 24,
                height: isSmallScreen ? 20 : 24,
                color: Colors.white,
              ),
            ),
            SizedBox(width: isSmallScreen ? 8 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle["registration"] ?? "",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: "Poppins",
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle["tokenNo"] ?? "",
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        vehicle["balance"] ?? "",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Future<void> selectVehicle(bool isFrom) async {
      final selected = await showModalBottomSheet<Map<String, String>>(
        context: context,
        barrierColor: Colors.black54,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(12),
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.separated(
              itemCount: widget.vehicles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final vehicle = widget.vehicles[index];
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, vehicle);
                  },
                  child: vehicleCard(vehicle),
                );
              },
            ),
          );
        },
      );

      if (selected != null) {
        setState(() {
          if (isFrom) {
            fromVehicle = selected;
          } else {
            toVehicle = selected;
          }
        });
      }
    }

    return PopScope(
      canPop: false, // disables back button
      child: AlertDialog(
        backgroundColor: Theme.of(context).disabledColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).primaryColorLight,
            width: 1,
          ),
        ),
        title: Center(
          child: Text(
            "Balance Transfer",
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // From Vehicle
            InkWell(
              onTap: () => selectVehicle(true),
              child: Container(
                padding: EdgeInsets.all(containerPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: fromVehicle != null
                    ? vehicleCard(fromVehicle!)
                    : Text(
                        "Select From Vehicle",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // To Vehicle
            InkWell(
              onTap: () => selectVehicle(false),
              child: Container(
                padding: EdgeInsets.all(containerPadding),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: toVehicle != null
                    ? vehicleCard(toVehicle!)
                    : Text(
                        "Select To Vehicle",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // Amount input
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Amount",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColorLight,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColorDark,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton1(
              onclick: () {
                if (fromVehicle == null || toVehicle == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Select both From and To vehicles"),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop({
                  "from": fromVehicle,
                  "to": toVehicle,
                  "amount": amountController.text.trim(),
                });
              },
              text: "Transfer",
              backgroundColor: Theme.of(context).primaryColorDark,
            ),
          ),
        ],
      ),
    );
  }
}
