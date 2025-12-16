import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/pages/alfawebview/weather_webview.dart';
import 'package:mtag_flutterapp/widgets/mtag_recovery_widget.dart';
import '../../api/user_repo.dart';
import '../../base/app_data.dart';
import '../../constants/call_helper.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../fcm_handeler.dart';
import '../../widgets/appbar/app_bar_widget.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/dialog/chat_support_dialog.dart';
import '../../widgets/shimmer_dashboard.dart';

import '../recharge/controller/recharge_controller.dart';
import '../recharge/recharge_page.dart';
import '../settings/setting_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeController controller = Get.find<HomeController>();

  final bottomNavigations = <Widget>[Container(), SettingScreen(), Container()];
  final _otherConstants = OtherConsts();
  final MessagingService _messagingService = MessagingService();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: controller.currentPage.value == 0
          ? BuilAppBarWidget(
              isDarkTheme: AppData.theme == true,
              onSupportTap: () {
                showCustomDialog(context: context, message: 'Support Center');
              },
              onSmsTap: () {
                Get.toNamed(
                  '/smsAlert',
                  arguments: controller.dashboradData.value.activeMtags,
                );
              },
              badgeCountNotifier: _messagingService.badgeCountNotifier,
              onNotificationTap: () {
                Get.toNamed('/notifications');
                _messagingService.resetBadgeCount();
              },
            )
          : null,
      body: Obx(
        () => controller.currentPage.value == 0
            ? _buildHomeBody(context)
            : bottomNavigations[controller.currentPage.value],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return RefreshIndicator.adaptive(
      displacement: 60,
      onRefresh: () async {
        await controller.pullRefreshDashboardData();
      },
      child: Obx(() {
        if (controller.isLoading.value) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return buildShimmerEffect(
                constraints.maxWidth,
                constraints.maxHeight,
              );
            },
          );
        }

        return _buildContent(context);
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return CustomScrollView(
          // physics: const BouncingScrollPhysics(),
          slivers: [
            // Carousel Section - SIMPLIFIED
            SliverToBoxAdapter(
              child: AspectRatio(
                aspectRatio: 2,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildCarousel(),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 80,
                      child: Column(children: [_buildWhatsAppButton()]),
                    ),
                  ],
                ),
              ),
            ),

            // MTags Section
            _buildMTagsSection(screenHeight),

            // Dashboard Grid Section
            _buildDashboardGrid(screenWidth, screenHeight),
          ],
        );
      },
    );
  }

  Widget _buildCarousel() {
    // SIMPLIFIED Carousel - Remove complex logic first
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: OtherConsts.sliderImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/slider/${OtherConsts.sliderImages[index]}',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhatsAppButton() {
    return GestureDetector(
      onTap: () {
        CallWhatsappUtil.openWhatsAppChat(
          controller.dashboradData.value.helpLineNumber?.toString() ??
              "+923105931103",
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Image.asset('assets/whatsapp_round.png', width: 40, height: 40),
      ),
    );
  }

  Widget _buildMTagsSection(double screenHeight) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.dashboradData.value.activeMtags == null ||
            controller.dashboradData.value.activeMtags!.isEmpty) {
          return SizedBox(height: screenHeight * 0.2);
        }

        return SizedBox(
          height: screenHeight * 0.23,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.dashboradData.value.activeMtags!.length,
            itemBuilder: (context, index) {
              final e = controller.dashboradData.value.activeMtags![index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: e.isactive == 8
                    ? mtagRecoveryWidget(
                        context,
                        size: MediaQuery.sizeOf(context),
                        height: screenHeight * 0.29,
                        isBlock: e.isactive,
                        mtagId: e.tokenno,
                        mobileNum: _otherConstants.mobile.string,
                        cnic: _otherConstants.ownerCNIC.string,
                        regId: e.registration,
                        blockAmount: e.block_amount,
                      )
                    : mtagDataWidget(
                        context,
                        size: MediaQuery.sizeOf(context),
                        height: screenHeight * 0.29,
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
                        mobileNum: _otherConstants.mobile.string,
                        cnic: _otherConstants.ownerCNIC.string,
                        regId: e.registration,
                        ball: e.balance,
                        showTransferButton:
                            controller
                                    .dashboradData
                                    .value
                                    .activeMtags
                                    ?.length ==
                                1
                            ? false
                            : true,
                        balanceDashboard: e.balance,
                        showChassisBadge: e.chassis_number == null,
                        chassisNumber: e.chassis_number,
                      ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildDashboardGrid(double screenWidth, double screenHeight) {
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: screenWidth * 0.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: screenHeight * 0.20,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = controller.dashBoardModel[index];
          return InkWell(
            onTap: () async {
              final rechctrl = Get.find<RechargeController>();
              selected1linkOpt.value = -1;
              await Get.toNamed(
                item.routeName ?? '',
                arguments: controller.dashboradData.value.activeMtags,
              );
              selected1linkOpt.value = -1;
              rechctrl.isPaymentModdeVisible(false);
              rechctrl.isSummaryVisible(false);
              rechctrl.isRechageVisible(true);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.image != null)
                    SvgPicture.asset(
                      item.image!,
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.1,
                    ),
                  const SizedBox(height: 8),
                  Text(
                    item.title ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: controller.dashBoardModel.length),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        iconSize: 20,
        selectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (value) {
          if (value == 0 && _otherConstants.isRefresh.value) {
            controller.pullRefreshDashboardData();
          }
          controller.setCurrentIndex(value);
        },
        showSelectedLabels: true,
        showUnselectedLabels: true,
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
          BottomNavigationBarItem(
            tooltip: 'Home',
            activeIcon: SvgPicture.asset(
              'assets/house-blank.svg',
              height: 20,
              width: 20,
              fit: BoxFit.fill,
            ),
            label: 'Home',
            icon: SvgPicture.asset(
              'assets/house-blank.svg',
              height: 20,
              width: 20,
              fit: BoxFit.fill,
            ),
          ),
          BottomNavigationBarItem(
            activeIcon: Image.asset('assets/settings.png', height: 20),
            label: 'Settings',
            tooltip: 'Settings',
            icon: Image.asset('assets/settings.png', height: 20),
          ),
        ],
      ),
    );
  }
}
