import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/call_helper.dart';
import 'package:mtag_flutterapp/features/promotion_page.dart';
import 'package:mtag_flutterapp/features/story_view_page.dart';
import 'package:mtag_flutterapp/pages/notification/notification_screen.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      resizeToAvoidBottomInset: false,
      extendBody: false,
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RechargeMapScreen()),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 50,
          width: 50,
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
            child: SvgPicture.asset(
              'assets/location.svg',
              height: 30,
            ),
          ),
        ),
      ),
      body: controller.currentPage.value == 0
          ? RefreshIndicator.adaptive(
              displacement: 60,
              onRefresh: () async {
                await Get.find<HomeController>().pullRefreshDashboardData();
              },
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.white,
                      elevation: 2,
                      expandedHeight: screenHeight * 0.45,
                      flexibleSpace: LayoutBuilder(
                        builder: (context, constraints) {
                          final top = constraints.biggest.height;
                          final isCollapsed = top <= kToolbarHeight;

                          return FlexibleSpaceBar(
                            title: isCollapsed
                                ? Obx(() {
                                    final activeMtags = controller
                                            .dashboradData.value.activeMtags ??
                                        [];
                                    if (activeMtags.isEmpty) return SizedBox();
                                    final e = activeMtags.first;
                                    return Row(
                                      children: [
                                        Text(
                                          'M-Tag: ${e.tokenno}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Vehicle: ${e.vehicletype}',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Chassis: ${e.chassis_number ?? "-"}',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    );
                                  })
                                : null,
                            background: Obx(() {
                              final activeMtags = controller
                                      .dashboradData.value.activeMtags ??
                                  [];
                              if (activeMtags.isEmpty) return SizedBox();
                              if (!isCollapsed) {
                                return ListView.builder(shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,physics: NeverScrollableScrollPhysics(),
                                  itemCount: activeMtags.length,
                                  itemBuilder: (context, index) {
                                    final e = activeMtags[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      child: Obx(() {
                                        return e.isactive == 9
                                            ? mtagRecoveryWidget(
                                                context,
                                                size:
                                                    MediaQuery.sizeOf(context),
                                                height: screenHeight * 0.60,
                                                isBlock: e.isactive,
                                                mtagId: e.tokenno,
                                                mobileNum: _otherConstants
                                                    .mobile.string,
                                                cnic: _otherConstants
                                                    .ownerCNIC.string,
                                                regId: e.registration,
                                                blockAmount: e.block_amount,
                                              )
                                            : mtagDataWidget(
                                                context,
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
                                                    .mobile.string,
                                                cnic: _otherConstants
                                                    .ownerCNIC.string,
                                                regId: e.registration,
                                                ball: e.balance,
                                                showTransferButton:
                                                    activeMtags.length == 1
                                                        ? false
                                                        : true,
                                                balanceDashboard: e.balance,
                                                showChassisBadge:
                                                    e.chassis_number == null,
                                                chassisNumber: e.chassis_number,
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
                body: Obx(
                  () => controller.isLoading.value
                      ? buildShimmerEffect(screenWidth, screenHeight)
                      : CustomScrollView(
                          slivers: [
                            // Keep all your existing slivers exactly as-is
                            // Dashboard Grid
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
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
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
                                            if (controller.dashBoardModel[index]
                                                    .image !=
                                                null)
                                              Padding(
                                                padding: .all(8.0),
                                                child: Image.asset(
                                                  controller
                                                      .dashBoardModel[index].image!,
                                                  width: screenWidth * 0.1,
                                                  height: screenHeight * 0.1,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              controller.dashBoardModel[index].title ??
                                                  '',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextTheme.of(context)
                                                  .bodyLarge
                                                  ?.copyWith(
                                                    color: primarSwatch,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: controller.dashBoardModel.length,
                                ),
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
                                    separatorBuilder: (_, __) =>
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
                                              stories:
                                                  OtherConsts.sliderImages,
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          height: 150,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            borderRadius: .circular(8),
                                            border: Border.all(color: primarSwatch),
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
                                  color: Colors.white,
                                  border: Border.all(width: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/phone.svg',
                                      width: 40,
                                      height: 40,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Help & Customer Support',
                                            style: Theme.of(context)
                                                .textTheme
                                                .displayMedium,
                                          ),
                                          Text(
                                            'Call our helpline 1313 to get quick help on queries related to your M-Tag',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              minimumSize: const Size(70, 28),
                                              maximumSize: const Size(70, 28),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
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
                ),
              ),
            )
          : bottomNavigations[controller.currentPage.value],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 20,
        selectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (value) {
          (value == 0 && _otherConstants.isRefresh.value)
              ? controller.pullRefreshDashboardData()
              : null;
          controller.setCurrentIndex(value);
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Theme.of(context).primaryColor,
        ),
        unselectedItemColor: Colors.grey,
        currentIndex: controller.currentPage.value,
        unselectedFontSize: 11,
        unselectedIconTheme: const IconThemeData(color: Colors.grey),
        backgroundColor: Colors.white,
        items: [
          buildCustomNavItem(
            context: context,
            index: 0,
            currentIndex: controller.currentPage.value,
            label: 'Home',
            asset: 'assets/house-blank.svg',
          ),
          buildCustomNavItem(
            context: context,
            index: 1,
            currentIndex: controller.currentPage.value,
            label: 'Promotions',
            asset: 'assets/promotion.svg',
          ),
          buildCustomNavItem(
            context: context,
            index: 2,
            currentIndex: controller.currentPage.value,
            label: 'Notifications',
            asset: 'assets/allert.svg',
          ),
          buildCustomNavItem(
            context: context,
            index: 3,
            currentIndex: controller.currentPage.value,
            label: 'Profile',
            asset: 'assets/user.svg',
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem buildCustomNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String label,
    required String asset,
  }) {
    bool isSelected = index == currentIndex;

    Widget navContent = Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            asset,
            height: 15,
            color: isSelected ? Colors.white : Colors.grey,
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );

    return BottomNavigationBarItem(
      label: label,
      icon: navContent,
      activeIcon: SizedBox(height: 50, child: navContent),
    );
  }
}
