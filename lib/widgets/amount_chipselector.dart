import 'package:flutter/material.dart';

class AmountChipSelector extends StatelessWidget {
  final List<int> amounts;
  final TextEditingController controller;

  const AmountChipSelector({
    super.key,
    required this.amounts,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: amounts
          .map((amount) => GestureDetector(
                onTap: () => controller.text = amount.toString(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Chip(
                    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 0.5,
                      ),
                    ),
                    labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    label: Text(
                      "$amount",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    elevation: 4,
                    avatar: CircleAvatar(
                      radius: 10,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Text(
                        'Rs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}
