import 'package:flutter/material.dart';

import '../elevated_button.dart';

class DeLinkVehicleDialog extends StatelessWidget {
  final String regId;

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const DeLinkVehicleDialog({
    super.key,
    required this.regId,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).disabledColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).primaryColorLight,
          width: 0.5,
        ),
      ),
      title: Center(
        child: Text(
          "Confirm Deletion",
          style: TextStyle(color: Theme.of(context).primaryColorLight),
        ),
      ),
      content: Text(
        "Vehicle Registration Number '$regId' will be deleted from your account.\n\nDo you want to delete?",
        style: TextStyle(
          color: Theme.of(context).primaryColorLight,
          fontSize: Theme.of(context).textTheme.labelLarge?.fontSize,
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton1(
                onclick: onCancel,
                text: "Cancel",
                backgroundColor: Theme.of(context).primaryColorDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton1(
                onclick: onConfirm,
                text: "Delete",
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
