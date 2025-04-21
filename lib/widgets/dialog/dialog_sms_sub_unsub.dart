import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/api_constants.dart';
import '../../constants/analytics.dart';
import '../../controller/home_controller.dart';
import '../../pages/smsalert/controller/update_sms_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/elevated_button.dart';

class SubUnsubDialog extends StatelessWidget {
  final String messageTextUrdu;
  final String messageTextEng;
  final String buttonText;
  final String statusValue; //0 for de-active 1 for activate
  final String mtagID;

  const SubUnsubDialog({
    super.key,
    this.messageTextUrdu = '',
    this.messageTextEng = '',
    this.buttonText = '',
    this.statusValue = '',
    this.mtagID = '',
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).dialogBackgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Image.asset(
                'assets/branding-development.png',
                width: 80.0,
                height: 60.0,
              ),
            ),
            const Divider(
              thickness: 0.3,
              color: Colors.black,
            ),
            const SizedBox(height: 10.0),
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageTextEng,
                    style: Theme.of(context).dialogTheme.contentTextStyle,
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    messageTextUrdu,
                    style: Theme.of(context).dialogTheme.contentTextStyle,
                    textAlign: TextAlign.right,
                  )
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton1(
                      backgroundColor: primarSwatch,
                      onclick: () {
                        Get.back();
                      },
                      text: 'Cancel'),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: ElevatedButton1(
                    textscaller: 0.9,
                    backgroundColor: primarSwatch,
                    onclick: () async {
                      Analytics.subscribeTapped();
                      Navigator.of(context).pop(true);
                      var response = await Get.find<UpdateSmsStatusController>()
                          .getSmsStatus(newValue: statusValue, mtagID: mtagID);
                      if (response.containsKey(APIRESPONSE.SUCCESS)) {
                        showCupertinoModalPopup(
                            context: Get.context!,
                            builder: (_) => CupertinoAlertDialog(
                                  content: Obx(() =>
                                      Text(Get.find<UpdateSmsStatusController>().updateSmsModel.value.message ?? '')),
                                  actions: [
                                    CupertinoDialogAction(
                                      child: const Text('Ok'),
                                      onPressed: () async {
                                        Navigator.of(Get.context!).pop(true);
                                        Get.back();
                                        final controller = Get.find<HomeController>();
                                        await controller.pullRefreshDashboardData();
                                        controller.dashboradData.refresh();
                                      },
                                    )
                                  ],
                                ));
                      }
                    },
                    text: buttonText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
