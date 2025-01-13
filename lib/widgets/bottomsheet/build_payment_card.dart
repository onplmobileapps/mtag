import 'package:flutter/material.dart';

Widget buildPaymentOption(
  BuildContext context, {
  required String label,
  required int value,
  required ValueNotifier<int> selectedOptionNotifier,
  
  required String assetPath,
  ValueNotifier<bool>?showTopupTimer,
    ValueNotifier<bool>?showTimer,

  ValueNotifier<Duration>? timerNotifier,
  Function()? onTap,
}) {
  return ValueListenableBuilder<int>(
    valueListenable: selectedOptionNotifier,
    builder: (context, selectedOption, child) {
      return ValueListenableBuilder<Duration>(
        valueListenable: timerNotifier ?? ValueNotifier(Duration.zero),
        builder: (context, remainingTime, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              visualDensity: VisualDensity(horizontal: -2, vertical: -2),
            ), // Adjust visual density
            child: RadioListTile<int>(isThreeLine: false,selected: true,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              value: value,
              groupValue: selectedOption,
              onChanged: (int? newValue) {
                if (newValue != null && remainingTime == Duration.zero) {
                  selectedOptionNotifier.value = newValue;
                  if (onTap != null) {
                    onTap();
                  }
                }
              },
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    assetPath,
                    height: 30,
                    width: 45,
                  ),
                  const SizedBox(width: 8), // Add some spacing
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0), // Reduce internal padding
              secondary: remainingTime > Duration.zero
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0), // Adjust spacing to fine-tune alignment
                      child: Text(
                        '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12, color: Colors.red),
                      ),
                    )
                  : null,
            ),
          );
        },
      );
    },
  );
}
