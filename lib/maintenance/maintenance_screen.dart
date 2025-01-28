import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/elevated_button.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height / 15,
          ),
          SvgPicture.asset('assets/logolight.svg'),
          const SizedBox(
            height: 50,
          ),
          Lottie.asset('assets/maintenance.json'),
          const Spacer(),
          ElevatedButton1(
              onclick: () {
                if (Platform.isAndroid) {
                  SystemNavigator.pop();
                } else if (Platform.isIOS) {
                  exit(0);
                }
              },
              text: 'Exit App'),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
