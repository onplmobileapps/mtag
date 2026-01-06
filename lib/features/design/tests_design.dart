import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/controller/home_controller.dart';
import 'package:mtag_flutterapp/pages/dashboard/home_page.dart';
import 'package:mtag_flutterapp/pages/dashboard/model/dashboard_model.dart';

import 'package:mtag_flutterapp/widgets/bottom_bar.dart';
import 'package:mtag_flutterapp/widgets/elevated_button.dart';
import 'package:mtag_flutterapp/widgets/shimmer_dashboard.dart';

import '../../constants/call_helper.dart';
import '../../pages/dashboard/model/mtag_model.dart';
import '../../pages/recharge/controller/recharge_controller.dart';
import '../../widgets/dashboard_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX(
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
          floatingActionButtonLocation: .miniCenterDocked,
          floatingActionButton: GestureDetector(
            onTap: () async {
              CallWhatsappUtil.openWhatsAppChat();
            },
            child: Image.asset('assets/whatsapp.png', height: 50, width: 50),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            controller: controller,
            items: navItems,
          ),

          body: currentPage,
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
    return GetX<HomeController>(
      builder: (controller) {
        final mtags = controller.dashboradData.value.activeMtags;

        if (controller.isLoading.value || mtags == null || mtags.isEmpty) {
          return buildShimmerEffect(double.infinity, context.height);
        }
        return Column(
          children: [
            AppBar(
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarBrightness: .light,
                statusBarIconBrightness: .light,
              ),
              backgroundColor: Colors.transparent,
              title: Image.asset('assets/logolight.png', height: 60, width: 70),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: false,
                    expandedHeight: 340,
                    backgroundColor: Colors.transparent, // Set a solid color
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.none,
                      background: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: PageView(
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
                                        .activeMtags?[i],
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          ValueListenableBuilder(
                            valueListenable: _currentPage,
                            builder: (context, value, child) {
                              return Container(
                                color: Colors.white, // Solid color
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
                                              ? Colors.black
                                              : Colors.black26,
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
  final ActiveMtags? mtags;
  const VehicleCard({super.key, this.mtags});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        return Container(
          margin: .symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: .circular(16),
            gradient: const LinearGradient(
              begin: .topLeft,
              end: AlignmentGeometry.centerRight,
              colors: [Color(0xFFE4EDFC), Color(0xFFFCFCFC), Color(0xFFEAEBFD)],
            ),
          ),
          child: Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            children: [
              _MtagDataWidget(width: w, key: key, mtag: mtags),
              Expanded(child: BalanceCard(mtag: mtags)),
            ],
          ),
        );
      },
    );
  }
}

class _MtagDataWidget extends StatelessWidget {
  final double width;
  final ActiveMtags? mtag;
  const _MtagDataWidget({super.key, this.width = 0, this.mtag});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .start,
      crossAxisAlignment: .start,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 16,
            left: width * 0.03,
            bottom: width * 0.025,
          ),

          child: Image.asset('assets/vehicles/car.png', height: width * 0.32),
        ),
        Expanded(
          child: Padding(
            padding: .symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // pushes badge to right
                  children: [
                    Padding(
                      padding: .only(right: 8, top: 8),
                      child: _ActiveBadge(mtag?.isactive == 1.0 ? true : false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: mtag?.registration ?? '',
                          // text: 'LEF-3574', // first part
                          style: TextStyle(
                            fontFamily: 'biotifbold',
                            color: Colors.black, // grey color
                            fontWeight: FontWeight.w600,
                          ),
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
                          text: ' #${mtag?.tokenno ?? ''}', // rest of text
                          style: TextStyle(
                            fontFamily: 'biotifbold',
                            color: Colors.black87, // black color
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
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
                            TextSpan(
                              text: mtag?.chassis_number ?? '',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'biotifbold',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () => showModalBottomSheet(
                          showDragHandle: true,
                          context: context,
                          builder: (_) => Container(),
                        ),
                        child: Icon(Icons.edit_square, size: 18),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1.5,
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
                        '${mtag?.ownername}',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'biotifbold',
                          fontWeight: .w600,
                          fontSize: 16,
                        ),
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
  final bool isActive;
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
                color: isActive ? Colors.green : Colors.red,
                width: 2.5,
              ),
            ),
          ),
          SizedBox(width: 4),
          Text(
            'ACTIVE',
            style: TextStyle(
              color: isActive ? Colors.green.shade900 : Colors.red,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              fontFamily: 'biotifbold',
            ),
          ),
        ],
      ),
    );
  }
}

class BalanceCard extends StatelessWidget {
  BalanceCard({super.key, this.mtag});
  final ActiveMtags? mtag;
  final ValueNotifier<bool> balanceVisibleNotifier = ValueNotifier(true);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          end: AlignmentGeometry.xy(0, 3),
          colors: const [
            Color(0xFFFFFFFF),
            Color(0xFFFCFCFC),
            Color(0xFFF8F6FF),
            Color(0xFFD9E5FF),
            Color(0xFFE6EBFF),
            Color(0xFFE6EBFF),
            Color(0xFFE6EBFF),
            Color(0xFFE6EBFF),
            Color(0xFFE6EBFF),

            // fades out
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(
        24,
        20,
        24,
        8,
      ), // ← slightly reduced bottom padding
      child: ValueListenableBuilder(
        valueListenable: balanceVisibleNotifier,
        builder: (context, value, child) {
          return Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Text(
                    'Available Balance',
                    style: TextStyle(
                      fontFamily: 'biotifbold',
                      fontSize: 16,
                      color: Colors.black54.withValues(alpha: 0.7),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      balanceVisibleNotifier.value =
                          !balanceVisibleNotifier.value;
                    },
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
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
              Text(
                value ? 'Rs. ${mtag?.balance ?? ''}' : '****',

                style: TextStyle(
                  fontFamily: "biotifbold",
                  fontSize: 38,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Low Balance',
                    style: TextStyle(
                      color: Colors.black54,

                      fontSize: 15,
                      fontFamily: 'biotifbold',
                    ),
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
                  child: _RechargeButton(mtag!),
                ),
              ),
              SizedBox(height: 5),
              _TransferRemoveRow(),
            ],
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
      onclick: () =>_showRechargeBottomSheet(activeMtags, context),
      text: 'Recharge M-TAG',
      icon: Icon(Icons.add_circle),
      isShowIcon: true,
      iconAlignment: .start,
    );
  }
  void _showRechargeBottomSheet(ActiveMtags mtag,BuildContext context) {
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
  const _TransferRemoveRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.swap_horiz_rounded,
              label: 'Transfer',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Container(),
                );
              }, //
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Container(),
                );
              },
            ),
          ),
        ],
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
    final color = Colors.black87.withValues(alpha: 0.5);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,

                color: color,
                fontFamily: 'biotifbold',
              ),
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
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: MediaQuery.of(context).size.height * 0.08,
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
    return GestureDetector(
      onTap: () => handleItemTap(context, item, controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: AlignmentGeometry.xy(-1.1, 0.9),
            end: Alignment(-1.0, 2.0),

            colors: (isCalculatorWidget == false)
                ? [Color(0xffFFFCFC), Color(0xffD9EDF8), Color(0xffE4EBF5)]
                : [Color(0xFFFFFEF8), Color(0xFFFFF9E5), Color(0xFFFFF2B8)],
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(1, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(4, 1),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(2, 2),
            ),
          ],
        ),
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
            Expanded(
              child: Text(
                item.title ?? '',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
