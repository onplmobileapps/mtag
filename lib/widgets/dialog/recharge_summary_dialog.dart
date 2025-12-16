import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../pages/recharge/model/owner_summary_model.dart';
import '../../widgets/elevated_button.dart';



// Replace with your actual paths


void showRechargeSummaryDialog({
  required BuildContext context,
  required void Function()? onPressed,
  OwnerRechargeModel? rechargeSummaryModel,
 
  required String payId,
}) {
  showDialog(
    barrierDismissible: false,
    useRootNavigator: false,
    context: context,
    builder: (BuildContext context) {
      // Responsive sizing
      final screenSize = MediaQuery.of(context).size;
      final dialogWidth = screenSize.width * 0.85;
      final dialogHeight = screenSize.height * 0.6;

      return Dialog.fullscreen(backgroundColor: ColorScheme.of(context).surface,
        // No need for shape or elevation; handled by adaptive
        child: Container(margin: EdgeInsets.all(16),
          width: dialogWidth,
          height: dialogHeight,
          padding: const EdgeInsets.all(8.0), // Minimal padding, adaptive adds more if needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/close_round.svg',
                      width: 20,
                      height: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              // Scrollable content
              Expanded(flex: 1,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: RechargeSummary(
                    
                      payId: payId,
                      mtagId: rechargeSummaryModel?.data?.first.mTAGID ?? '',
                      vehicle: rechargeSummaryModel?.data?.first.vEHNO ?? '',
                      ballance:
                          rechargeSummaryModel?.data?.first.mTagBalance ?? '',
                      bankCharges:
                          rechargeSummaryModel?.data?.first.bankCharges ?? '',
                      total: double.parse(
                              '${rechargeSummaryModel?.data?.first.totalRechargeAmount}')
                          .toString(),
                      ownerName:
                          rechargeSummaryModel?.data?.first.oWNERNAME ?? '',
                      status:
                          rechargeSummaryModel?.data?.first.iSACTIVE ?? '',
                    ),
                  ),
                ),
              ),
              // Proceed button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: ElevatedButton1(
                    onclick: onPressed,
                    text: "Proceed",
                    // Full-width adaptive
                    
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ignore: must_be_immutable
class RechargeSummary extends StatelessWidget {
  String vehicle;
  String mtagId;
  String ownerName;
  String status;
  String payId;
  String ballance;
  String bankCharges;
  String total;
 

  RechargeSummary(
      {super.key,
      required this.vehicle,
      required this.ballance,
      required this.bankCharges,
      required this.mtagId,
      required this.ownerName,
      required this.payId,
      required this.status,
      required this.total,
      });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recharge Summary',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.redAccent),
          ),
          const Divider(color: Colors.grey, thickness: 1),
          const SizedBox(height: 16),
          Text(
            'Vehicle Details',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          detailRow(context, 'Vehicle:', vehicle),
          const Divider(color: Colors.grey, thickness: 0.5),
          detailRow(context,  'M-TAG ID:', mtagId),
          const Divider(color: Colors.grey, thickness: 0.5),
          detailRow(context, 'Owner Name:', ownerName),
          const Divider(color: Colors.grey, thickness: 0.5),
          detailRow(
            context,
            //'1 for active and o for blocked
            'Status:',
            status == '1' ? 'Verified' : '',
            valueColor: status == '1' ? Colors.green : Colors.grey,
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          const SizedBox(height: 16),
          Text(
            'Transaction Summary',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          detailRow(
            context,
            'Pay via:',
            payId == '0' ? 'Credit/Debit Card' : 'JazzCash Wallet',
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          detailRow(context, 'M-Tag Balance:', ballance,
              valueColor: Colors.green),
          const Divider(color: Colors.grey, thickness: 0.5),
          detailRow(context, 'Bank Charges:', 'PKR $bankCharges'),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey, thickness: 0.5),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //voucher ui
              // Row(
              //   children:  [
              //     Icon(Icons.confirmation_num,color: Colors.redAccent,size: 20,),
              //     SizedBox(width: 5),
              //     Text("Apply a voucher",
              //       style: Theme.of(context).textTheme.displayMedium?.copyWith(
              //           color: Colors.redAccent, fontWeight: FontWeight.bold),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 10),
              // TextField(
              //   maxLength: 10,
              //
              //   decoration: InputDecoration(
              //     filled: true,
              //     fillColor: Colors.grey.shade200,
              //     hintText: "Enter voucher code",
              //     border: const OutlineInputBorder(),
              //     enabledBorder: OutlineInputBorder(
              //       borderSide: BorderSide(color: Colors.grey.shade400),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderSide:  BorderSide(color: Theme.of(context).primaryColor, width: 1),
              //       borderRadius: BorderRadius.circular(5),
              //     ),
              //     suffixIcon: Padding(
              //       padding: const EdgeInsets.only(right: 0),
              //       child: SizedBox(
              //         width: 30,
              //         child: ElevatedButton(
              //           onPressed: () {
              //             // Apply action
              //           },
              //           style: ElevatedButton.styleFrom(
              //             padding: EdgeInsets.zero,
              //             backgroundColor: Theme.of(context).primaryColor,
              //           ),
              //           child: const Text(
              //             "Apply",
              //             style: TextStyle(fontSize: 12),
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Recharge',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  Text(
                    'PKR $total',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          )

        ],
      ),
    );
  }

  Widget detailRow(BuildContext context, String title, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  valueColor ?? Theme.of(context).textTheme.bodyMedium?.color),
        ),
      ],
    );
  }
}
