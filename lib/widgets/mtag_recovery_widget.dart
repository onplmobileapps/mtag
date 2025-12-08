import 'package:flutter/material.dart';
import 'package:mtag_flutterapp/widgets/dashboard_widget.dart';

Widget mtagRecoveryWidget(
  BuildContext context, {
  String? vehType,
  double? height,
  Size? size,
  String? userName,
  String? ball,
  balanceDashboard,
  String? mtagId,
  String? regId,
  String? creditCode,
  String? jazzCode,
  double? blockStatus,
  double? blockAmount,
  String? cnic,
  String? mobileNum,
  double? isBlock,
  bool? showTransferButton,
  bool? showChassisBadge,
  String? chassisNumber,
}) {
  final theme = Theme.of(context);
  final textTheme = theme.textTheme;
  final screenWidth = MediaQuery.of(context).size.width;
  final horizontalPadding = screenWidth * 0.04;
  final elementSpacing = 8.0;
  final borderRadius = 12.0;

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
    child: Container(
      width: screenWidth - 2 * horizontalPadding,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.disabledColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: theme.colorScheme.error, width: 1),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    "assets/alert-octagon.png",
                    color: theme.colorScheme.error,
                    height: 24,
                    width: 24,
                  ),
                  SizedBox(width: elementSpacing),
                  Flexible(
                    child: Text(
                      "M-Tag Blacklisted",
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: elementSpacing),
              Text(
                'You have pending dues on your account. You are not allowed to enter the motorway until your dues are cleared.',
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              SizedBox(height: elementSpacing),
              Row(
                children: [
                  Text('Reg no:', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.error)),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(regId ?? '', style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                  children: [
                    TextSpan(text: 'M-TAG ID: ', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.error)),
                    TextSpan(text: mtagId ?? 'N/A'),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text("Recovery Amount:", style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.error)),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text("Rs $blockAmount", style: textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
                  ),
                ],
              ),
              SizedBox(height: 40),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: ElevatedButton.icon(
              onPressed: () => showPaymentBottomSheet(
                context,
                blackListRecharge: true,
                mtagId: mtagId,
                regId: regId,
                recoveryAmount: blockAmount,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Image.asset("assets/cc_plus.png", color: Colors.white, height: 20, width: 20),
              label: Text(
                "PAY NOW",
                style: textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
