import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:mtag_flutterapp/widgets/gradient_appbar.dart';
import '../../controller/home_controller.dart';
import '../../pages/recharge/shared/card_shared_ui.dart';
import '../../remoteconfig/firebase_remote_config.dart';
import '../../utils/utils.dart';
import '../../widgets/amount_chipselector.dart';
import '../../widgets/bottomsheet/build_payment_options_widget.dart';
import '../../widgets/dialog/cupertino_dialog.dart';
import '../../api/api_constants.dart';
import '../../pages/payment/controller/payment_card_controller.dart';
import '../../pages/payment/model/payment_card_model.dart';
import '../../widgets/mtag_card_widget.dart';
import '../../widgets/textform_widget.dart';
import '../dashboard/model/dashboard_model.dart';

ValueNotifier<int> selected1linkOpt = ValueNotifier<int>(-1);
ValueNotifier<bool> showPSIDField = ValueNotifier(false);

class RechargeSelfPage extends StatelessWidget {
  const RechargeSelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RechargeSelfController>(
      init: RechargeSelfController(
        paymentController: Get.find(),
        homeController: Get.find(),
      ),
      builder: (controller) => PopScope(
        canPop: true,
        onPopInvokedWithResult: controller.handlePop,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: GradientAppBar(title: Text('Recharge M-Tag')),
          // appBar: AppBar(title: const Text('Recharge M-Tag')),
          body: _buildBody(context, controller),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, RechargeSelfController controller) {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Theme.of(context).primaryColor,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          // borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildContent(context, controller),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    RechargeSelfController controller,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      controller: controller.scrollController1,
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMtagSection(context, controller),
            _buildAmountSection(context, controller),
            _buildPaymentSection(context, controller),
            SafeArea(child: _buildCardSection(context, controller)),
          ],
        ),
      ),
    );
  }
}

class RechargeSelfController extends GetxController {
  // Dependencies
  final PaymentCardController paymentController;
  final HomeController homeController;

  RechargeSelfController({
    required this.paymentController,
    required this.homeController,
  });

  final scrollController = ScrollController(),
      scrollController1 = ScrollController(),
      scrollController2 = ScrollController(),
      scrollController3 = ScrollController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final amountController = TextEditingController(),
      jazzCashController = TextEditingController(),
      otherMtagController = TextEditingController();
  final RxList<ActiveMtags> arguments =
      (Get.arguments is List<ActiveMtags>
              ? Get.arguments as List<ActiveMtags>
              : Get.arguments is ActiveMtags
              ? [Get.arguments as ActiveMtags]
              : [ActiveMtags()])
          .obs;
  final RxInt selectedMtagIndex = (-1).obs;
  final RxString selectedMtag = ''.obs;
  final RxInt selectedPayment = (-1).obs;
  final RxBool isLoading = false.obs;
  final RxBool isOtherMtagFieldVisible = false.obs;
  final Rx<PaymentCardModel> paymentCardModel = PaymentCardModel().obs;
  final RxBool showPsidField = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  void _initialize() {
    _setupInitialValues();
    FirebaseRemoteConfigService().fetchRemoteConfig();
  }

  void _setupInitialValues() {
    isJazzShown.value = false;
    isCardsVisible.value = false;

    if (arguments.isNotEmpty) {
      selectedMtagIndex.value = arguments.length == 1 ? 0 : -1;

      selectedMtag.value = arguments.length == 1
          ? arguments.first.tokenno ?? ''
          : '';
      amountController.text = arguments.first.amount ?? '';

      _handleInitialPayment();
    }
  }

  void _handleInitialPayment() {
    if (arguments.first.payId != null) {
      fetchPaymentCards(arguments.first.payId!);
      if (arguments.first.payId == '1') {
        isCardsVisible.value = true;
        setPayment(2);
      } else if (arguments.first.payId == '0') {
        isCardsVisible.value = true;
        setPayment(1);
      }
    }
  }

