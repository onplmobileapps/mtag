// ignore_for_file: must_be_immutable
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';

import '../../constants/analytics.dart';
import '../../main.dart';
import '../../pages/recharge/controller/recharge_controller.dart';
import '../../pages/recharge/recharge_new_design.dart';
import '../../widgets/textform_widget.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../../pages/recharge/recharge_summry_page.dart';
import '../../pages/recharge/select_mtag.dart';
import '../../widgets/amount_entry_widget.dart';

class RechargePage extends StatefulWidget {
  List<ActiveMtags>? mtags;
  RechargePage({super.key, this.mtags}) {
    if (Get.arguments is List<ActiveMtags>) {
      mtags = Get.arguments as List<ActiveMtags>;
    } else {
      mtags = [ActiveMtags()];
    }
  }

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  final amountcontroller = TextEditingController(), mtagcontroller = TextEditingController();
  @override
  void dispose() {
    Get.find<RechargeController>().isPaymentModdeVisible(false);
    Get.find<RechargeController>().isSummaryVisible(false);
    Get.find<RechargeController>().isPaymentModdeVisible(false);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Analytics.rechargeMTagScreenDisplayed();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Recharge M-Tag'),
          bottom: TabBar(
            physics: const NeverScrollableScrollPhysics(),
            isScrollable: false,
            padding: const EdgeInsets.only(bottom: 2),
            unselectedLabelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
            labelStyle:
                const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 14),
            indicator: UnderlineTabIndicator(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  width: 1.5,
                  color: Colors.white,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 1)),
            labelPadding: const EdgeInsets.all(4),
            labelColor: Colors.white,
            indicatorWeight: 0.1,
            indicatorColor: Colors.white,
            dividerColor: Colors.transparent,
            tabs: const [
              Text(
                'Recharge Self',
              ),
              Text('Recharge Others'),
            ],
          ),
        ),
        body: Container(
          constraints: const BoxConstraints.expand(),
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          color: Theme.of(context).primaryColor,
          child: Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                )),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        RechargeSelfPage(),
                        // MtagPanel(
                        //   mtags: widget.mtags,
                        //   controller: mtagcontroller,
                        //   isOther: false,
                        // ),
                        const OtheRecahrge(),
                      ],
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

class MtagPanel extends StatelessWidget {
  TextEditingController? controller;
  bool? isOther;
  List<ActiveMtags>? mtags;
  MtagPanel({
    super.key,
    this.mtags,
    this.isOther,
    this.controller,
  });
  var isExpanded = true.obs;
  var selectedMtag = ''.obs;
  var isRechageVisible = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOther == true ? 'Enter M-TAG ID' : 'Select MTAG',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Spacer(),
              Text(
                selectedMtag.value,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(
                width: 4,
              ),
              InkWell(
                onTap: () {
                  isExpanded(!isExpanded.value);
                  isRechageVisible(false);
                },
                child: Icon(isExpanded.value ? Icons.keyboard_arrow_down_outlined : Icons.keyboard_arrow_up_outlined),
              )
            ],
          ),
          isOther == true
              ? CustomTExtField(
                  textInputAction: TextInputAction.next,
                  fillColor: Theme.of(context).primaryColorDark,
                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                  maxLength: 8,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                  validator: (p0) {
                    if (p0!.isEmpty || p0.length > 8) return 'Enter 8 digit value';
                    return null;
                  },
                  controller: controller,
                  onTapOutside: (v) {
                    FocusScope.of(context).unfocus();
                    Get.find<RechargeController>().isPaymentModdeVisible(false);
                    Get.find<RechargeController>().isSummaryVisible(false);
                    isRechageVisible(true);
                  },
                  onEditingComplete: () {
                    Get.find<RechargeController>().setMtagId(controller?.text ?? '');
                    selectedMtag(controller?.text ?? '');

                    Get.find<RechargeController>().isPaymentModdeVisible(false);
                    Get.find<RechargeController>().isSummaryVisible(false);
                    isRechageVisible(true);
                    FocusScope.of(context).nextFocus();
                  },
                )
              : Visibility(
                  visible: isExpanded.value,
                  child: Expanded(
                    child: SelectMtag(
                        mtags: mtags,
                        onChange: (v) {
                          selectedMtag(v.toString());
                          Get.find<RechargeController>().setMtagId(v.toString());
                          isExpanded(false);
                          isRechageVisible(true);
                        }),
                  ),
                ),
          const SizedBox(
            height: 10,
          ),
          Visibility(visible: isRechageVisible.value, child: Expanded(child: RechargePanel())),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

