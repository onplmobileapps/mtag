import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:mtag_flutterapp/widgets/gradient_appbar.dart';
import '../../pages/tollhistory/toll_history_screen.dart';

import '../../widgets/dashboard_widget.dart';
import '/pages/recharge/controller/recharge_controller.dart';
import '../../pages/tollhistory/controller/tollcontroller.dart';
import '../../widgets/elevated_button.dart';
import '../dashboard/model/dashboard_model.dart';

class MatagDetailScreen extends GetView<TollController> {
  MatagDetailScreen({super.key});
  final arguments = Get.arguments is List<ActiveMtags>
      ? Get.arguments as List<ActiveMtags>
      : Get.arguments != null
      ? [Get.arguments as ActiveMtags]
      : [ActiveMtags()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: const Text('Vehicle Details')),

      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 8,left: 16,right: 16,bottom: 5),
                  decoration: BoxDecoration(
                    gradient: Theme.of(
                      context,
                    ).extension<AppGradients>()!.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Image.asset(
                              getVehicleImage(
                                arguments.first.vehicletype ?? '',
                              ),

                              height: 70,
                              width: 90,
                            ),
                          ),

                          Column(
                            mainAxisAlignment: .start,
                            crossAxisAlignment: .start,
                            children: [
                              Row(
                                mainAxisAlignment: .spaceBetween,
                                children: [
                                  Text(
                                    'Available Balance     ',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    'PKR ${arguments.isNotEmpty ? arguments.first.balance ?? '00.00' : '00.00'}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),

                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topLeft,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            arguments.first.registration ?? '',
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
                                        text:
                                            ' #${arguments.first.tokenno ?? ''}',
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
                                      '${arguments.first.vehicletype}',
                                      style: TextTheme.of(context).bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton1(height: 35,
                        backgroundColor: Theme.of(context).primaryColor,
                        width: double.infinity,
                        onclick: () async {
                          if (arguments.isNotEmpty &&
                              arguments.first.tokenno != null) {
                            Get.find<RechargeController>()
                                .isPaymentModdeVisible(false);
                            Get.find<RechargeController>().isSummaryVisible(
                              false,
                            );
                            Get.find<RechargeController>().isRechageVisible(
                              true,
                            );
                            await Get.toNamed(
                              '/recharge',
                              arguments: arguments,
                            );
                          } else {
                            log(
                              'Error: Invalid arguments or missing token number',
                            );
                            // Optionally show an error message to the user
                          }
                        },
                        text: 'Recharge M-TAG',
                         icon: Icon(Icons.add_circle),
      isShowIcon: true,
      iconAlignment: .start,
                      ),
                    ],
                  ),
                ),

                // Recharge button
                const SizedBox(height: 15),
                 Text('Recharge History',style: TextTheme.of(context).labelLarge,),
                Expanded(
                  child: FutureBuilder(
                    future: controller.geTollHistory(
                      mtagID: arguments.isNotEmpty
                          ? arguments.first.tokenno
                          : '',
                    ),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ListSkeleton();
                      }

                      var transactions = controller
                          .tollHistoryModel
                          .value
                          ?.data
                          ?.allTransactions;
                      if (transactions == null || transactions.isEmpty) {
                        return const Center(
                          child: Text('No transactions found'),
                        );
                      }

                      return ListView.builder(
                        itemCount: transactions.length,
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (ctx, index) {
                          var data = transactions[index];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.only(top: 5),
                                title: Text(data.eXITSTATIONNAME ?? ''),
                                subtitle: DefaultTextStyle(
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall!,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('M-TAG ${data.iTOKKENNO ?? ''}'),
                                      Text(data.tRANSTIME ?? ''),
                                    ],
                                  ),
                                ),
                                trailing: Text(
                                  '${data.cR ?? ''} PKR ${data.fARE ?? ''}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.green),
                                ),
                              ),
                              const Divider(thickness: 0.5),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
