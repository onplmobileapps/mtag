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
    OperatorItem(name: 'Jazz', image: 'assets/jazz-logo-1.png'),
    OperatorItem(name: 'Telenor', image: 'assets/telenor.jpg'),
    OperatorItem(name: 'Zong', image: 'assets/zong.png'),
    OperatorItem(name: 'Ufone', image: 'assets/ufone.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: leftPadding, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedOperator,
          isExpanded: true,
          hint: Text(
            hintText,
            style: TextStyle(color: Colors.grey.shade500),
          ),
          icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
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
                  Text(op.name, style: const TextStyle(fontSize: 16)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class OperatorItem {
  final String name;
  final String image;
  const OperatorItem({required this.name, required this.image});
}
