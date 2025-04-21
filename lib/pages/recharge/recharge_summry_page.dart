import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/user_repo.dart';
import 'controller/recharge_controller.dart';

// ignore: must_be_immutable
class RechargeSummary extends StatelessWidget {
  final String payMentMethod;
  RechargeSummary({super.key, required this.payMentMethod});
  ActionSliderController? slidercontroller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GetX<RechargeController>(
          init: RechargeController(userRepo: UserRepo()),
          builder: (controller) => Container(
            margin: const EdgeInsets.only(top: 4),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 10),
                  child: Text(
                    'Recharge Details',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 0.2),
                  ),
                  child: Column(children: [
                    Text(
                      'Owner Summary',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Row(
                      children: [
                        Text('Vehicle:', style: Theme.of(context).textTheme.displayMedium),
                        const Spacer(),
                        Text(controller.ownerRechargeModel.value?.data?.first.vEHNO ?? '',
                            style: Theme.of(context).textTheme.displayMedium)
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          'M-TAG ID:',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const Spacer(),
                        Text(
                          controller.ownerRechargeModel.value?.data?.first.mTAGID ?? '',
                          style: Theme.of(context).textTheme.displayMedium,
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Owner Name:',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        Flexible(
                            child: Text(
                          controller.ownerRechargeModel.value?.data?.first.oWNERNAME?.toUpperCase() ?? ''.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displayMedium,
                        ))
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          'Status:',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.check_circle_sharp,
                          color: Colors.green,
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          controller.ownerRechargeModel.value?.data?.first.iSACTIVE == '1' ? 'Active' : 'Blocked',
                          style: Theme.of(context).textTheme.displaySmall,
                        )
                      ],
                    ),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).primaryColor, width: 0.2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Recharge Summary',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text('Payment Type:', style: Theme.of(context).textTheme.displayMedium),
                          const Spacer(),
                          Text(payMentMethod, style: Theme.of(context).textTheme.displayMedium)
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text(
                            'M-TAG Balance:',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          const Spacer(),
                          Text(controller.ownerRechargeModel.value?.data?.first.mTagBalance ?? '0.0',
                              style: Theme.of(context).textTheme.displayMedium)
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text('Bank Charges:', style: Theme.of(context).textTheme.displaySmall),
                          const Spacer(),
                          Text(controller.ownerRechargeModel.value?.data?.first.bankCharges ?? '0.0',
                              style: Theme.of(context).textTheme.displayMedium)
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text('Total Recharge Amount:', style: Theme.of(context).textTheme.displayMedium),
                          const Spacer(),
                          Text('${controller.ownerRechargeModel.value?.data?.first.totalRechargeAmount ?? '0.0'}',
                              style: Theme.of(context).textTheme.displayMedium)
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ActionSlider.standard(
              successIcon: const Icon(
                Icons.check_rounded,
                color: Colors.white,
              ),
              controller: slidercontroller,
              backgroundColor: const Color(0xffE6E6E6),
              loadingIcon: const CircularProgressIndicator(color: Colors.white),
              height: 40,
              icon: const Icon(
                Icons.arrow_forward_ios_outlined,
                color: Colors.white,
              ),
              backgroundBorderRadius: BorderRadius.circular(50),
              width: double.infinity,
              action: (controller) async {
                controller.loading(); //starts loading animation
                await Future.delayed(const Duration(seconds: 1));
                controller.success(); //starts success animation
                await Future.delayed(const Duration(seconds: 1));
                controller.reset();
                await Future.delayed(const Duration(milliseconds: 2), () {
                  Get.find<RechargeController>().isSummaryVisible(false);
                  Get.toNamed(
                    '/payment',
                    arguments: {
                      'payId': Get.find<RechargeController>().payId.value,
                      'mtagId': Get.find<RechargeController>().ownerRechargeModel.value?.data?.first.mTAGID,
                      'amount': Get.find<RechargeController>()
                          .ownerRechargeModel
                          .value
                          ?.data
                          ?.first
                          .totalRechargeAmount
                          .toString()
                    },
                  );
                }); //resets the slider
              },
              direction: TextDirection.ltr,
              child: Text(
                'Slide to Proceed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