  void _disposeControllers() {
    amountController.dispose();
    jazzCashController.dispose();
    otherMtagController.dispose();
    scrollController.dispose();
    scrollController1.dispose();
    scrollController2.dispose();
    scrollController3.dispose();
  }

  void handlePop(bool didPop, dynamic result) {
    if (!didPop) {
      selected1linkOpt.value = -1;
      log('pop invoked:$didPop ${selected1linkOpt.value}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.back();
      });
    }
  }

  void scrollLeft() => _scroll(scrollController, -100);

  void scrollRight() => _scroll(scrollController, 100);

  void _scroll(ScrollController controller, double offset) {
    controller.animateTo(
      controller.offset + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onMTagTap(int index, String value, bool isOtherMtag) {
    selectedMtagIndex.value = index;
    selectedMtag.value = value;
    isOtherMtagFieldVisible.value = isOtherMtag;
    if (!isOtherMtag) otherMtagController.clear();
  }

  void setPayment(int index) => selectedPayment.value = index;

  Future<void> fetchPaymentCards(String payId) async {
    try {
      isLoading.value = true;
      paymentCardModel.value.cardsData?.clear();
      final response = await paymentController.getCardDetails(payId);
      if (response.containsKey(APIRESPONSE.SUCCESS)) {
        paymentCardModel.value = PaymentCardModel.fromJson(
          response[APIRESPONSE.SUCCESS],
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  String maskString(String value) {
    if (value.isEmpty) return '';
    if (value.length == 11 || value.length == 19) {
      return value.substring(value.length - 4);
    }
    return '';
  }
}

// Widget Builders
Widget _buildMtagSection(
  BuildContext context,
  RechargeSelfController controller,
) {
  return Obx(
    () => Container(
      margin: .symmetric(vertical: 8),
      padding: .symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<AppGradients>()!.background,
        borderRadius: .circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Select M-tag/Vehicle'),
          Row(
            children: [
              if (controller.arguments.length > 2)
                _buildScrollButton(
                  Icons.keyboard_arrow_left,
                  controller.scrollLeft,
                ),
              Expanded(child: _buildMtagList(context, controller)),
              if (controller.arguments.length > 2)
                _buildScrollButton(
                  Icons.keyboard_arrow_right_outlined,
                  controller.scrollRight,
                ),
            ],
          ),
          if (controller.isOtherMtagFieldVisible.value)
            _buildOtherMtagField(context, controller),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

Widget _buildSectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 10, bottom: 10),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: .w600),
    ),
  );
}

Widget _buildScrollButton(IconData icon, VoidCallback onTap) {
  return InkWell(onTap: onTap, child: Icon(icon));
}

Widget _buildMtagList(BuildContext context, RechargeSelfController controller) {
  return SingleChildScrollView(
    controller: controller.scrollController,
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        ...controller.arguments.map(
          (item) => MTagCard(
            index: controller.arguments.indexOf(item),
            token: item.tokenno ?? '',
            registration: item.registration ?? '',
            isSelected:
                controller.selectedMtagIndex.value ==
                controller.arguments.indexOf(item),
            onTap: () => item.isactive == 8
                ? showPopDialog(
                    "You have pending dues on your account. You are not allowed to enter the motorway until your dues are cleared.",
                    () => Get.back(),
                  )
                : controller.onMTagTap(
                    controller.arguments.indexOf(item),
                    item.tokenno ?? '',
                    false,
                  ),
            isActive: item.isactive ?? 1,
          ),
        ),
        MTagCard(
          index: controller.arguments.length,
          token: 'Other M-TAG',
          registration: 'Recharge',
          isSelected:
              controller.selectedMtagIndex.value == controller.arguments.length,
          onTap: () =>
              controller.onMTagTap(controller.arguments.length, '', true),

          isActive: 1,
        ),
      ],
    ),
  );
}

Widget _buildOtherMtagField(
  BuildContext context,
  RechargeSelfController controller,
) {
  return CustomTextField(
    controller: controller.otherMtagController,
    hint: "Enter M-Tag Id",
    hintStyle: const TextStyle(color: Colors.grey),
    textInputAction: TextInputAction.done,
    keyboardType: const TextInputType.numberWithOptions(signed: true),
    maxLength: 8,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: validateMtag,
    onChanged: (value) => controller.selectedMtag.value = value.trim(),
  );
}

Widget _buildAmountSection(
  BuildContext context,
  RechargeSelfController controller,
) {
  return Obx(
    () => !controller.showPsidField.value
        ? Container(
            padding: .symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: Theme.of(context).extension<AppGradients>()!.background,
              borderRadius: .circular(8),
            ),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  crossAxisAlignment: .center,
                  children: [
                    _buildSectionTitle(context, 'Enter Amount'),
                    Text(
                      'Min: Rs. ${controller.homeController.dashboradData.value.rechargeMinAmount} '
                      'Max: Rs. ${controller.homeController.dashboradData.value.rechargeMaxAmount}',
                      style: const TextStyle(fontSize: 7, color: Colors.black),
                    ),
                  ],
                ),
                CustomTextField(
                  controller: controller.amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: validateAmount,
                  maxLength: 8,
                  hint: '50',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AmountChipSelector(
                    amounts: AmountList.amountList,
                    controller: controller.amountController,
                  ),
                ),
              ],
            ),
          )
        : const SizedBox.shrink(),
  );
}

