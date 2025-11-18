import 'package:flutter/material.dart';

import 'package:mtag_flutterapp/main.dart';
import 'package:mtag_flutterapp/pages/dashboard/model/dashboard_model.dart';

class SelectMtag extends StatelessWidget {
  final List<ActiveMtags>? mtags;
  const SelectMtag({
    required this.onChange,
    this.mtags,
    super.key,
  });
  final Function(Object?) onChange;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: mtags?.length,
        itemBuilder: (context, index) => InkWell(
              onTap: () {
                onChange(mtags?[index].tokenno.toString());
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/suv.png',
                        height: 40,
                        width: 40,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: .start,
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              mtags?[index].tokenno ?? '',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              children: [
                                Text(
                                  mtags?[index].registration ?? '',
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                const Spacer(),
                                Text(
                                  'Rs. ${mtags?[index].balance ?? ''}',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: redAccent),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
