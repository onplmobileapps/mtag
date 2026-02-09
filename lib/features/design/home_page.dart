import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/features/recharge_center_locator.dart';
import 'package:mtag_flutterapp/pages/settings/setting_screen.dart';
import 'package:mtag_flutterapp/widgets/whatsapp_widget.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/elevated_button.dart';
import '../../widgets/notched_border_painter.dart';
import '../../widgets/shimmer_dashboard.dart';
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
  HomePage({super.key});

  final List<Widget> _navigationPages = [
    HomePageContent(),
    HomePageContent(),
    RechargeMapScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      init: Get.find<HomeController>(),
      builder: (controller) {
        const SizedBox.shrink();
        return Scaffold(
          body: _navigationPages[controller.currentPage.value],
          bottomNavigationBar: CustomPaint(
            painter: NotchedBorderPainter(
              borderColor: ColorScheme.of(context).outline,
              strokeWidth: 1.5,
              notchMargin: 7,
              notchColor: ColorScheme.of(
                context,
              ).outline.withValues(alpha: 0.7),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: BottomAppBar(
                  height: 55,
                  clipBehavior: Clip.hardEdge,
                  elevation: 4,
                  notchMargin: 1.0,
                  padding: .zero,
                  color: ColorScheme.of(context).surface,
                  shape: const CircularNotchedRectangle(),
                  child: _BottomNavItems(),
                ),
              ),
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorScheme.of(context).surface,
                border: .all(
                  color: ColorScheme.of(context).outline,
                  width: 1.5,
                ),
              ),
              child: WhatsAppButton(),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }
}

class _BottomNavItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final currentIndex = controller.currentPage.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (index) {
          return _NavItem(
            index: index,
            currentIndex: currentIndex,
            icon: _navItems[index]['icon']!,
            label: _navItems[index]['label']!,
            onTap: () => controller.setCurrentIndex(index),
          );
        }),
      );
    });
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String icon;
  final VoidCallback onTap;
  final String label;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      borderRadius: BorderRadius.circular(16),
      child: FittedBox(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            children: [
              if (icon.isNotEmpty)
                SvgPicture.asset(
                  icon,
                  height: 25,
                  colorFilter: ColorFilter.mode(
                    isActive ? ColorScheme.of(context).primary : Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
              Text(label, style: TextTheme.of(context).displaySmall),
            ],
          ),
        ),
      ),
    );
  }
}

