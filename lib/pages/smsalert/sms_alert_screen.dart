import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mtag_flutterapp/controller/home_controller.dart';
import 'package:mtag_flutterapp/widgets/dialog/dialog_sms_sub_unsub.dart';

import '../dashboard/model/dashboard_model.dart';

class SMSAlertScreen extends StatefulWidget {
  const SMSAlertScreen({super.key});
  @override
  State<SMSAlertScreen> createState() => _SMSAlertScreenState();
}

class _SMSAlertScreenState extends State<SMSAlertScreen> with TickerProviderStateMixin {
  final List<int> items = <int>[1, 2, 3, 6];
  late List<AnimationController> _animationControllers;
  final List<ActiveMtags> arguments = Get.arguments ?? Get.find<HomeController>().dashboradData.value.activeMtags ?? [];
  final String vehicleNum = '';
  final String vehToken = '';

  Map<String, dynamic> _setTextEnglish(String vehicleNum, String vehToken) {
    var subText =
        "Are you sure you want to Subscribe Motorway SMS Alerts on Vehicle No, $vehicleNum and M-Tag ID $vehToken, which cost Rs 75.00/- per Month. Service will Auto Renew in 30 Days.\n\n";
    var unSubText =
        "Are you sure you want to Un-Subscribe Motorway SMS Alerts on Vehicle No, $vehicleNum and M-Tag ID $vehToken.\n\n";

    var statusValue = '';
    return {'subText': subText, 'unSubText': unSubText, 'statusValue': statusValue};
  }

  Map<String, dynamic> _setTextUrdu(String vehicleNum, String vehToken) {
    var subText =
        "کیا آپ واقعی موٹروے ایس ایم ایس الرٹس کو سبسکرائب کرنا چاہتے ہیں جس کی قیمت -/75.00 روپے ماہانہ ہے۔سروس 30 دنوں میں خودکار تجدید ہو جائے گی۔";
    var unSubText = "کیا آپ واقعی موٹروے ایس ایم ایس الرٹس کو ان سبسکرائب کرنا چاہتے ہیں ہے۔";

    var statusValue = '';
    return {'subText': subText, 'unSubText': unSubText, 'statusValue': statusValue};
  }

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(arguments.length, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..forward();
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SMS Subscription'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadiusDirectional.only(
              topEnd: Radius.circular(15),
              topStart: Radius.circular(15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  height: 80,
                  width: 200,
                  child: Image.asset(
                    'assets/mtagbrand.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Vehicles List', style: Theme.of(context).textTheme.displayLarge),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: arguments.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            Map<String, dynamic> texts =
                                _setTextEnglish(arguments[index].registration ?? '', arguments[index].tokenno ?? '');
                            Map<String, dynamic> textsUrdu =
                                _setTextUrdu(arguments[index].registration ?? '', arguments[index].tokenno ?? '');

                            return SubUnsubDialog(
                              messageTextEng: arguments[index].smsStaus == 'Active'
                                  ? texts['unSubText'] ?? ''
                                  : texts['subText'] ?? '',
                              messageTextUrdu: arguments[index].smsStaus == 'Active'
                                  ? textsUrdu['unSubText'] ?? ''
                                  : textsUrdu['subText'] ?? '',
                              buttonText: arguments[index].smsStaus == 'Active' ? "Un-Subscribe" : "Subscribe",
                              statusValue: arguments[index].smsStaus == 'Active' ? "0" : "1",
                              mtagID: arguments[index].tokenno ?? '',
                            );
                          },
                        );
                      },
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _animationControllers[index],
                            curve: Interval(
                              index / items.length,
                              1.0,
                              curve: Curves.easeInOut,
                            ),
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: arguments[index].smsStaus == 'Active' ? Colors.green : Colors.red),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.adaptivePlatformDensity,
                            selected: true,
                            leading: SizedBox(
                              width: 50,
                              child: Image.asset(
                                'assets/suv.png',
                                height: 40,
                                width: 40,
                                color: arguments[index].smsStaus == 'Active' ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${arguments[index].registration}',
                                    style: Theme.of(context).textTheme.displayMedium,
                                  ),
                                  Text(
                                    '${arguments[index].tokenno}',
                                    style: Theme.of(context).textTheme.displayMedium,
                                  )
                                ],
                              ),
                            ),
                            trailing: arguments[index].smsStaus == "Active"
                                ? Image.asset(
                                    'assets/active_mtag.png',
                                    height: 35,
                                  )
                                : Image.asset(
                                    'assets/inactive.png',
                                    height: 35,
                                  ),
                          ),
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
