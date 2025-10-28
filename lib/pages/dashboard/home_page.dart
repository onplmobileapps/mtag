import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
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

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  final _carouselController = CarouselSliderController();

  final bottomNavigations = <Widget>[
    Container(),
    // const ActivityScreen(),
    SettingScreen(),
    Container(),
  ];
  final _otherConstants = OtherConsts();
  final MessagingService _messagingService = MessagingService();

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
          child: _buildScaffold(
            context,
            controller,
          ), // No UpgradeAlert for non-iOS
        );
      },
    );
  }

  Widget _buildScaffold(BuildContext context, HomeController controller) {
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
      body: controller.currentPage.value == 0
          ? RefreshIndicator.adaptive(
              displacement: 60,
              onRefresh: () async {
                await Get.find<HomeController>().pullRefreshDashboardData();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;

                  return Obx(
                    () => controller.isLoading.value
                        ? buildShimmerEffect(screenWidth, screenHeight)
                        : CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: AspectRatio(
                                  aspectRatio: 2,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: CarouselSlider(
                                          carouselController:
                                              _carouselController,
                                          items: OtherConsts.sliderImages.map((
                                            e,
                                          ) {
                                            final imageUrl = 'assets/slider/$e';
                                            return ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),

                                              child: Image.asset(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: Colors.grey[300],
                                                        child: Center(
                                                          child: Image.asset(
                                                            'assets/placeholder.png',
                                                            fit: BoxFit.cover,
                                                            width:
                                                                double.infinity,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                              ),
                                            );
                                          }).toList(),
                                          options: CarouselOptions(
                                            height: 600,
                                            viewportFraction: 1,
                                            autoPlay: true,
                                            autoPlayInterval: const Duration(
                                              seconds: 5,
                                            ),
                                            enlargeCenterPage: true,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 80,
                                        child: GestureDetector(
                                          onTap: () {
                                            CallWhatsappUtil.openWhatsAppChat(
                                              controller
                                                          .dashboradData
                                                          .value
                                                          .helpLineNumber !=
                                                      null
                                                  ? controller
                                                        .dashboradData
                                                        .value
                                                        .helpLineNumber
                                                        .toString()
                                                  : "+923105931103",
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(
                                                139,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft: Radius.circular(
                                                      8,
                                                    ),
                                                  ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withAlpha(
                                                    100,
                                                  ),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Image.asset(
                                              'assets/whatsapp.png',
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              controller.dashboradData.value.activeMtags !=
                                          null &&
                                      controller
                                          .dashboradData
                                          .value
                                          .activeMtags!
                                          .isNotEmpty
                                  ? SliverToBoxAdapter(
                                      child: SizedBox(
                                        height: screenHeight * 0.23,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: controller
                                              .dashboradData
                                              .value
                                              .activeMtags!
                                              .length,
                                          itemBuilder: (context, index) {
                                            final e = controller
                                                .dashboradData
                                                .value
                                                .activeMtags![index];
                                            if (!controller.hiddenStates
                                                .containsKey(e.tokenno)) {
                                              controller.hiddenStates[e.tokenno
                                                      .toString()] =
                                                  true;
                                            }
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 0.0,
                                                  ),

                                              child: Obx(() {
                                                return
                                                // controller.isLoading.value
                                                //   ? placeholderWidget(
                                                //       context,
                                                //       size: MediaQuery.sizeOf(
                                                //         context,
                                                //       ),
                                                //       height:
                                                //           screenHeight * 0.29,
                                                //     )
                                                //   :
                                                mtagDataWidget(
                                                  context,
                                                  size: MediaQuery.sizeOf(
                                                    context,
                                                  ),
                                                  height: screenHeight * 0.28,
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
                                                  ball:
                                                      controller.balances[e
                                                          .tokenno] ??
                                                      "0.00",
                                                  showTransferButton:
                                                      controller
                                                              .dashboradData
                                                              .value
                                                              .activeMtags!
                                                              .length ==
                                                          1
                                                      ? false
                                                      : true,
                                                  balanceDashboard: e.balance,
                                                  showChassisBadge:
                                                      e.chassis_number == null
                                                      ? true
                                                      : false,
                                                  chassisNumber:
                                                      e.chassis_number,
                                                );
                                              }),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : SliverToBoxAdapter(
                                      child: Container(
                                        height: screenHeight / 3,
                                      ),
                                    ),

                              SliverPadding(
                                padding: const EdgeInsets.all(8.0),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: screenWidth * 0.5,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        mainAxisExtent: screenHeight * 0.20,
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (controller
                                                      .dashBoardModel[index]
                                                      .image !=
                                                  null)
                                                SvgPicture.asset(
                                                  controller
                                                      .dashBoardModel[index]
                                                      .image!,
                                                  width: screenWidth * 0.1,
                                                  height: screenHeight * 0.1,
                                                  fit: BoxFit.contain,
                                                ),
                                              const SizedBox(height: 8),
                                              Text(
                                                controller
                                                        .dashBoardModel[index]
                                                        .title ??
                                                    '',
                                                overflow: TextOverflow.ellipsis,
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
                                    },
                                    childCount:
                                        controller.dashBoardModel.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                },
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
          // BottomNavigationBarItem(
          //   activeIcon: SvgPicture.asset(
          //     'assets/clock-five.svg',
          //     height: 20,
          //     width: 20,
          //     fit: BoxFit.fill,
          //   ),
          //   label: 'Activities',
          //   tooltip: 'Activities',
          //   icon: SvgPicture.asset(
          //     'assets/clock-five.svg',
          //     height: 20,
          //     width: 20,
          //     fit: BoxFit.fill,
          //   ),
          // ),
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
