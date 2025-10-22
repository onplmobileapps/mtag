import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/widgets/dashboard_widget.dart';

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
      appBar: AppBar(title: const Text('Vehicle Details'), centerTitle: true),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle details container
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).disabledColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Balance',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'PKR ${arguments.isNotEmpty ? arguments.first.balance ?? '00.00' : '00.00'}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'M-TAG ${arguments.isNotEmpty ? arguments.first.tokenno ?? '' : ''}',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  'Owner: ${arguments.isNotEmpty ? arguments.first.ownername ?? '' : ''}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Registration # ${arguments.isNotEmpty ? arguments.first.registration ?? '' : ''}',
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: SvgPicture.asset(
                                  getVehicleImage(
                                    arguments.first.vehicletype ?? '',
                                  ),
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).hintColor,
                                    BlendMode.srcIn,
                                  ),
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                              const SizedBox(height: 5),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Vehicle: ${arguments.isNotEmpty ? arguments.first.vehicletype ?? '' : ''}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displaySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Recharge button
                ElevatedButton1(
                  backgroundColor: Theme.of(context).primaryColor,
                  width: double.infinity,
                  onclick: () async {
                    if (arguments.isNotEmpty &&
                        arguments.first.tokenno != null) {
                      Get.find<RechargeController>().isPaymentModdeVisible(
                        false,
                      );
                      Get.find<RechargeController>().isSummaryVisible(false);
                      Get.find<RechargeController>().isRechageVisible(true);
                      await Get.toNamed('/recharge', arguments: arguments);
                    } else {
                      log('Error: Invalid arguments or missing token number');
                      // Optionally show an error message to the user
                    }
                  },
                  text: 'Recharge',
                ),
                const SizedBox(height: 15),
                const Text('Recharge History'),
                // Recharge history list
                Expanded(
                  child: FutureBuilder(
                    future: controller.geTollHistory(
                      mtagID: arguments.isNotEmpty
                          ? arguments.first.tokenno
                          : '',
                    ),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Text('Please Wait'));
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
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'M-TAG ${data.iTOKKENNO ?? ''}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displaySmall,
                                    ),
                                    Text(
                                      data.tRANSTIME ?? '',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.displaySmall,
                                    ),
                                  ],
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
