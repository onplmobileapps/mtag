import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/call_helper.dart';
import 'package:mtag_flutterapp/features/promotion_page.dart';
import 'package:mtag_flutterapp/features/story_view_page.dart';
import 'package:mtag_flutterapp/pages/notification/notification_screen.dart';
import 'package:mtag_flutterapp/widgets/mtag_recovery_widget.dart';
import '../../api/user_repo.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../features/recharge_center_locator.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/shimmer_dashboard.dart';
import '../recharge/controller/recharge_controller.dart';
import '../recharge/recharge_page.dart';
import '../settings/setting_screen.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  final bottomNavigations = <Widget>[
    Container(),
    PromotionPage(),
    NotificationScreen(),
    SettingScreen(),
  ];
  final _otherConstants = OtherConsts();

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      init: HomeController(userRepo: UserRepo()),
      builder: (controller) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: _buildScaffold(context, controller),
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, HomeController controller) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButtonAnimator: .scaling,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      resizeToAvoidBottomInset: false,
      extendBody: false,
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RechargeMapScreen()),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00296B), Color(0xFF8A2E87)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset('assets/location.svg', height: 30),
          ),
        ),
      ),
      body: controller.currentPage.value == 0
          ? controller.isLoading.value
                ? buildShimmerEffect(screenWidth, screenHeight)
                : NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverAppBar(
                          pinned: true,
                          backgroundColor: Colors.transparent,
                          elevation: 2,
                          expandedHeight: screenHeight * 0.52,
                          flexibleSpace: LayoutBuilder(
                            builder: (context, constraints) {
                              final top = constraints.biggest.height;
                              final isCollapsed = top <= kToolbarHeight;

                              return FlexibleSpaceBar(
                                titlePadding: .zero,
                                background: Obx(() {
                                  final activeMtags =
                                      controller
                                          .dashboradData
                                          .value
                                          .activeMtags ??
                                      [];
                                  if (activeMtags.isEmpty) return SizedBox();
                                  if (!isCollapsed) {
                                    return ListView.builder(
                                      padding: .zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: activeMtags.length,
                                      itemBuilder: (context, index) {
                                        final index =
                                            controller.selectedMtagIndex.value;
                                        final e = activeMtags[index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 0,
                                          ),
                                          child: Obx(() {
                                            return e.isactive == 8
                                                ? mtagRecoveryWidget(
                                                    context,
                                                    size: MediaQuery.sizeOf(
                                                      context,
                                                    ),
                                                    height: screenHeight * 0.60,
                                                    isBlock: e.isactive,
                                                    mtagId: e.tokenno,
                                                    mobileNum: _otherConstants
                                                        .mobile
                                                        .string,
                                                    cnic: _otherConstants
                                                        .ownerCNIC
                                                        .string,
                                                    regId: e.registration,
                                                    blockAmount: e.block_amount,
                                                  )
                                                : mtagDataWidget(
                                                    context,
                                                    onTapBack: () {
                                                      controller.goBack();
                                                    },
                                                    onTapForward: () {
                                                      controller.goNext(
                                                        activeMtags.length,
                                                      );
                                                    },
                                                    isBlock: e.isactive,
                                                    jazzCode: controller
                                                        .dashboradData
                                                        .value
                                                        .jazzCashRecharge
                                                        .toString(),
                                                    creditCode: controller
                                                        .dashboradData
                                                        .value
                                                        .creditCardRecharge
                                                        .toString(),
                                                    vehType: e.vehicletype,
                                                    mtagId: e.tokenno,
                                                    userName: e.ownername,
                                                    mobileNum: _otherConstants
                                                        .mobile
                                                        .string,
                                                    cnic: _otherConstants
                                                        .ownerCNIC
                                                        .string,
                                                    regId: e.registration,
                                                    ball: e.balance,
                                                    showTransferButton:
                                                        activeMtags.length == 1
                                                        ? false
                                                        : true,
                                                    balanceDashboard: e.balance,
                                                    showChassisBadge:
                                                        e.chassis_number ==
                                                        null,
                                                    chassisNumber:
                                                        e.chassis_number,
                                                  );
                                          }),
                                        );
                                      },
                                    );
                                  }
                                  return SizedBox.shrink();
                                }),
                              );
                            },
                          ),
                        ),
                      ];
                    },
                    body: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(8.0),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: screenWidth * 0.5,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  mainAxisExtent: screenHeight * 0.11,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return InkWell(
                                onTap: () async {
                                  final rechctrl =
                                      Get.find<RechargeController>();
                                  selected1linkOpt.value = -1;
                                  await Get.toNamed(
                                    '${controller.dashBoardModel[index].routeName}',
                                    arguments: controller
                                        .dashboradData
                                        .value
                                        .activeMtags,
                                  );
                                  selected1linkOpt.value = -1;
                                  rechctrl.isPaymentModdeVisible(false);
                                  rechctrl.isSummaryVisible(false);
                                  rechctrl.isRechageVisible(true);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: .circular(8),
                                    color: Theme.of(context).disabledColor,
                                  ),
                                  child: Row(
                                    spacing: 8,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      if (controller
                                              .dashBoardModel[index]
                                              .image !=
                                          null)
                                        Padding(
                                          padding: .all(8.0),
                                          child: Image.asset(
                                            controller
                                                .dashBoardModel[index]
                                                .image!,
                                            width: screenWidth * 0.1,
                                            height: screenHeight * 0.1,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      Text(
                                        controller
                                                .dashBoardModel[index]
                                                .title ??
                                            '',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextTheme.of(context).bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }, childCount: controller.dashBoardModel.length),
                          ),
                        ),
                        // Slider Section
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Tap to see what’s new',
                              style: TextTheme.of(context).bodyMedium,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              height: 150,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: OtherConsts.sliderImages.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final imageName =
                                      OtherConsts.sliderImages[index];
                                  final imageUrl = 'assets/slider/$imageName';

                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StoryViewPage(
                                          stories: OtherConsts.sliderImages,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: .circular(8),
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).highlightColor,
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(imageUrl),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        // Help & Customer Support
                        SliverToBoxAdapter(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ColorScheme.of(context).surfaceDim,
                              border: Border.all(
                                width: 0.1,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: .start,
                              crossAxisAlignment: .center,
                              children: [
                                SvgPicture.asset(
                                  'assets/phone.svg',
                                  width: 50,
                                  height: 50,
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Help & Customer Support',
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayLarge
                                            ?.copyWith(fontWeight: .w900),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Call our helpline 1313 to get quick help on queries related to your M-Tag',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.displayMedium,
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          CallWhatsappUtil.openCall1313();
                                        },
                                        icon: const Icon(
                                          Icons.arrow_forward,
                                          size: 14,
                                          color: Colors.redAccent,
                                        ),
                                        label: const Text(
                                          '1313',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12,
                                          ),
                                        ),
                                        iconAlignment: .end,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          minimumSize: const Size(70, 28),
                                          maximumSize: const Size(70, 28),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          side: const BorderSide(
                                            color: Colors.redAccent,
                                          ),
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
                    ),
                  )
          //RefreshIndicator.adaptive(
          // displacement: 60,
          // onRefresh: () async {
          //   await Get.find<HomeController>().pullRefreshDashboardData();
          // },
          : bottomNavigations[controller.currentPage.value],
      bottomNavigationBar: BottomAppBar(
        height: 50,
        padding: .only(top: 8),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6, // <--- Gives the glowing/hue space around FAB
        elevation: 10,
        color: Colors.grey.withValues(alpha: 0.1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buildCustomNavItem(
              context: context,
              index: 0,
              currentIndex: controller.currentPage.value,
              label: 'Home',
              asset: 'assets/house-blank.svg',
              onTap: () {
                (0 == 0 && _otherConstants.isRefresh.value)
                    ? controller.pullRefreshDashboardData()
                    : null;
                controller.setCurrentIndex(0);
              },
            ),
            buildCustomNavItem(
              context: context,
              index: 1,
              currentIndex: controller.currentPage.value,
              label: 'Promotions',
              asset: 'assets/promotion.svg',
              onTap: () => controller.setCurrentIndex(1),
            ),

            // gap for center FAB notch
            buildCustomNavItem(
              context: context,
              index: 2,
              currentIndex: controller.currentPage.value,
              label: 'Notifications',
              asset: 'assets/allert.svg',
              onTap: () => controller.setCurrentIndex(2),
            ),
            buildCustomNavItem(
              context: context,
              index: 3,
              currentIndex: controller.currentPage.value,
              label: 'Profile',
              asset: 'assets/user.svg',
              onTap: () => controller.setCurrentIndex(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCustomNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String label,
    required String asset,
    required Function() onTap,
  }) {
    final isSelected = index == currentIndex;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = isSelected
        ? colorScheme.primary
        : colorScheme.secondary.withValues(alpha: 0.7);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            asset,
            height: 22,
            colorFilter: ColorFilter.mode(
              iconColor,
              BlendMode.srcIn,
            ), // unselected color from theme
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.secondary.withValues(
                      alpha: 0.7,
                    ), // unselected color from theme
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
