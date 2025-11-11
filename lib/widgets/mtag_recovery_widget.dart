import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  return LayoutBuilder(
    builder: (context, constraints) {
      final double screenWidth = MediaQuery.sizeOf(context).width;
      final double screenHeight = MediaQuery.sizeOf(context).height;

      final double availableWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : screenWidth;

      final double containerHeight = height ?? screenHeight * 0.22;

      final double horizontalPadding = availableWidth * 0.04;
      final double containerPadding = containerHeight * 0.06;
      final double elementSpacing = containerHeight * 0.04;
      final double fontSizeBase = containerHeight * 0.055;
      final double borderRadius = containerHeight * 0.05;
      final double iconSize = containerHeight * 0.08;
      final double buttonHeight = containerHeight * 0.20;
      final double buttonWidth = availableWidth * 0.30;

      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Container(
              width: availableWidth - (horizontalPadding * 2),
              padding: EdgeInsets.all(containerPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: Colors.redAccent,
                  width: availableWidth * 0.0013,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/alert-octagon.png",
                            color: Colors.red[700],
                            height: iconSize,
                            width: iconSize,
                          ),
                          SizedBox(width: elementSpacing),
                          Flexible(
                            child: Text(
                              "M-Tag Blacklisted",
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: fontSizeBase * 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: elementSpacing * 0.8),

                      Text(
                        'You have pending dues on your account. You are not allowed to enter the motorway until your dues are cleared.',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: fontSizeBase * 0.94,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                      ),

                      SizedBox(height: elementSpacing * 1.2),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Reg no:',
                            style: TextStyle(
                              fontSize: fontSizeBase,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: elementSpacing * 0.5),
                          Flexible(
                            child: Text(
                              regId ?? '',
                              style: TextStyle(
                                fontSize: fontSizeBase,
                                color: Colors.red.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: elementSpacing * 0.3),

                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: fontSizeBase,
                            color: Colors.red.shade600,
                          ),
                          children: [
                            TextSpan(
                              text: 'M-TAG ID: ',
                              style: TextStyle(
                                fontSize: fontSizeBase,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: mtagId ?? 'N/A',
                              style: TextStyle(
                                fontSize: fontSizeBase,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: elementSpacing * 0.3),

                      Row(
                        children: [
                          Text(
                            "Recovery Amount:",
                            style: TextStyle(
                              fontSize: fontSizeBase,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: elementSpacing * 0.5),
                          Flexible(
                            child: Text(
                              "Rs $blockAmount",
                              style: TextStyle(
                                fontSize: fontSizeBase,
                                color: Colors.red.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: buttonHeight * 0.4),
                    ],
                  ),

                  Positioned(
                    bottom: 20,
                    right: 8,
                    child: SizedBox(
                      height: buttonHeight,
                      width: buttonWidth,
                      child: ElevatedButton(
                        onPressed: () => showPaymentBottomSheet(
                          context,
                          blackListRecharge: true,
                          mtagId: mtagId,
                          regId: regId,
                          recoveryAmount: blockAmount,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          padding: EdgeInsets.symmetric(
                            horizontal: buttonWidth * 0.08,
                            vertical: buttonHeight * 0.15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              borderRadius * 0.6,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/cc_plus.png",
                              color: Colors.white,
                              height: iconSize * 0.9,
                              width: iconSize * 0.9,
                            ),
                            SizedBox(width: elementSpacing * 0.6),
                            Flexible(
                              child: Text(
                                "PAY NOW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeBase * 0.9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