Widget _buildPaymentSection(
  BuildContext context,
  RechargeSelfController controller,
) {
  return Obx(
    () => Container(
      margin: .symmetric(vertical: 8),
      padding: .symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<AppGradients>()!.background,
        borderRadius: .circular(8),
      ),
      child: BuildPaymentOptionsWidget(
        onChanged: (paymentMethod) =>
            controller.handlePaymentSelection(paymentMethod),
        amount: controller.amountController,
        showPSIDField: showPSIDField,
        psidController: TextEditingController(),
        creditCode: '',
        jazzCode: '',
        mtagId: controller.selectedMtag.value,
        blackListRecharge: false,
      ),
    ),
  );
}

Widget _buildCardSection(
  BuildContext context,
  RechargeSelfController controller,
) {
  return Obx(
    () => CardSharedUi(
      cardListData: controller.paymentCardModel.value.cnt == 0
          ? []
          : controller.paymentCardModel.value.cardsData ?? [],
      loading: controller.isLoading.value,
      payId: controller.selectedPayment.value,
      paymentHead: controller.selectedPayment.value == 2
          ? 'JazzCash'
          : controller.selectedPayment.value == 1
          ? 'Credit/Debit Card'
          : '',
      mtagId: controller.selectedMtag.value,
      amount: controller.amountController.text,
    ),
  );
}

extension RechargeSelfControllerExtensions on RechargeSelfController {
  void handlePaymentSelection(int paymentMethod) {
    if (!isMtagValid()) {
      showPopDialog('Select M-Tag / Enter M-Tag', () {
        selected1linkOpt.value = -1;
        Get.back();
      });
      return;
    }

    setPayment(
      paymentMethod,
    ); // Use paymentMethod directly (1 for Credit/Debit, 2 for JazzCash)
    fetchPaymentCards(paymentMethod.toString());
    isCardsVisible.value =
        paymentMethod == 1 || paymentMethod == 2; // Show cards for 1 or 2
    if (isCardsVisible.value) isJazzShown.value = false;

    setPayment(paymentMethod == 1 ? 2 : 1);
    fetchPaymentCards(paymentMethod.toString());
    isCardsVisible.value = paymentMethod <= 1;
    if (isCardsVisible.value) isJazzShown.value = false;
  }

  bool isMtagValid() =>
      selectedMtag.value.isNotEmpty && selectedMtag.value.length >= 8;
}
