
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:mtag_flutterapp/widgets/mtag_recovery_widget.dart';
import '../../base/app_data.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../fcm_handeler.dart';
import '../../widgets/appbar/app_bar_widget.dart';
import '../../widgets/bottom_bar.dart';
import '../../widgets/carousal_widget.dart';
import '../../widgets/dashboard_grid.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/dialog/chat_support_dialog.dart';
import '../../widgets/shimmer_dashboard.dart';
import '../../widgets/whatsapp_widget.dart';
import '../recharge/controller/recharge_controller.dart';
import '../recharge/recharge_page.dart';
import '../settings/setting_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final HomeController controller = Get.find<HomeController>();
  final _otherConstants = OtherConsts();
  final MessagingService _messagingService = MessagingService();

  final bottomNavigation = <Widget>[Container(), SettingScreen(), Container()];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  // --------------------- AppBar ---------------------
  PreferredSizeWidget? _buildAppBar() {
    if (controller.currentPage.value != 0) return null;

    return BuilAppBarWidget(
      isDarkTheme: AppData.theme == true,
      onSupportTap: () {
        showCustomDialog(context: Get.context!, message: 'Support Center');
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
    );
  }

  // --------------------- Body ---------------------
  Widget _buildBody() {
    return Obx(() {
      if (controller.currentPage.value != 0) {
        return bottomNavigation[controller.currentPage.value];
      }

      return RefreshIndicator.adaptive(
        displacement: 60,
        onRefresh: controller.pullRefreshDashboardData,
        child: controller.isLoading.value
            ? _buildShimmer()
            : _buildHomeContent(),
      );
    });
  }

  Widget _buildShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return buildShimmerEffect(constraints.maxWidth, constraints.maxHeight);
      },
    );
  }

  Widget _buildHomeContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return CustomScrollView(
          slivers: [
            _buildCarouselSection(screenHeight),
            _buildMTagsSection(screenHeight),
            _buildDashboardGrid(screenWidth, screenHeight),
          ],
        );
      },
    );
  }

  // --------------------- Carousel + WhatsApp ---------------------
  Widget _buildCarouselSection(double screenHeight) {
    return SliverToBoxAdapter(
      child: AspectRatio(
        aspectRatio: 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CarouselWidget(),
            ),
            Positioned(
              right: 0,
              bottom: 80,
              child: WhatsAppButton(
                phoneNumber:
                    controller.dashboradData.value.helpLineNumber?.toString() ??
                    "+923105931103",
                width: 40,
                height: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------- MTags Section ---------------------
  Widget _buildMTagsSection(double screenHeight) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final activeMtags = controller.dashboradData.value.activeMtags;
        if (activeMtags == null || activeMtags.isEmpty) {
          return SizedBox(height: screenHeight * 0.2);
        }

        return SizedBox(
          height: screenHeight * 0.23,
          child: ListView.builder(padding: .zero,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: activeMtags.length,
            itemBuilder: (context, index) {
              final e = activeMtags[index];

              return e.isactive == 8
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
                      showTransferButton: activeMtags.length > 1,
                      balanceDashboard: e.balance,
                      showChassisBadge: e.chassis_number == null,
                      chassisNumber: e.chassis_number,
                    );
            },
          ),
        );
      }),
    );
  }

  // --------------------- Dashboard Grid ---------------------
  Widget _buildDashboardGrid(double screenWidth, double screenHeight) {
    return DashboardGrid(
      items: controller.dashBoardModel
          .map(
            (e) => DashboardGridItem(
              title: e.title,
              image: e.image,
              routeName: e.routeName,
            ),
          )
          .toList(),
      maxCrossAxisExtent: screenWidth * 0.5,
      mainAxisExtent: screenHeight * 0.2,
      itemColor: Theme.of(Get.context!).primaryColor,
      onItemTap: (item, index) async {
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
    );
  }

  // --------------------- Bottom Navigation ---------------------
  Widget _buildBottomNav(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: controller.currentPage.value,
      onTap: (index) {
        if (index == 0 && _otherConstants.isRefresh.value) {
          controller.pullRefreshDashboardData();
        }
        controller.setCurrentIndex(index);
      },
      selectedColor: Theme.of(context).primaryColor,
      unselectedColor: Colors.grey,
      backgroundColor: Colors.white,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/house-blank.svg',
            height: 20,
            width: 20,
          ),
          activeIcon: SvgPicture.asset(
            'assets/house-blank.svg',
            height: 20,
            width: 20,
          ),
          label: 'Home',
          tooltip: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/settings.png', height: 20),
          activeIcon: Image.asset('assets/settings.png', height: 20),
          label: 'Settings',
          tooltip: 'Settings',
        ),
      ],
    );
  }
}
