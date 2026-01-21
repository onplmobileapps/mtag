import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/design/home_page.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gradient_appbar.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/dialog/cupertino_dialog.dart';
import '../../widgets/dialog/delink_dialog.dart';
import '../dashboard/model/dashboard_model.dart';
import 'controller/delink_controller.dart';
class MyMtagScreen extends StatelessWidget {
  MyMtagScreen({super.key});

  final List<ActiveMtags> argument = Get.arguments is ActiveMtags
      ? [Get.arguments]
      : Get.arguments ?? [ActiveMtags()];
  final dlinkVehicleController = Get.find<DelinkController>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: GradientAppBar(title: const Text("My M-Tag")),
      body: Container(
        constraints: const BoxConstraints.expand(),
        height: size.height,
        width: size.width,
        color: Theme.of(context).primaryColor,
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListView.builder(
              itemCount: argument.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return MtagCardWidget(
                  argument: argument,
                  dlinkVehicleController: dlinkVehicleController,
                  index: index,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MtagCardWidget extends StatelessWidget {
  const MtagCardWidget({
    super.key,
    required this.argument,
    required this.dlinkVehicleController,
    required this.index,
  });

  final List<ActiveMtags> argument;
  final DelinkController dlinkVehicleController;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<AppGradients>()!.background,
        borderRadius: BorderRadius.circular(12),
        border: argument[index].isactive == 8
            ? Border.all(color: Colors.redAccent, width: 1)
            : Border.all(color: Theme.of(context).disabledColor, width: 1),
      ),
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: .end,
            children: [SizedBox(height: 22,
              child: ActiveBadge(argument[index].isactive))],
          ),
          Container(
            padding: const EdgeInsets.all(8),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  child: Image.asset(
                    getVehicleImage(argument[index].vehicletype ?? ''),
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      FittedBox(
                        child: Row(
                         
                          children: [
                            Text(
                              'Available Balance : ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Rs ${argument[index].balance}',
                              style: TextTheme.of(
                                context,
                              ).bodyLarge?.copyWith(fontWeight: .w500),
                            ),
                          ],
                        ),
                      ),
                      // M-TAG Row
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: argument[index].registration ?? '',
                                style: TextTheme.of(
                                  context,
                                ).bodyMedium?.copyWith(fontSize: 13),
                              ),

                              TextSpan(
                                text: ' • M-TAG ', // rest of text
                                style: TextStyle(
                                  fontFamily: 'biotifbold',
                                  color: Colors.grey, // black color
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: ' #${argument[index].tokenno}',
                                style: TextTheme.of(
                                  context,
                                ).bodyMedium?.copyWith(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      
                      FittedBox(
                        child: Row(
                          mainAxisAlignment: .start,
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              'Vehicle Type : ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '${argument[index].vehicletype}',
                              style: TextTheme.of(context).bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.grey.shade300,
                        thickness: 1.5,
                        height: 8,
                        indent: 1,
                        endIndent: 10,
                      ),

                      // Name Row
                      FittedBox(
                        child: Row(
                          mainAxisAlignment: .start,
                          crossAxisAlignment: .start,
                          children: [
                            Icon(
                              Icons.person_2,
                              color: Colors.green.shade400,
                              size: 19,
                            ),
                            Text(
                              'Owner : ',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              '${argument[index].ownername}',
                              style: TextTheme.of(context).bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Row(mainAxisAlignment: .center,crossAxisAlignment: .center,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (argument[index].isactive == 8) {
                      return;
                    }
                    showDialog(
                      context: Get.context!,
                      builder: (ctx) {
                        return DeLinkVehicleDialog(
                          regId: argument[index].registration ?? '',
                          onCancel: () => Get.back(),
                          onConfirm: () {
                            Get.back();
                            dlinkVehicleController.deLinkVehicle(
                              mtagID: argument[index].tokenno ?? '',
                              rDesc: "${0}--${"Vehicle has been sold out."}",
                              rID: "1",
                            );
                          },
                        );
                      },
                    );
                  },
                  child: argument[index].isactive == 8
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withAlpha(77),
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Blacklisted',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                         
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Row(
                            mainAxisAlignment: .center,
                            crossAxisAlignment: .center,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.delete_forever_outlined,
                                size: 18,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              Spacer(),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (argument[index].isactive == 8) {
                      showPopDialog(
                        "You have pending dues on your account. You are not allowed to enter the motorway until your dues are cleared.",
                        () => Get.back(),
                      );
                    } else {
                      await Get.toNamed(
                        '/mtagDetails',
                        arguments: argument[index],
                      );
                    }
                  },
                  child: Container(
                    height: 35,
                    alignment: .center,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: .circular(18),
                      color: ColorScheme.of(context).surface,
                    ),
                    clipBehavior: Clip.none,
                    child: Text(
                      'View Details',
                      style: TextTheme.of(context).bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
