import 'package:flutter/material.dart';

import '../pages/activity/model/activities_model.dart';

class ActivitiesListView extends StatelessWidget {
  final List<TransData>? activitiesModel;

  const ActivitiesListView({super.key, required this.activitiesModel});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: activitiesModel?.length,
      itemBuilder: (context, index) {
        final transaction = activitiesModel?[index];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                horizontalTitleGap: 8.0,
                leading: const Icon(
                  Icons.receipt_outlined,
                  size: 45,
                  color: Colors.grey,
                ),
                title: Text(
                  'Recharge ${transaction?.logDate ?? ''}',
                  style: Theme.of(context).listTileTheme.titleTextStyle,
                ),
                trailing: Text(
                  'PKR ${transaction?.amount ?? ''}/-',
                  style: Theme.of(context).listTileTheme.titleTextStyle?.copyWith(
                        color: Colors.green,
                      ),
                ),
                subtitle: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction?.orderId ?? '',
                      style: Theme.of(context).listTileTheme.titleTextStyle?.copyWith(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction?.cardNumber ?? '',
                      style: Theme.of(context)
                          .listTileTheme
                          .titleTextStyle
                          ?.copyWith(color: Colors.redAccent, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              indent: 12,
              endIndent: 12,
              thickness: 0.2,
            ),
          ],
        );
      },
    );
  }
}
