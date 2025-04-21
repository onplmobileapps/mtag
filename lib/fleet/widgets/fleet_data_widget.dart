import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class FleetDataWidget extends StatelessWidget {
  FleetDataWidget({super.key, this.balance, this.companyId, this.userName, this.totalVehicles});
  final _obscured = Rx<bool>(false);
  String? userName, companyId, balance, totalVehicles;
  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Theme.of(context).focusColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(width: 0.2, color: Colors.grey)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userName?.toUpperCase() ?? '',
                    textScaler: TextScaler.noScaling,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Company ID: ',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    TextSpan(
                      text: companyId ?? '',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Baseline(
                baseline: 30,
                baselineType: TextBaseline.alphabetic,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        softWrap: true,
                        text: TextSpan(children: [
                          TextSpan(text: 'Registered Vehicles: ', style: Theme.of(context).textTheme.displaySmall),
                          TextSpan(text: ' ${totalVehicles ?? ''}', style: Theme.of(context).textTheme.displayMedium)
                        ])),
                    SvgPicture.asset(
                      'assets/f4.svg',
                      colorFilter: ColorFilter.mode(Theme.of(context).hintColor, BlendMode.srcIn),
                      height: 40,
                      width: 40,
                      alignment: Alignment.bottomCenter,
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: 0.1,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Available Balance',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _obscured.value
                          ? Text(
                              'PKR ${balance ?? '0.00'}',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: double.parse(balance ?? '0.0') < 35000.00 ? Colors.green : Colors.red,
                                  ),
                              textScaler: TextScaler.noScaling,
                            )
                          : Text(
                              'PKR ••••••',
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                    color: Colors.green,
                                  ),
                              textScaler: TextScaler.noScaling,
                              textAlign: TextAlign.start,
                            ),
                    ),
                    Baseline(
                      baseline: 20,
                      baselineType: TextBaseline.ideographic,
                      child: InkWell(
                        onTap: () {
                          _obscured(!_obscured.value);
                        },
                        child: Icon(
                          _obscured.value ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
