import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/features/recharge_center_locator.dart';
import 'package:mtag_flutterapp/pages/settings/setting_screen.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/elevated_button.dart';
import '../../widgets/shimmer_dashboard.dart';
import '../../pages/dashboard/model/mtag_model.dart';
import '../../pages/mtag/controller/delink_controller.dart';
import '../../pages/recharge/controller/recharge_controller.dart';
import '../../widgets/bottomsheet/balance_transfer_bs.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/dialog/chassis_num.dart';
import '../../widgets/dialog/delink_dialog.dart';
import '../../widgets/verified_badge.dart';
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
        return Scaffold(
          body: _navigationPages[controller.currentPage.value],
          bottomNavigationBar: Padding(
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
                padding: EdgeInsets.zero,
                color: ColorScheme.of(context).surface,
                child: _BottomNavItems(),
              ),
            ),
          ),
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
        children: List.generate(_navItems.length, (index) {
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
        fit: BoxFit.scaleDown,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                label,
                style: TextTheme.of(context).displaySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
    double getExpandedHeight(BuildContext context) {
      final screenHeight =
          MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom;

      if (screenHeight <= 740) {
        return screenHeight * 0.55;
      } else if (screenHeight <= 800) {
        return screenHeight * 0.48;
      } else {
        return screenHeight * 0.45;
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
                clipBehavior: Clip.none,
                centerTitle: true,
                elevation: 0,
                systemOverlayStyle: Get.isDarkMode
                    ? const SystemUiOverlayStyle(
                        statusBarBrightness: Brightness.dark,
                        statusBarIconBrightness: Brightness.light,
                      )
                    : const SystemUiOverlayStyle(
                        statusBarBrightness: Brightness.light,
                        statusBarIconBrightness: Brightness.dark,
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
              Expanded(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      toolbarHeight: 0,
                      pinned: true,
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
                              child: PageView.builder(
                                clipBehavior: Clip.none,
                                controller: _pageController,
                                onPageChanged: (value) =>
                                    _currentPage.value = value,
                                itemCount: mtags.length,
                                itemBuilder: (context, i) =>
                                    VehicleCard(mtags: mtags[i]),
                              ),
                            ),
                            const SizedBox(height: 5),
                            ValueListenableBuilder(
                              valueListenable: _currentPage,
                              builder: (context, value, child) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    mtags.length,
                                    (i) => Container(
                                      decoration: BoxDecoration(
                                        color: i == value
                                            ? ColorScheme.of(context).primary
                                            : ColorScheme.of(
                                                context,
                                              ).surfaceContainerLowest,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      margin: const EdgeInsets.all(2),
                                      height: 5,
                                      width: i == value ? 15 : 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ActionGrid(controller: controller),
                    SliverPadding(
                      sliver: SliderSection(),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    HelpSection(),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
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

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              clipBehavior: Clip.none,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: Theme.of(
                  context,
                ).extension<AppGradients>()!.background,
              ),
              child: Column(
                children: [
                  _MtagDataWidget(width: w, mtag: mtags),
                  const Spacer(),
                  BalanceCard(mtag: mtags),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 18,
              child: VerifiedBadge(
                isVerified: mtags.eto_verified ?? false,
                label: (mtags.eto_verified == true ? 'Verified' : 'Unverified')
                    .toUpperCase(),
                tooltipMessage: mtags.eto_verified == true
                    ? 'Verified by Excise & Taxation Office (ETO).'
                    : 'To get verified, enter your correct chassis number.',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MtagDataWidget extends StatelessWidget {
  final double width;
  final ActiveMtags mtag;

  const _MtagDataWidget({required this.width, required this.mtag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final vehicleImagePath = getVehicleImage(mtag.vehicletype ?? '');
    final expiryDate = controller.expiryDate(mtag);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Container(
            padding: EdgeInsets.only(top: 22, left: width * 0.03),
            child: vehicleImagePath.isNotEmpty
                ? Image.asset(vehicleImagePath, height: width * 0.32)
                : SizedBox(height: width * 0.32),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8, top: 8),
                      child: ActiveBadge(mtag),
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
                        const TextSpan(
                          text: ' • M-TAG ',
                          style: TextStyle(
                            fontFamily: 'biotifbold',
                            color: Colors.grey,
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
                if (expiryDate.isNotEmpty)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ColorScheme.of(
                          context,
                        ).surfaceContainerLowest.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            getMtagStatus(mtag) == 'EXPIRED'
                                ? 'M-Tag Expires on : '
                                : 'M-Tag Expires in : ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 10.5,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            expiryDate,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
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
                            if (mtag.chassis_number?.trim().isEmpty ?? true)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () => _showChassisDialog(context),
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
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 11,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Add Chassis Number',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 9,
                                            letterSpacing: 0.5,
                                            fontFamily: '0',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else
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
                        const SizedBox(width: 10),
                        if (mtag.eto_verified != true)
                          InkWell(
                            onTap: () => _showChassisDialog(context),
                            child: const Icon(Icons.edit_square, size: 18),
                          ),
                      ],
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade300, thickness: 1.5, height: 8),
                FittedBox(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_2,
                        color: Colors.green.shade400,
                        size: 20,
                      ),
                      const Text(
                        'Owner : ',
                        style: TextStyle(color: Colors.grey),
                      ),
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

  void _showChassisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ChassisNumberDialog(
        chassissNo: mtag.chassis_number ?? '',
        registration: mtag.registration ?? '',
        tokenNo: mtag.tokenno ?? '',
        mobileNumber: mtag.mobilenum ?? '',
        balance: mtag.balance ?? '',
        cnicNumber: OtherConsts().ownerCNIC.value,
      ),
    );
  }
}

// String getMtagStatus(ActiveMtags activeMtags) {
//   switch (activeMtags.isactive) {
//     case 9:
//       return 'EXPIRED';
//     case 8:
//       return 'BLACKLISTED';
//     case 0:
//       // If active is 0, check blockstatus for 3 or 4
//       log('Blockst${activeMtags.block_status}');
//       if (activeMtags.block_status == 3 || activeMtags.block_status == 4) {
//         return 'BLOCKED';
//       }
//       return 'IN-ACTIVE';
//     case 3:
//     case 4:
//       return 'BLOCKED';
//     case 1:
//     default:
//       return 'ACTIVE';
//   }
// }
String getMtagStatus(ActiveMtags activeMtags) {
  switch (activeMtags.isactive) {
    case 9.0:
      return 'EXPIRED';
    case 8.0:
      return 'BLACKLISTED';
    case 0.0:
      return 'BLOCKED';
    case 1.0:
    default:
      return 'ACTIVE';
  }
}

class ActiveBadge extends StatelessWidget {
  final ActiveMtags mtag;

  const ActiveBadge(this.mtag, {super.key});

  @override
  Widget build(BuildContext context) {
    final label = getMtagStatus(mtag);
    final isTagActive = label == 'ACTIVE';
    final isWarningStatus = label == 'EXPIRED' || label == 'In ACTIVE';

    final Color color = isTagActive
        ? Colors.green
        : (isWarningStatus ? Colors.orange : Colors.red);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.5),
            ),
          ),
          const SizedBox(width: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: isTagActive
                    ? Colors.green.shade900
                    : (isWarningStatus ? Colors.orange.shade900 : Colors.red),
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
  final ActiveMtags? mtag;
  final double? balance;
  final ValueNotifier<bool> balanceVisibleNotifier = ValueNotifier(true);

  BalanceCard({super.key, this.mtag, this.balance});

  @override
  Widget build(BuildContext context) {
    if (mtag == null) return const SizedBox.shrink();

    final statusLabel = getMtagStatus(mtag!);
    final balanceValue = double.tryParse(mtag?.balance ?? '0.0');
    final recoveryAmount = mtag?.block_amount ?? 0.0;

    final bool isRecoveryRequired =
        statusLabel == 'BLACKLISTED' ||
        statusLabel == 'BLOCKED' ||
        statusLabel == 'IN-ACTIVE';
    final bool isBalanceVisible =
        statusLabel == 'ACTIVE' ||
        statusLabel == 'EXPIRED' ||
        mtag?.isactive == 5;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: Theme.of(context).extension<AppGradients>()!.verticalFade,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder(
        valueListenable: balanceVisibleNotifier,
        builder: (context, visible, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isRecoveryRequired
                            ? 'Recovery Amount'
                            : 'Available Balance',
                        style: TextTheme.of(context).titleMedium,
                      ),
                    ),
                    InkWell(
                      onTap: () => balanceVisibleNotifier.value = !visible,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: ColorScheme.of(
                          context,
                        ).surfaceContainerLowest.withValues(alpha: 0.5),
                        child: Icon(
                          visible
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: Colors.black54,
                          size: 17,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    visible
                        ? (isBalanceVisible
                              ? 'Rs. ${balanceValue ?? '0.0'}'
                              : 'Rs. $recoveryAmount')
                        : '****',
                    style: TextTheme.of(context).titleLarge?.copyWith(
                      letterSpacing: 1.2,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isRecoveryRequired ||
                    (balanceValue != null && balanceValue <= 50.0))
                  Row(
                    children: [
                      Text(
                        isRecoveryRequired
                            ? 'Pay Recovery Amount to start using M-TAG'
                            : 'Low Balance',
                        style: isRecoveryRequired
                            ? Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.red.shade900,
                              )
                            : Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).primaryColorLight,
                              ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.warning_rounded,
                        size: 20,
                        color: isRecoveryRequired
                            ? Colors.red.shade900
                            : Colors.yellow.shade800,
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                if (mtag?.isactive != 5)
                  Card(
                    elevation: 1,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: isRecoveryRequired
                          ? ElevatedButton1(
                              width: double.infinity,
                              isEnabled: statusLabel != 'IN-ACTIVE',
                              backgroundColor: Colors.red.shade900,
                              onclick: () => showPaymentBottomSheet(
                                context,
                                blackListRecharge: true,
                                mtagId: mtag?.tokenno,
                                regId: mtag?.registration,
                                recoveryAmount: mtag?.block_amount ?? 0.0,
                              ),
                              text: 'Pay Now',
                            )
                          : _RechargeButton(mtag!),
                    ),
                  ),
                const SizedBox(height: 5),
                if (!isRecoveryRequired) _TransferRemoveRow(mtag!),
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
      onclick: () => showPaymentBottomSheet(
        context,
        mtagId: activeMtags.tokenno,
        regId: activeMtags.registration,
        jazzCode: '1',
        creditCode: '0',
        blackListRecharge: false,
      ),
      text: 'Recharge M-TAG',
      icon: const Icon(Icons.add_circle),
      isShowIcon: true,
      iconAlignment: IconAlignment.start,
    );
  }
}

class _TransferRemoveRow extends StatelessWidget {
  final ActiveMtags mtag;

  const _TransferRemoveRow(this.mtag);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final activeMtags = homeController.dashboradData.value.activeMtags ?? [];
    final bool hasMultipleCars = activeMtags.length > 1;

    final List<Map<String, dynamic>> otherCars = activeMtags
        .where((car) => car.registration != mtag.registration)
        .map(
          (car) => {
            "carNumber": car.registration ?? '',
            "balance": double.tryParse(car.balance ?? '') ?? 0.0,
            "mtagID": car.tokenno ?? '',
          },
        )
        .toList();

    return Container(
      padding: const EdgeInsets.all(2),
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
                onTap: () => _showBalanceTransferSheet(context, otherCars),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('|', style: TextStyle(color: Colors.grey)),
            ),
          ],
          Expanded(
            child: ActionButton(
              icon: Icons.delete_outlined,
              label: 'Delete Vehicle',
              onTap: () => _showDeleteDialog(),
            ),
          ),
        ],
      ),
    );
  }

  void _showBalanceTransferSheet(
    BuildContext context,
    List<Map<String, dynamic>> otherCars,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BalanceTransferSheet(
        carRegistration: mtag.registration ?? '',
        balance: mtag.balance ?? '0',
        cnicNumber: OtherConsts().ownerCNIC.value,
        mobileNumber: mtag.mobilenum ?? '',
        mtagid: mtag.tokenno ?? '',
        dropDownCars: otherCars,
      ),
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      DeLinkVehicleDialog(
        regId: mtag.registration ?? '',
        onCancel: () => Get.back(),
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

class ActionButton extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final VoidCallback? onTap;

  const ActionButton({
    super.key,
    this.icon,
    this.imagePath,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 25,
                height: 25,
                color: Get.isDarkMode ? Colors.white : null,
              )
            else if (icon != null)
              Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextTheme.of(context).displayMedium?.copyWith(
                fontSize: 9.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionGrid extends StatelessWidget {
  final HomeController controller;

  const ActionGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
            final item = controller.dashBoardModel[index];
            return _ActionTile(item: item, controller: controller);
          },
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final MtagModel item;
  final HomeController controller;

  const _ActionTile({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isCalc = item.title == 'Toll Calculator';
    final gradientColor = Theme.of(
      context,
    ).extension<AppGradients>()!.gridWidget.colors;

    return GestureDetector(
      onTap: () {
        if (item.routeName != null) {
          Get.toNamed(
            item.routeName!,
            arguments: controller.dashboradData.value.activeMtags,
          );
        }
        final rc = Get.find<RechargeController>();
        rc.isPaymentModdeVisible(false);
        rc.isSummaryVisible(false);
        rc.isRechageVisible(true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: const Alignment(-1.1, 0.9),
            end: const Alignment(-1.0, 2.2),
            colors: isCalc && !Get.isDarkMode
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
            children: [
              if (item.image != null)
                Image.asset(item.image!, width: 30, height: 30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  spacing: 3,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? '',
                      style: TextTheme.of(context).displayMedium,
                    ),
                    Text(
                      item.subtitle ?? '',
                      style: TextTheme.of(
                        context,
                      ).bodySmall?.copyWith(fontSize: 7),
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
}
