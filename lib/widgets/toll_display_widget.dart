import 'package:flutter/material.dart';

class TollDisplay extends StatelessWidget {
  final double padding;
  final bool isCalculating;
  final String? entry;
  final String? exit;
  final String? vehicleName;
  final String? toll;
  final String? route;

  const TollDisplay({
    super.key,
    required this.padding,
    required this.isCalculating,
    required this.entry,
    required this.exit,
    required this.vehicleName,
    required this.toll,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Color(0xff20285F), // Dark blue to match the image
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toll Details',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                _buildDetailRow(
                  'Route',
                  route ?? '$entry—$exit', // Use em dash to match image
                  context,
                ),
                _buildDetailRow(
                  'Vehicle type',
                  vehicleName ?? 'Unknown',
                  context,
                ),
               
              ],
            ),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: _buildDetailRow(
            'Total Toll',
            toll != null ? 'Rs. $toll PKR' : '',
            context,
            isTotal: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    BuildContext context, {
    bool isTotal = false,
  }) {
    TextStyle labelStyle = TextStyle(
      color: isTotal ? Colors.white : Colors.white,
      fontWeight: isTotal ? FontWeight.normal : FontWeight.normal,
      fontSize: 14,
    );

    TextStyle valueStyle = TextStyle(
      color: isTotal ? Colors.white : Colors.white,
      fontSize: isTotal ? 18 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
    );

    if (label == 'Route' && !isTotal) {
      valueStyle = const TextStyle(
        color: Colors.white,
 
        fontSize: 14,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isTotal ? 8 : 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: labelStyle,
          ),
          Text(
            value,
            style: valueStyle,
          ),
        ],
      ),
    );
  }
}

  