class RechargePanel extends StatelessWidget {
  RechargePanel({
    super.key,
  });
  var selectedAmount = ''.obs;

  TextEditingController? controller;
  final _controler = Get.find<RechargeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recharge Amount',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Spacer(),
              Text(
                selectedAmount.value,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(
                width: 4,
              ),
              InkWell(
                onTap: () {
                  _controler.isRechageVisible(!_controler.isRechageVisible.value);
                  _controler.isPaymentModdeVisible(false);
                  _controler.isSummaryVisible(false);
                },
                child: Icon(_controler.isRechageVisible.value
                    ? Icons.keyboard_arrow_up_outlined
                    : Icons.keyboard_arrow_down_outlined),
              )
            ],
          ),
          Visibility(
            visible: _controler.isRechageVisible.value,
            child: AmountWidget(
                amountChange: (v) {
                  selectedAmount(
                    v,
                  );
                  _controler.setAmount(v);
                },
                controller: controller),
          ),
          const SizedBox(
            height: 10,
          ),
          Visibility(visible: _controler.isPaymentModdeVisible.value, child: Expanded(child: PaymentModeSelection()))
        ],
      ),
    );
  }
}

class PaymentModeSelection extends StatelessWidget {
  PaymentModeSelection({super.key});
  var selectedPaymentMode = ''.obs;

