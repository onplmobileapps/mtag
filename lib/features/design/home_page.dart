import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../pages/dashboard/nav_item.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/elevated_button.dart';
import '../../widgets/new_bottom_bar.dart';
import '../../widgets/shimmer_dashboard.dart';
import '../../constants/call_helper.dart';
import '../../pages/dashboard/model/mtag_model.dart';
import '../../pages/mtag/controller/delink_controller.dart';
import '../../pages/recharge/controller/recharge_controller.dart';
import '../../widgets/bottomsheet/balance_transfer_bs.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/dialog/chassis_num.dart';
import '../../widgets/dialog/delink_dialog.dart';
import '../widget/help_section.dart';
import '../widget/slider_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      init: Get.find<HomeController>(),
      builder: (controller) {
        final currentPage =
            navItems
                .firstWhere(
                  (item) => item.index == controller.currentPage.value,
              orElse: () => navItems[0],
            )
                .page ??
                const SizedBox.shrink();

        return Scaffold(
          body: currentPage,

          bottomNavigationBar: SafeArea(
            child: NewBottomBar(
              controller: controller,
              items:navItems ,
              onCenterTap: () {
                CallWhatsappUtil.openWhatsAppChat();
              },
            ),
          ),
        );
      },
    );
  }
}


class HomePageContent extends StatelessWidget {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  HomePageContent({super.key});
  @override
  Widget build(BuildContext context) {
    log('height:${MediaQuery.sizeOf(context).height}');

    double getExpandedHeight(BuildContext context) {
      final screenHeight =
          MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom;

      if (screenHeight <= 740) {
        return screenHeight * 0.55; // small devices → more height
      } else if (screenHeight <= 800) {
        return screenHeight * 0.45; // normal devices
      } else {
        return screenHeight * 0.42; // large devices → less height
      }
    }

    return GetX<HomeController>(
      builder: (controller) {
        final mtags = controller.dashboradData.value.activeMtags;

        if (controller.isLoading.value || mtags == null || mtags.isEmpty) {
          return buildShimmerEffect(double.infinity, context.height);
        }
        return Column(
          children: [
            AppBar(
              clipBehavior: .none,
              centerTitle: true,
              elevation: 0,
              systemOverlayStyle: Get.isDarkMode
                  ? SystemUiOverlayStyle(
                      statusBarBrightness: .dark,
                      statusBarIconBrightness: .light,
                    )
                  : SystemUiOverlayStyle(
                      statusBarBrightness: .light,
                      statusBarIconBrightness: .dark,
                    ),
              backgroundColor: Colors.transparent,
              title: Image.asset(
                Get.isDarkMode ? 'assets/darklogo.png' : 'assets/logolight.png',
                height: 60,
                width: 70,
              ),),
            // ),
            Expanded(
              flex: 1,
              child: CustomScrollView(
                shrinkWrap: true,
                clipBehavior: .antiAlias,
                slivers: [
                  SliverAppBar(
                    toolbarHeight: 60,
                    foregroundColor: Colors.transparent,
                    forceMaterialTransparency: false,
                    clipBehavior: .none,
                    pinned: true,
                    floating: false,
                    forceElevated: false,
                    expandedHeight: getExpandedHeight(context),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.none,
                      background: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: PageView(
                              padEnds: false,
                              clipBehavior: .none,
                              controller: _pageController,
                              scrollDirection: .horizontal,
                              onPageChanged: (value) =>
                                  _currentPage.value = value,
                              children: [
                                for (
                                  int i = 0;
                                  i <
                                      controller
                                          .dashboradData
                                          .value
                                          .activeMtags!
                                          .length;
                                  i++
                                )
                                  VehicleCard(
                                    mtags: controller
                                        .dashboradData
                                        .value
                                        .activeMtags![i],
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          ValueListenableBuilder(
                            valueListenable: _currentPage,
                            builder: (context, value, child) {
                              return Container(
                                color: Colors.transparent, // Solid color
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    for (
                                      int i = 0;
                                      i <
                                          controller
                                              .dashboradData
                                              .value
                                              .activeMtags!
                                              .length;
                                      i++
                                    )
                                      Container(
                                        decoration: BoxDecoration(
                                          color: i == value
                                              ? ColorScheme.of(context).primary
                                              : ColorScheme.of(
                                                  context,
                                                ).surfaceContainerLowest,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(2),
                                        height: 5,
                                        width: i == value ? 15 : 10,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ActionGrid(controller: controller),

                  SliverPadding(
                    sliver: SliderSection(),
                    padding: .symmetric(horizontal: 8),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                  HelpSection(),
                  SliverToBoxAdapter(child: SizedBox(height: 10)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class VehicleCard extends StatelessWidget {
  final ActiveMtags mtags;
  const VehicleCard({super.key, required this.mtags});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        return Container(
          clipBehavior: .none,
          margin: .symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: .circular(16),
            gradient: Theme.of(context).extension<AppGradients>()!.background,
          ),
          child: Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              _MtagDataWidget(width: w, key: key, mtag: mtags),
              Spacer(),
              BalanceCard(mtag: mtags),
            ],
          ),
        );
      },
    );
  }
}

class _MtagDataWidget extends StatelessWidget {
  final double width;
  final ActiveMtags mtag;
  const _MtagDataWidget({super.key, this.width = 0, required this.mtag});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .start,
      crossAxisAlignment: .start,
      children: [
        FittedBox(
          child: Container(
            padding: EdgeInsets.only(top: 16, left: width * 0.03, bottom: 0),

            child: Image.asset(
              getVehicleImage(mtag.vehicletype ?? ''),
              height: width * 0.32,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: .symmetric(horizontal: 10),
            child: Column(
              spacing: 8,
              mainAxisAlignment: .start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: .only(right: 8, top: 8),
                      child: _ActiveBadge(mtag.isactive),
                    ),
                  ],
                ),

                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: mtag.registration ?? '',
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
                          text: ' #${mtag.tokenno ?? ''}',
                          style: TextTheme.of(
                            context,
                          ).bodyMedium?.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                FittedBox(
                  child: Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Chassis No: ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontFamily: 'biotifbold',
                              ),
                            ),
                            // Number
                            if (mtag.isactive != 8 &&
                                (mtag.chassis_number == null ||
                                    mtag.chassis_number == '' ||
                                    mtag.chassis_number!.trim().isEmpty)) ...[
                              TextSpan(
                                text: 'Chassis number is missing',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => ChassisNumberDialog(
                                        chassissNo: mtag.chassis_number ?? '',
                                        registration: mtag.registration ?? '',
                                        tokenNo: mtag.tokenno ?? '',
                                        mobileNumber: mtag.mobilenum ?? '',
                                        balance: mtag.balance ?? '',
                                        cnicNumber:
                                            OtherConsts().ownerCNIC.value,
                                      ),
                                    );
                                  },
                              ),
                            ],
                            TextSpan(
                              text: mtag.chassis_number ?? '',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (mtag.chassis_number?.isNotEmpty ?? false) ...[
                        SizedBox(width: 10),
                        InkWell(
                          onTap: () async => await showDialog(
                            context: context,
                            builder: (_) => ChassisNumberDialog(
                              chassissNo: mtag.chassis_number ?? '',
                              registration: mtag.registration ?? '',
                              tokenNo: mtag.tokenno ?? '',
                              mobileNumber: mtag.mobilenum ?? '',
                              balance: mtag.balance ?? '',
                              cnicNumber: OtherConsts().ownerCNIC.value,
                            ),
                          ),
                          child: Icon(Icons.edit_square, size: 18),
                        ),
                      ],
                    ],
                  ),
                ),

                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1.5,
                  height: 8,
                  indent: 1,
                  endIndent: 10,
                ),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: .start,
                    crossAxisAlignment: .start,
                    children: [
                      Icon(
                        Icons.person_2,
                        color: Colors.green.shade400,
                        size: 20,
                      ),
                      Text('Owner : ', style: TextStyle(color: Colors.grey)),
                      Text(
                        '${mtag.ownername}',
                        style: TextTheme.of(context).bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final double isActive;
  const _ActiveBadge(this.isActive);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive == 1.0 ? Colors.green : Colors.red,
                width: 2.5,
              ),
            ),
          ),
          SizedBox(width: 4),
          FittedBox(
            fit: .scaleDown,
            child: Text(
              'ACTIVE',
              style: TextStyle(
                color: isActive == 1.0
                    ? Colors.green.shade900
                    : isActive == 1.5
                    ? Colors.red
                    : Colors.black,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
                fontFamily: 'biotifbold',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  BalanceCard({super.key, this.mtag, this.balance});
  final ActiveMtags? mtag;
  final double? balance;
  final ValueNotifier<bool> balanceVisibleNotifier = ValueNotifier(true);
  @override
  Widget build(BuildContext context) {
    final balance = double.tryParse('${mtag?.balance}');
    return Container(
      clipBehavior: .none,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: Theme.of(context).extension<AppGradients>()!.verticalFade,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(4, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder(
        valueListenable: balanceVisibleNotifier,
        builder: (context, value, child) {
          return Padding(
            padding: .symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    FittedBox(
                      fit: .scaleDown,
                      child: Text(
                        mtag?.isactive == 8.0
                            ? 'Recovery Amount'
                            : 'Available Balance',
                        style: TextTheme.of(context).titleMedium,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        balanceVisibleNotifier.value =
                            !balanceVisibleNotifier.value;
                      },
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: ColorScheme.of(
                          context,
                        ).surfaceContainerLowest.withValues(alpha: 0.5),
                        child: Icon(
                          value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: Colors.black54,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4), // ← was 6 → tighter
                FittedBox(
                  fit: .scaleDown,
                  child: Text(
                    value ? 'Rs. ${balance ?? ''}' : '****',
                    style: TextTheme.of(
                      context,
                    ).headlineLarge?.copyWith(letterSpacing: 1.2),
                  ),
                ),
                if (mtag?.isactive != 8.0 && balance != null && balance <= 50.0)
                  Row(
                    children: [
                      Text(
                        'Low Balance',
                        style: TextTheme.of(context).titleMedium,
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.warning_rounded,
                        size: 24,
                        color: Colors.yellow.shade800,
                      ),
                    ],
                  ),
                SizedBox(height: 4),

                // ← was 8 → much tighter
                Card(
                  elevation: 1,
                  borderOnForeground: true,
                  shape: RoundedSuperellipseBorder(borderRadius: .circular(50)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: mtag?.isactive != 1.0
                        ? ElevatedButton1(
                            width: double.infinity,
                            backgroundColor: Colors.red.shade900,
                            onclick: () async {
                              showPaymentBottomSheet(
                                context,
                                blackListRecharge: true,
                                mtagId: mtag?.tokenno,
                                regId: mtag?.registration,
                                recoveryAmount: mtag?.block_amount,
                              );
                            },
                            text: 'Pay now',
                          )
                        : _RechargeButton(mtag!),
                  ),
                ),
                SizedBox(height: 5),
                if (mtag?.isactive != 8.0) _TransferRemoveRow(mtag!),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RechargeButton extends StatelessWidget {
  final ActiveMtags activeMtags;
  const _RechargeButton(this.activeMtags);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton1(
      width: double.infinity,
      textStyle: TextTheme.of(context).labelLarge?.copyWith(
        color: Colors.white,
        fontFamily: 'biotifbold',
        fontSize: 18,
        fontWeight: .w600,
      ),
      onclick: () => _showRechargeBottomSheet(activeMtags, context),
      text: 'Recharge M-TAG',
      icon: Icon(Icons.add_circle),
      isShowIcon: true,
      iconAlignment: .start,
    );
  }

  void _showRechargeBottomSheet(ActiveMtags mtag, BuildContext context) {
    showPaymentBottomSheet(
      context,
      mtagId: mtag.tokenno,
      regId: mtag.registration,
      jazzCode: '1',
      creditCode: '0',
      blackListRecharge: false,
    );
  }
}

class _TransferRemoveRow extends StatelessWidget {
  final ActiveMtags mtag;
  const _TransferRemoveRow(this.mtag);

  @override
  Widget build(BuildContext context) {
    final allCars = Get.find<HomeController>().dashboradData.value.activeMtags!
        .where((car) => car.registration != mtag.registration)
        .map(
          (car) => {
            "carNumber": car.registration,
            "balance": double.tryParse(car.balance ?? '0.0') ?? 0.0,
            "mtagID": car.tokenno,
          },
        )
        .toList();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        color: ColorScheme.of(
          context,
        ).surfaceContainerLow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.swap_horiz_rounded,
              label: 'Balance Transfer',
              onTap: () {
                _showBalanceTransferSheet(context, mtag, allCars);
              }, //
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '|',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w100,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          Expanded(
            child: _ActionButton(
              icon: Icons.delete,
              label: 'Remove',
              isDestructive: true,
              onTap: () {
                _showDeleteDialog(mtag);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBalanceTransferSheet(
    BuildContext context,
    ActiveMtags mtag,
    List<Map<String, dynamic>> allCars,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BalanceTransferSheet(
          carRegistration: mtag.registration,
          balance: mtag.balance,
          cnicNumber: OtherConsts().ownerCNIC.value,
          mobileNumber: mtag.mobilenum,
          mtagid: mtag.tokenno,
          dropDownCars: allCars,
        );
      },
    );
  }

  void _showDeleteDialog(ActiveMtags mtag) {
    Get.dialog(
      DeLinkVehicleDialog(
        regId: mtag.registration ?? '',
        onCancel: Get.back,
        onConfirm: () {
          Get.back();
          Get.find<DelinkController>().deLinkVehicle(
            mtagID: mtag.tokenno ?? '',
            rDesc: "0--Vehicle has been sold out.",
            rID: "1",
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextTheme.of(context).bodyMedium?.copyWith(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key, required this.controller});
  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: .symmetric(horizontal: 10),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: MediaQuery.of(context).size.height * 0.09,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: controller.dashBoardModel.length,
          (context, index) {
            final e = controller.dashBoardModel[index];
            return _ActionTile(
              item: e,
              controller: controller,
              isCalculatorWidget: e.title == 'Toll\nCalculator' ? true : false,
            );
          },
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final MtagModel item;
  final bool? isCalculatorWidget;
  final HomeController controller;
  const _ActionTile({
    required this.item,
    this.isCalculatorWidget = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColor = Theme.of(
      context,
    ).extension<AppGradients>()!.gridWidget.colors;
    return GestureDetector(
      onTap: () => handleItemTap(context, item, controller),
      child: Container(
        clipBehavior: .none,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: AlignmentGeometry.xy(-1.1, 0.9),
            end: Alignment(-1.0, 2.0),

            colors: isCalculatorWidget == true && !Get.isDarkMode
                ? [Color(0xFFFFFEF8), Color(0xFFFFF9E5), Color(0xFFFFF2B8)]
                : gradientColor,
          ),
        ),
        child: FittedBox(
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,

                alignment: Alignment.center,
                child: Image.asset(
                  item.image ?? '',
                  width: 38,
                  height: 38,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              FittedBox(
                child: Text(
                  item.title ?? '',
                  style: TextTheme.of(context).displayMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleItemTap(
    BuildContext context,
    MtagModel item,
    HomeController controller,
  ) async {
    final rechargeController = Get.find<RechargeController>();

    if (item.routeName != null) {
      await Get.toNamed(
        item.routeName!,
        arguments: controller.dashboradData.value.activeMtags,
      );
    }
    rechargeController.isPaymentModdeVisible(false);
    rechargeController.isSummaryVisible(false);
    rechargeController.isRechageVisible(true);
  }
}

