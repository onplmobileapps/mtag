import 'package:flutter/material.dart';

class OperatorDropdown extends StatelessWidget {
  final String? selectedOperator;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final double leftPadding;

  const OperatorDropdown({
    super.key,
    required this.selectedOperator,
    required this.onChanged,
    this.hintText = "Select Operator",
    this.leftPadding = 10.0,
  });

  // Default operators list
  static final List<OperatorItem> defaultOperators = [
    OperatorItem(name: 'Jazz', image: 'assets/jazz-logo-1.png', value: 1),
    OperatorItem(name: 'Telenor', image: 'assets/telenor.jpg', value: 2),
    OperatorItem(name: 'Ufone', image: 'assets/ufone.png', value: 3),
    OperatorItem(name: 'Warid', image: 'assets/warid.png', value: 4),
    OperatorItem(name: 'Zong', image: 'assets/zong.png', value: 5),
    OperatorItem(name: 'SCO', image: 'assets/sco.webp', value: 6),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final bgColor = isDarkMode
        ? Theme.of(context).cardColor
        : Colors.grey.shade50;
    final borderColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: leftPadding, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedOperator,
          isExpanded: true,
          hint: Text(
            hintText,
            style: TextStyle(
              color: hintColor,
              fontSize: 16,
            ),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          dropdownColor: isDarkMode
              ? Theme.of(context).dialogBackgroundColor
              : Colors.white,
          items: defaultOperators.map((op) {
            return DropdownMenuItem<String>(
              value: op.name,
              child: Row(
                children: [
                  Image.asset(
                    op.image,
                    height: 28,
                    width: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    op.name,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class OperatorItem {
  final String name;
  final String image;
  final int value;
  const OperatorItem({
    required this.name,
    required this.image,
    required this.value
  });
}