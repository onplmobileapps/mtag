import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';

import '../../widgets/dashboard_widget.dart';
import '../../widgets/dialog/dialog_sms_sub_unsub.dart';
import '../../widgets/gradient_appbar.dart';
import '../../controller/home_controller.dart';
import '../dashboard/model/dashboard_model.dart';

class SMSAlertScreen extends StatefulWidget {
  const SMSAlertScreen({super.key});
  @override
  State<SMSAlertScreen> createState() => _SMSAlertScreenState();
}

class _SMSAlertScreenState extends State<SMSAlertScreen> {
  final List<int> items = <int>[1, 2, 3, 6];

  final List<ActiveMtags> arguments =
      Get.arguments ??
      Get.find<HomeController>().dashboradData.value.activeMtags ??
      [];
  final String vehicleNum = '';
  final String vehToken = '';

  Map<String, dynamic> _setTextEnglish(String vehicleNum, String vehToken) {
    var subText =
        "Are you sure you want to Subscribe Motorway SMS Alerts on Vehicle No, $vehicleNum and M-Tag ID $vehToken, which cost Rs 75.00/- per Month. Service will Auto Renew in 30 Days.\n\n";
    var unSubText =
        "Are you sure you want to Un-Subscribe Motorway SMS Alerts on Vehicle No, $vehicleNum and M-Tag ID $vehToken.\n\n";

    var statusValue = '';
    return {
      'subText': subText,
      'unSubText': unSubText,
      'statusValue': statusValue,
    };
  }

  Map<String, dynamic> _setTextUrdu(String vehicleNum, String vehToken) {
    var subText =
        "کیا آپ واقعی موٹروے ایس ایم ایس الرٹس کو سبسکرائب کرنا چاہتے ہیں جس کی قیمت -/75.00 روپے ماہانہ ہے۔سروس 30 دنوں میں خودکار تجدید ہو جائے گی۔";
    var unSubText =
        "کیا آپ واقعی موٹروے ایس ایم ایس الرٹس کو ان سبسکرائب کرنا چاہتے ہیں ہے۔";

    var statusValue = '';
    return {
      'subText': subText,
      'unSubText': unSubText,
      'statusValue': statusValue,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(title: const Text('SMS Subscription')),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  height: 80,
                  width: 250,
                  child: SvgPicture.asset(
                    'assets/m-tag2.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'Vehicles List',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: .w600),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: .zero,
                  itemCount: arguments.length,
                  itemBuilder: (context, index) {
                    log('Data:${arguments[index].smsStaus}');
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            Map<String, dynamic> texts = _setTextEnglish(
                              arguments[index].registration ?? '',
                              arguments[index].tokenno ?? '',
                            );
                            Map<String, dynamic> textsUrdu = _setTextUrdu(
                              arguments[index].registration ?? '',
                              arguments[index].tokenno ?? '',
                            );

                            return SubUnsubDialog(
                              messageTextEng:
                                  arguments[index].smsStaus == 'Active'
                                  ? texts['unSubText'] ?? ''
                                  : texts['subText'] ?? '',
                              messageTextUrdu:
                                  arguments[index].smsStaus == 'Active'
                                  ? textsUrdu['unSubText'] ?? ''
                                  : textsUrdu['subText'] ?? '',
                              buttonText: arguments[index].smsStaus == 'Active'
                                  ? "Un-Subscribe"
                                  : "Subscribe",
                              statusValue: arguments[index].smsStaus == 'Active'
                                  ? "0"
                                  : "1",
                              mtagID: arguments[index].tokenno ?? '',
                            );
                          },
                        );
                      },

                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 5,
                          left: 16,
                          right: 16,
                        ),
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                          gradient: Theme.of(
                            context,
                          ).extension<AppGradients>()!.gridWidget,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: ListTile(
                          horizontalTitleGap: 6,
                          dense: true,
                          contentPadding: EdgeInsets.only(left: 6),
                          visualDensity: VisualDensity.adaptivePlatformDensity,
                          selected: true,
                          leading: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Image.asset(
                              getVehicleImage(
                                arguments[index].vehicletype ?? '',
                              ),

                              height: 80,
                              width: 90,
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${arguments[index].registration}',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: arguments[index].smsStaus == 'Active'
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : Colors.red.withValues(alpha: 0.15),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              arguments[index].smsStaus ==
                                                  'Active'
                                              ? Colors.green
                                              : Colors.red,
                                          width: 2.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${arguments[index].smsStaus}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color:
                                                arguments[index].smsStaus ==
                                                    'Active'
                                                ? Colors.green.shade700
                                                : Colors.red,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${arguments[index].tokenno}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),

                          // title: Padding(
                          //   padding: const EdgeInsets.only(left: 10),
                          //   child: Column(
                          //     mainAxisAlignment: MainAxisAlignment.start,
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         '${arguments[index].registration}',
                          //         style: Theme.of(
                          //           context,
                          //         ).textTheme.displayMedium,
                          //       ),

                          //     ],
                          //   ),
                          // ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
