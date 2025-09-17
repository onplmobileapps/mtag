import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/analytics.dart';
import 'package:mtag_flutterapp/widgets/dashboard_widget.dart';
import 'package:mtag_flutterapp/widgets/dialog/d_link_dialog.dart';

import '../dashboard/model/dashboard_model.dart';

class MyMtagScreen extends StatelessWidget {
  MyMtagScreen({super.key});

  final List<ActiveMtags> argument = Get.arguments is ActiveMtags
      ? [Get.arguments]
      : Get.arguments ?? [ActiveMtags()];

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
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(
                    constraints: const BoxConstraints.expand(),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 5.0),
                          child: Icon(Icons.delete, size: 25.0),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Text(
                            'Swipe to Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      showDialog(
                        context: Get.context!,
                        builder: (ctx) {
                          return DelinkVehicleDialog(argument: argument[index]);
                        },
                      );
                    }
                    return null;
                  },
                  child: InkWell(
                    onTap: () async {
                      Analytics.selectedMTag(
                        argument[index].tokenno.toString(),
                      );
                      await Get.toNamed(
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
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
                                onTap: () => showDialog(
                                  context: Get.context!,
                                  builder: (ctx) {
                                    return DelinkVehicleDialog(
                                      argument: argument[index],
                                    );
                                  },
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios,
                                        size: 12,
                                        color: Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'De-Link',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.delete_outline,
                                        size: 18,
                                        color: Colors.red.shade700,
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