  var isCardVisible = true.obs;
  final rechargeController = Get.find<RechargeController>();
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Spacer(),
              Text(
                selectedPaymentMode.value,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(
                width: 4,
              ),
              InkWell(
                onTap: () {
                  rechargeController.isPaymentModdeVisible(!rechargeController.isPaymentModdeVisible.value);
                },
                child: Icon(rechargeController.isPaymentModdeVisible.value
                    ? Icons.keyboard_arrow_up_outlined
                    : Icons.keyboard_arrow_down_outlined),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (isCardVisible.value) ...[
            _buildCardWidget(
              context,
              title: 'Debit/Credit Card',
              image: 'assets/creditcard.png',
              amount: '0',
              onTap: () async {
                Analytics.creditDebitTapped();
                rechargeController.setPayId('0');
                isCardVisible(false);
                selectedPaymentMode('Debit/Credit Card');
                rechargeController.getOwnerRechargeDetails(
                    onError: () {},
                    amount: rechargeController.rechargeAmount.value,
                    payId: '0',
                    mtagId: rechargeController.mtagId.value);

                isCardVisible(false);

                log(isCardVisible.value.toString());
              },
            ),
            const SizedBox(
              height: 10,
            ),
            _buildCardWidget(
              context,
              title: 'JazzCash Wallet',
              image: 'assets/jazzcash.png',
              amount: '20',
              onTap: () async {
                Analytics.jazzCashTapped();
                rechargeController.setPayId('1');
                selectedPaymentMode('JazzCash Wallet');
                rechargeController.getOwnerRechargeDetails(
                    onError: () {},
                    amount: rechargeController.rechargeAmount.value,
                    payId: '1',
                    mtagId: rechargeController.mtagId.value);

                isCardVisible(false);
              },
            ),
          ],
          Visibility(
            visible: rechargeController.isSummaryVisible.value,
            child: RechargeSummary(
              payMentMethod: selectedPaymentMode.toString(),
            ),
          )
        ],
      ),
    );
  }

  _buildCardWidget(BuildContext context, {String? image, String? title, String? amount, Callback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Theme.of(context).disabledColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor)),
        width: double.infinity,
        child: Row(
          children: [
            Image.asset(
              image ?? '',
              height: 50,
              width: 50,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              title ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Column(
              children: [
                const Text(
                  'Charges',
                  style: TextStyle(color: redAccent),
                ),
                Text(
                  'PKR $amount./-',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class OtheRecahrge extends StatefulWidget {
  const OtheRecahrge({super.key});

  @override
  State<OtheRecahrge> createState() => _OtheRecahrgeState();
}

class _OtheRecahrgeState extends State<OtheRecahrge> {
  final _mtagController = TextEditingController();

  TextEditingController? amountController;

  final _rechargeController = Get.find<RechargeController>();

  var isExpanded = Rx<bool>(false);
  var isTextField = Rx<bool>(true);

  var isRechageVisible = Rx<bool>(false);

  var mtagValue = Rx<String>('');

  var selectedAmount = Rx<String>('');

  var isRechagePaneVisible = Rx<bool>(false);

  var selectedPaymentMode = Rx<String>('');

  var paymentMode = Rx<bool>(false);

  var paymentModePane = Rx<bool>(false);

  var isSummaryVisible = Rx<bool>(false);
  @override
  void dispose() {
    disPose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter M-TAG ID',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const Spacer(),
              Text(
                mtagValue.value,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(
                width: 4,
              ),
              const Icon(Icons.keyboard_arrow_down_outlined)
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          if (isTextField.value)
            CustomTExtField(
              textInputAction: TextInputAction.next,
              fillColor: Theme.of(context).primaryColorDark,
              keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
              validator: (p0) {
                if (p0!.isEmpty || p0.length > 8) return 'Enter 8 digit value';
                return null;
              },
              controller: _mtagController,
              onTapOutside: (v) {
                FocusScope.of(context).unfocus();
                Get.find<RechargeController>().isPaymentModdeVisible(false);
                Get.find<RechargeController>().isSummaryVisible(false);
                isRechageVisible(true);
                isRechagePaneVisible(true);
              },
              onEditingComplete: () {
                mtagValue(_mtagController.text);
                Get.find<RechargeController>().setMtagId(_mtagController.text.trim());

                Get.find<RechargeController>().isPaymentModdeVisible(false);
                Get.find<RechargeController>().isSummaryVisible(false);
                isRechageVisible(true);
                isRechagePaneVisible(true);
                isTextField(false);
                FocusScope.of(context).nextFocus();
              },
            ),
          if (isRechagePaneVisible.value)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recharge Amount',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const Spacer(),
                Text(
                  selectedAmount.value,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(
                  width: 4,
                ),
                Icon(isRechageVisible.value ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined)
              ],
            ),
          const SizedBox(
            height: 5,
          ),
          Visibility(
            visible: isRechageVisible.value,
            child: AmountWidget(
              amountChange: (v) {
                selectedAmount(v);
                amountController?.text = v;
                isRechageVisible(false);
                paymentMode(true);
                paymentModePane(true);
              },
              controller: amountController,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (paymentModePane.value)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const Spacer(),
                Text(
                  selectedPaymentMode.value,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(
                  width: 4,
                ),
                const Icon(Icons.keyboard_arrow_down_outlined)
              ],
            ),
          if (paymentMode.value) ...[
            _buildCardWidget(
              context,
              title: 'Debit/Credit Card',
              image: 'assets/creditcard.png',
              amount: '0',
              onTap: () async {
                Analytics.creditDebitTapped();
                _rechargeController.setPayId('0');

                selectedPaymentMode('Debit/Credit Card');
                _rechargeController.getOwnerRechargeDetails(
                    onError: resetWidgetState,
                    amount: selectedAmount.value.toString(),
                    payId: '0',
                    mtagId: mtagValue.value.toString());

                paymentMode(false);
                isSummaryVisible(true);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            _buildCardWidget(
              context,
              title: 'JazzCash Wallet',
              image: 'assets/jazzcash.png',
              amount: '10',
              onTap: () async {
                Analytics.jazzCashTapped();
                _rechargeController.setPayId('1');
                selectedPaymentMode('JazzCash Wallet');
                _rechargeController.getOwnerRechargeDetails(
                    onError: resetWidgetState,
                    amount: selectedAmount.value.toString(),
                    payId: '1',
                    mtagId: mtagValue.value.toString());
                paymentMode(false);
                isSummaryVisible(true);
              },
            ),
          ],
          Visibility(
            visible: _rechargeController.isSummaryVisible.value && isSummaryVisible.value,
            child: RechargeSummary(
              payMentMethod: selectedPaymentMode.value,
            ),
          ),
        ],
      ),
    );
  }

  void resetWidgetState() {
    disPose();
    setState(() {});
  }

  disPose() {
    isRechagePaneVisible(false);
    isSummaryVisible(false);
    isExpanded(false);
    paymentModePane(false);
    isTextField(true);
    mtagValue('');
    amountController?.dispose();
  }

  _buildCardWidget(BuildContext context, {String? image, String? title, String? amount, Callback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Theme.of(context).disabledColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).primaryColor)),
        width: double.infinity,
        child: Row(
          children: [
            Image.asset(
              image ?? '',
              height: 50,
              width: 50,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              title ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Column(
              children: [
                const Text(
                  'Charges',
                  style: TextStyle(color: redAccent),
                ),
                Text(
                  'PKR $amount.0/-',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