final _navItems = [
  {'icon': 'assets/home_new.svg', 'label': 'Home'},
  {'icon': 'assets/weather.svg', 'label': 'Weather Updates'},
  {'icon': 'assets/location.svg', 'label': 'Recharge Locations'},
  {'icon': 'assets/setting.svg', 'label': 'Settings'},
];

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
        return RefreshIndicator(
          onRefresh: () async {
            controller.isLoading.value = true;
            try {
              await controller.refreshDashboardData();
            } finally {
              controller.isLoading.value = false;
            }
          },
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          displacement: 40,
          strokeWidth: 2.8,
          triggerMode: RefreshIndicatorTriggerMode.onEdge,
          child: Column(
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
                  Get.isDarkMode
                      ? 'assets/darklogo.png'
                      : 'assets/logolight.png',
                  height: 60,
                  width: 70,
                ),
              ),
              // ),
              Expanded(
                flex: 1,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  clipBehavior: .antiAlias,
                  slivers: [
                    SliverAppBar(
                      toolbarHeight: 0,
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
                                                ? ColorScheme.of(
                                                    context,
                                                  ).primary
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
          ),
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
    final vehicleImagePath = getVehicleImage(mtag.vehicletype ?? '');
    return Row(
      mainAxisAlignment: .start,
      crossAxisAlignment: .start,
      children: [
        FittedBox(
          child: Container(
            padding: EdgeInsets.only(top: 16, left: width * 0.03, bottom: 0),

            child: vehicleImagePath.isNotEmpty
                ? Image.asset(vehicleImagePath, height: width * 0.32)
                : SizedBox(height: width * 0.32),
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
                  mainAxisAlignment: .end,
                  children: [
                    Padding(
                      padding: .only(right: 8, top: 8),
                      child: ActiveBadge(mtag.isactive),
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
                            if (mtag.chassis_number == null ||
                                mtag.chassis_number == '' ||
                                mtag.chassis_number!.trim().isEmpty) ...[
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () async {
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
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.red.withValues(
                                          alpha: 0.4,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.add_circle_outline,
                                          size: 11,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Add Chassis Number',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 9,
                                            letterSpacing: 0.5,
                                            fontFamily: 'biotifbold',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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

class ActiveBadge extends StatelessWidget {
  final double isActive;

  const ActiveBadge(this.isActive, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isActive == 1.0
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.red.withValues(alpha: 0.15),
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
              isActive == 1.0 ? 'ACTIVE' : "BLACKLISTED",
              style: TextStyle(
                color: isActive == 1.0
                    ? Colors.green.shade900
                    : isActive == 8.0
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
    final recoveryAmount = double.tryParse('${mtag?.block_amount}');

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
                    value
                        ? mtag?.isactive == 1.0
                              ? 'Rs. ${balance ?? ''}'
                              : 'Rs. ${recoveryAmount ?? ''}'
                        : '****',
                    style: TextTheme.of(context).titleLarge?.copyWith(
                      letterSpacing: 1.2,
                      fontSize: 24,
                      fontWeight: .bold,
                    ),
                  ),
                ),
                if (balance != null && balance <= 50.0)
                  Row(
                    children: [
                      Text(
                        mtag?.isactive == 8.0
                            ? 'Pay Recovery Amount to start using M-TAG'
                            : 'Low Balance',
                        style: mtag?.isactive == 8.0
                            ? Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade900,
                              )
                            : Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.warning_rounded,
                        size: 20,
                        color: mtag?.isactive == 8.0
                            ? Colors.red.shade900
                            : Colors.yellow.shade800,
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
                            // backgroundColor: Colors.red.shade900,
                            onclick: () async {
                              showPaymentBottomSheet(
                                context,
                                blackListRecharge: true,
                                mtagId: mtag?.tokenno,
                                regId: mtag?.registration,
                                recoveryAmount: mtag?.block_amount,
                              );
                            },
                            text: 'Pay Now',
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
        fontWeight: FontWeight.w600,
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
    final homeController = Get.find<HomeController>();

    final activeMtags =
        homeController.dashboradData.value.activeMtags ?? const [];

    final bool hasMultipleCars = activeMtags.length > 1;

    final List<Map<String, dynamic>> allCars = activeMtags
        .where(
          (car) =>
              car.registration != null && car.registration != mtag.registration,
        )
        .map(
          (car) => {
            "carNumber": car.registration ?? '',
            "balance": double.tryParse(car.balance ?? '') ?? 0.0,
            "mtagID": car.tokenno ?? '',
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
        children: [
          if (hasMultipleCars) ...[
            Expanded(
              child: ActionButton(
                imagePath: "assets/transfer_balance.png",
                label: 'Balance Transfer',
                isDestructive: false,
                onTap: () {
                  if (allCars.isEmpty) return;
                  _showBalanceTransferSheet(context, mtag, allCars);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '|',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  color: Colors.grey,
                ),
              ),
            ),
          ],

          Expanded(
            child: ActionButton(
              icon: Icons.delete_outlined,
              label: 'Delete Vehicle',
              isDestructive: false,
              onTap: () => _showDeleteDialog(mtag),
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
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BalanceTransferSheet(
          carRegistration: mtag.registration ?? '',
          balance: mtag.balance ?? '0',
          cnicNumber: OtherConsts().ownerCNIC.value,
          mobileNumber: mtag.mobilenum ?? '',
          mtagid: mtag.tokenno ?? '',
          dropDownCars: allCars,
        );
      },
    );
  }

  void _showDeleteDialog(ActiveMtags mtag) {
    if (mtag.tokenno == null || mtag.tokenno!.isEmpty) return;

    Get.dialog(
      DeLinkVehicleDialog(
        regId: mtag.registration ?? '',
        onCancel: () {
          if (Get.isDialogOpen ?? false) Get.back();
        },
        onConfirm: () {
          if (Get.isDialogOpen ?? false) Get.back();

          final controller = Get.find<DelinkController>();

          controller.deLinkVehicle(
            mtagID: mtag.tokenno ?? '',
            rDesc: "0--Vehicle has been sold out.",
            rID: "1",
          );
        },
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  const ActionButton({
    super.key,
    this.icon,
    this.imagePath,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextTheme.of(context).displayMedium?.copyWith(
      fontSize: 9.4,
      fontWeight: FontWeight.bold,
      color: isDestructive ? Colors.red : null,
    );

    Widget? leadingWidget;
    if (imagePath != null && imagePath!.isNotEmpty) {
      leadingWidget = Image.asset(
        imagePath!,
        width: 25,
        height: 25,
        fit: BoxFit.contain,
        color: Get.isDarkMode ? Colors.white : null,
      );
    } else if (icon != null) {
      leadingWidget = Icon(
        icon,
        size: 20,
        color: isDestructive ? Colors.red : null,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingWidget != null) ...[
              leadingWidget,
              const SizedBox(width: 8),
            ],
            Text(label, style: textStyle),
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
          maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.6,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: MediaQuery.of(context).size.height * 0.07,
        ),
        delegate: SliverChildBuilderDelegate(
          childCount: controller.dashBoardModel.length,
          (context, index) {
            final e = controller.dashBoardModel[index];
            return _ActionTile(
              item: e,
              controller: controller,
              isCalculatorWidget: e.title == 'Toll Calculator' ? true : false,
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
    final imagePath = item.image ?? '';

    return GestureDetector(
      onTap: () => handleItemTap(context, item, controller),
      child: Container(
        padding: .symmetric(horizontal: 16),
        clipBehavior: .none,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: AlignmentGeometry.xy(-1.1, 0.9),
            end: Alignment(-1.0, 2.2),
            colors: isCalculatorWidget == true && !Get.isDarkMode
                ? const [
                    Color(0xFFFFFDF5),
                    Color(0xFFFFF3CC),
                    Color(0xFFFFF3CC),
                    Color(0xFFFFE7A0),
                  ]
                : gradientColor,
          ),
          boxShadow: Theme.of(context).extension<AppShadows>()!.gridShadow,
        ),

        child: FittedBox(
          child: Row(
            mainAxisAlignment: .start,
            crossAxisAlignment: .center,
            children: [
              if (imagePath.isNotEmpty)
                Image.asset(
                  imagePath,
                  width: 30,
                  height: 30,
                  fit: BoxFit.contain,
                ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  spacing: 3,
                  mainAxisAlignment: .start,
                  crossAxisAlignment: .start,
                  children: [
                    FittedBox(
                      child: Text(
                        item.title ?? '',
                        style: TextTheme.of(context).displayMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    FittedBox(
                      child: Text(
                        item.subtitle ?? '',
                        style: TextTheme.of(
                          context,
                        ).bodySmall?.copyWith(fontSize: 7),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
