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
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Text('Toll Details', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            _buildDetailRow('Route', route ?? '$entry - $exit'),
            _buildDetailRow('Vehicle', vehicleName ?? 'Unknown'),
            const Divider(height: 1, color: Colors.grey),
            isCalculating
                ? const CircularProgressIndicator()
                : _buildDetailRow(
                    'Total Toll',
                    '$toll PKR',
                    isTotal: true,
                    valueStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red, fontSize: 18),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}