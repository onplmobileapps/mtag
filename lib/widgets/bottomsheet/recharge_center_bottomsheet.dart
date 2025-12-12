import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../class/recharge_center.dart';
import '../elevated_button.dart';

class RechargeCenterBottomSheet extends StatelessWidget {
  final RechargeCenter center;
  final VoidCallback onOpenMap;

  const RechargeCenterBottomSheet({
    super.key,
    required this.center,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = center.isOpenNow;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,

        children: [
          Row(
            children: [
              SvgPicture.asset('assets/r_center.svg'),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SvgPicture.asset('assets/rbadge.svg'),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: isOpen ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOpen ? 'Open Now' : 'Closed',
                          style: TextStyle(
                            color: isOpen ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            'Call our helpline 1313 to get quick help on queries related to your M-Tag',
            style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.w400,
              fontSize: 16.0,
            ),
          ),

          const SizedBox(height: 24),

          _infoRow(context, Icons.access_time_rounded, 'Timing', center.timing),
          const SizedBox(height: 16),
          _infoRow(
            context,
            Icons.info_outlined,
            'Information',
            center.information,
          ),

          const SizedBox(height: 32),

          ElevatedButton1(
            backgroundColor: ColorScheme.of(context).primary,
            width: double.infinity, // theme primary
            foregroundColor: ColorScheme.of(context).surfaceDim,
            onclick: onOpenMap,
            text: "Open in Google Maps",
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            height: 50,
            textscaller: 1.5,
            icon: const Icon(Icons.arrow_forward),
            iconRight: true,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorScheme.of(context).surface,
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.all(color: ColorScheme.of(context).outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: Theme.of(context).primaryColorLight),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
