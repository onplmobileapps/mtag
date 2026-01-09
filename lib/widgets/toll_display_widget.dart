import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';

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
          decoration: BoxDecoration(
            gradient: Theme.of(context).extension<AppGradients>()!.background,
            // Dark blue to match the image
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
                  style: Theme.of(context).textTheme.bodyLarge,
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
            color: Color(0xff12B76A),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              spacing: 10,
              mainAxisAlignment: .spaceBetween,
              children: [
                Text(
                  'Total Toll',
                  style: TextTheme.of(context).titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: .w600,
                  ),
                ),
                Text(
                  toll != null ? 'Rs. $toll PKR' : '',
                  style: TextTheme.of(context).bodyMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: .w600,
                  ),
                ),
              ],
            ),
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isTotal ? 8 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text('$label:'), Text(value)],
      ),
    );
  }
}
