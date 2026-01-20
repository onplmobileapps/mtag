import 'package:flutter/material.dart';

Widget buildPaymentOption(
  BuildContext context, {
  required String label,
  required int value,
  required ValueNotifier<int> selectedOptionNotifier,
  required String assetPath,
  ValueNotifier<bool>? showTopupTimer,
  ValueNotifier<bool>? showTimer,
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
              visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
            ),
            child: RadioGroup<int>(
              groupValue: selectedOption,
              onChanged: (newValue) {
                if (remainingTime == Duration.zero) {
                  selectedOptionNotifier.value = newValue!;
                  if (onTap != null) onTap();
                }
              },
              child: RadioListTile<int>(
                isThreeLine: false,
                selected: selectedOption == value,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: value,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontWeight: .w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    remainingTime > Duration.zero
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontSize: 12, color: Colors.red),
                            ),
                          )
                        : Container(),
                    // Image.asset(assetPath, height: 30, width: 45),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                fillColor: WidgetStatePropertyAll(
                  ColorScheme.of(context).primary,
                ),
                activeColor: Theme.of(context).primaryColor,
                radioSide: BorderSide(color: Colors.grey),
                dense: true,

                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                secondary: Image.asset(assetPath, height: 30, width: 45),
              ),
            ),
          );
        },
      );
    },
  );
}
