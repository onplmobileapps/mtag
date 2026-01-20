import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';

import '../../pages/recharge/model/owner_summary_model.dart';
import '../../widgets/elevated_button.dart';

void showRechargeSummaryDialog({
  required BuildContext context,
  required void Function()? onPressed,
  OwnerRechargeModel? rechargeSummaryModel,
  required String payId,
}) {
  final data = rechargeSummaryModel?.data?.first;
  
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: Theme.of(context).extension<AppGradients>()!.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: RechargeSummary(
            vehicle: data?.vEHNO ?? '',
            mtagId: data?.mTAGID ?? '',
            ownerName: data?.oWNERNAME ?? '',
            status: data?.iSACTIVE ?? '',
            payId: payId,
            ballance: data?.mTagBalance ?? '',
            bankCharges: data?.bankCharges ?? '',
            total: double.tryParse("${data?.totalRechargeAmount ?? '0'}").toString(),
            onPressed: onPressed,
          ),
        ),
      );
    },
  );
}

class RechargeSummary extends StatelessWidget {
  final String vehicle;
  final String mtagId;
  final String ownerName;
  final String status;
  final String payId;
  final String ballance;
  final String bankCharges;
  final String total;
  final void Function()? onPressed;

  const RechargeSummary({
    super.key,
    required this.vehicle,
    required this.mtagId,
    required this.ownerName,
    required this.status,
    required this.payId,
    required this.ballance,
    required this.bankCharges,
    required this.total,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Recharge Summary',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.redAccent,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset(
                  'assets/close_round.svg',
                  width: 24,
                  height: 24,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        
        const Divider(color: Colors.grey, thickness: 1),
        
        // Content
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Details
                _sectionTitle(context, 'Vehicle Details'),
                _detailRow(context, 'Vehicle:', vehicle),
                _detailRow(context, 'M-TAG ID:', mtagId),
                _detailRow(context, 'Owner Name:', ownerName),
                _detailRow(
                  context,
                  'Status:',
                  status == '1' ? 'Verified' : 'Blocked',
                  status == '1' ? Colors.green : Colors.grey,
                ),
                
                const SizedBox(height: 16),
                
                // Transaction Summary
                _sectionTitle(context, 'Transaction Summary'),
                _detailRow(
                  context,
                  'Pay via:',
                  payId == '0' ? 'Credit/Debit Card' : 'JazzCash Wallet',
                ),
                _detailRow(context, 'M-Tag Balance:', ballance, Colors.green),
                _detailRow(context, 'Bank Charges:', 'PKR $bankCharges'),
                
                const SizedBox(height: 16),
          

                
                // Total
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        
        // Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton1(
            onclick: onPressed,
            text: "Proceed",
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
          color: Colors.redAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String title, String value, [Color? valueColor]) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor ?? Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.grey, thickness: 0.5),
      ],
    );
  }
}