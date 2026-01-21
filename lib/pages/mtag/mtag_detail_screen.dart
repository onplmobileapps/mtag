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
    return SafeArea(top: false,
      child: Scaffold(
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
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 16,
                      right: 16,
                      bottom: 5,
                    ),
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
                                Row(
                                
                                  children: [
                                    Text(
                                      'Available Balance  ',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      'Rs ${arguments.isNotEmpty ? arguments.first.balance ?? '00.00' : '00.00'}',
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
                                // FittedBox(
                                //   child: Row(
                                //     mainAxisAlignment: .start,
                                //     crossAxisAlignment: .start,
                                //     children: [
                                //       Text(
                                //         'Vehicle Type : ',
                                //         style: TextStyle(color: Colors.grey),
                                //       ),
                                //       Text(
                                //         '${arguments.first.vehicletype}',
                                //         style: TextTheme.of(context).bodyMedium,
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton1(
                          height: 35,
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
                  const SizedBox(height: 10),
                  Text(
                    'Recharge History',
                    style: TextTheme.of(context).titleLarge,
                  ),
                       const SizedBox(height: 8),
                  Expanded(flex: 1,
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
      
                        return ListView.builder(scrollDirection: .vertical,
                          itemCount: transactions.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemBuilder: (ctx, index) {
                            var data = transactions[index];
                            return Container(margin: .only(bottom:4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: Theme.of(context).extension<AppGradients>()!.gridWidget
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(margin: .only(bottom:4,right:8),
                                  width: 50,
                                  height: 60,
                                  decoration: BoxDecoration(borderRadius: .circular(8),color: ColorScheme.of(context).surface,
                                    shape: BoxShape.rectangle,
                                    
                                  ),
                                  child:  FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Image.asset(
                                getVehicleImage(
                                  arguments.first.vehicletype ?? '',
                                ),
      
                                height: 80,
                                width: 90,
                              ),
                            ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        data.eXITSTATIONNAME ?? 'Unknown Station',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).colorScheme.onSurface,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green.withValues(alpha:0.2),
                                            Colors.green.withValues(alpha:0.1),
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        '${data.cR ?? ''} PKR ${data.fARE ?? ''}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Container(
                                  margin: const EdgeInsets.only(top: 4,bottom: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.confirmation_number,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'M-TAG ${data.iTOKKENNO ?? ''}',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Theme.of(context).colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            data.tRANSTIME ?? '',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
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
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
