import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/widgets/dashboard_widget.dart';
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
      appBar: AppBar(elevation: 0, title: const Text("My M-Tag")),
      body: Container(
        constraints: const BoxConstraints.expand(),
        height: size.height,
        width: size.width,
        color: Theme.of(context).primaryColor,
        child: Container(
          height: size.height,
          width: size.width,
          margin: const EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ListView.builder(
              itemCount: argument.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () async {
                    argument[index].isactive == 8
                        ? showPopDialog(
                            "You have pending dues on your account. You are not allowed to enter the motorway until your dues are cleared.",
                            () => Get.back(),
                          )
                        : await Get.toNamed(
                            '/mtagDetails',
                            arguments: argument[index],
                          );
                    log(argument[index].toString());
                  },
                  child: Container(
                    key: UniqueKey(),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).disabledColor,
                      borderRadius: BorderRadius.circular(12),
                      border: argument[index].isactive == 8
                          ? Border.all(color: Colors.redAccent, width: 1)
                          : Border.all(
                              color: Theme.of(context).disabledColor,
                              width: 1,
                            ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/mtag_logo.svg',
                                colorFilter: ColorFilter.mode(
                                  Theme.of(context).hintColor,
                                  BlendMode.srcIn,
                                ),
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'M-TAG',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                argument[index].tokenno ?? "",
                                style: Theme.of(
                                  context,
                                ).textTheme.displayMedium,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor,
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${argument[index].ownername}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'PKR ${argument[index].balance}',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  argument[index].registration ?? '',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  argument[index].vehicletype ?? '',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // const SizedBox(height: 30, width: 20),
                            InkWell(
                              onTap: () => argument[index].isactive == 8
                                  ? Container()
                                  : showDialog(
                                      context: Get.context!,
                                      builder: (ctx) {
                                        return DeLinkVehicleDialog(
                                          regId:
                                              argument[index].registration ??
                                              '',

                                          onCancel: () => Get.back(),
                                          onConfirm: () {
                                            Get.back();
                                            dlinkVehicleController.deLinkVehicle(
                                              mtagID:
                                                  argument[index].tokenno ?? '',
                                              rDesc:
                                                  "${0}--${"Vehicle has been sold out."}",
                                              rID: "1",
                                            );
                                          },
                                        );
                                      },
                                    ),
                              child: argument[index].isactive == 8
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.red.withAlpha(77),
                                            blurRadius: 4,
                                            offset: Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).disabledColor,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.delete_forever_outlined,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(width: 2),
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
                            const SizedBox(height: 20),
                            SvgPicture.asset(
                              getVehicleImage(
                                argument[index].vehicletype ?? '',
                              ),
                              height: 40,
                              width: 50,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context).hintColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
