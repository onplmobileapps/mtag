

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../fcm_handeler.dart';
import '../../widgets/appbar/app_bar_widget.dart';

import '../../api/user_repo.dart';
import '../../base/app_data.dart';
import '../../constants/call_helper.dart';
import '../../controller/home_controller.dart';
import '../../widgets/dashboard_widget.dart';
import '../../api/application_url.dart';
import '../../constants/other_consts.dart';
import '../../widgets/dialog/chat_support_dialog.dart';

import '../../widgets/shimmer_dashboard.dart';
import '../activity/activity_screen.dart';
import '../recharge/controller/recharge_controller.dart';
import '../recharge/recharge_new_design.dart';
import '../settings/setting_screen.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});
  final _carouselController = CarouselSliderController();

  final bottomNavigations = <Widget>[
    Container(),
    const ActivityScreen(),
    SettingScreen(),
    Container()
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
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: controller.currentPage.value == 0
                  ? BuilAppBarWidget(
                      isDarkTheme: AppData.theme == true,
                      onSupportTap: () {
                        showCustomDialog(
                            context: context, message: 'Support Center');
                      },
                      onSmsTap: () {
                        Get.toNamed('/smsAlert',
                            arguments:
                                controller.dashboradData.value.activeMtags);
                      },
                      badgeCountNotifier: _messagingService.badgeCountNotifier,
                      onNotificationTap: () {
                        Get.toNamed('/notifications');
                        _messagingService.resetBadgeCount();
                      })
                  : null,
              body: controller.currentPage.value == 0
                  ? RefreshIndicator.adaptive(
                      displacement: 60,
                      onRefresh: () async {
                        controller.pullRefreshDashboardData();
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Screen dimensions
                          final screenWidth = constraints.maxWidth;
                          final screenHeight = constraints.maxHeight;

                          return Obx(
                            () => controller.isLoading.value
                                ? buildShimmerEffect(screenWidth, screenHeight)
                                : CustomScrollView(
                                    slivers: [
                                      // Responsive Carousel
                                      controller.dashboradData.value
                                                      .picturesURL !=
                                                  null &&
                                              controller.dashboradData.value
                                                  .picturesURL!.imgs!.isNotEmpty
                                          ? SliverToBoxAdapter(
                                              child: SizedBox(
                                                height: screenHeight *
                                                    0.38, // 25% of screen height
                                                child: Stack(
                                                  children: [
                                                    CarouselSlider(
                                                      carouselController:
                                                          _carouselController,
                                                      items: controller
                                                          .dashboradData
                                                          .value
                                                          .picturesURL!
                                                          .imgs
                                                          ?.map((e) {
                                                        final imageUrl =
                                                            '${ApplicationUrl.IMAGE_ULR}${e.name}?v=${DateTime.now().millisecondsSinceEpoch}';

                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            child:
                                                                CachedNetworkImage(
                                                              width: double
                                                                  .infinity,
                                                              imageUrl:
                                                                  imageUrl,
                                                              fit: BoxFit.cover,
                                                              errorWidget:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Container(
                                                                  color: Colors
                                                                          .grey[
                                                                      300],
                                                                  child: Center(
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/placeholder.png',
                                                                      width:
                                                                          screenWidth *
                                                                              0.3,
                                                                      height:
                                                                          screenHeight *
                                                                              0.15,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                return Container(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/placeholder.png',
                                                                    width: double
                                                                        .infinity,
                                                                    height:
                                                                        screenHeight *
                                                                            0.15,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                );
                                                              },
                                                              memCacheHeight:
                                                                  600,
                                                              memCacheWidth:
                                                                  600,
                                                              maxHeightDiskCache:
                                                                  600,
                                                              maxWidthDiskCache:
                                                                  600,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      options: CarouselOptions(autoPlayInterval: Duration(seconds: 10),
                                                        height:
                                                            screenHeight * 0.38,
                                                        autoPlay: true,
                                                        viewportFraction: 1.0,
                                                      ),
                                                    ),
                                                    Positioned(
                                                        right:
                                                            0, // Distance from the right edge
                                                        bottom:
                                                            100, // Distance from the bottom edge
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            CallWhatsappUtil
                                                                .openWhatsAppChat(
                                                                    "+923105931103");
                                                          },
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 4,
                                                                    bottom: 4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withAlpha(
                                                                      139),
                                                              borderRadius: BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          8),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          8)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withAlpha(
                                                                          100),
                                                                  blurRadius: 6,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 3),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Image.asset(
                                                              'assets/whatsapp.png',
                                                              width: screenWidth *
                                                                  0.1, // 10% of screen width
                                                              height:
                                                                  screenHeight *
                                                                      0.06,
                                                              fit: BoxFit
                                                                  .contain,
                                                            ),
                                                          ),
                                                        )),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : SliverToBoxAdapter(
                                              child: Container(
                                                width: double.infinity,
                                                height: screenHeight * 0.25,
                                                color: Colors.grey[300],
                                                child: Center(
                                                  child: Image.asset(
                                                    'assets/placeholder.png',
                                                    width: screenWidth * 0.3,
                                                    height: screenHeight * 0.15,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),

                                      // Responsive Horizontal Scroll for Active Tags
                                      controller.dashboradData.value
                                                      .activeMtags !=
                                                  null &&
                                              controller.dashboradData.value
                                                  .activeMtags!.isNotEmpty
                                          ? SliverToBoxAdapter(
                                              child: SizedBox(
                                                height: screenHeight *
                                                    0.25, // 15% of screen height
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: controller
                                                      .dashboradData
                                                      .value
                                                      .activeMtags!
                                                      .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final e = controller
                                                        .dashboradData
                                                        .value
                                                        .activeMtags![index];
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 0.0),
                                                      child: mtagDataWidget(
                                                        context,
                                                        size: MediaQuery.sizeOf(
                                                            context),
                                                        height: screenHeight *
                                                            0.25, // Adjust dynamically
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
                                                        regId: e.registration,
                                                        ball: e.balance,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            )
                                          : SliverToBoxAdapter(
                                              child: Container(
                                                  height: screenHeight / 3)),

                                      SliverPadding(
                                        padding: const EdgeInsets.all(8.0),
                                        sliver: SliverGrid(
                                          gridDelegate:
                                              SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: screenWidth *
                                                0.5, // Max width for each grid item
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                            mainAxisExtent: screenHeight *
                                                0.17, // Height for each grid item
                                          ),
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              return InkWell(
                                                onTap: () async {
                                                  final rechctrl = Get.find<
                                                      RechargeController>();
                                                         selected1linkOpt.value = -1;
                                                  await Get.toNamed(
                                                    '${controller.dashBoardModel[index].routeName}',
                                                    arguments: controller
                                                        .dashboradData
                                                        .value
                                                        .activeMtags,
                                                  );
                                                  selected1linkOpt.value = -1;
                                                  rechctrl
                                                      .isPaymentModdeVisible(
                                                          false);
                                                  rechctrl
                                                      .isSummaryVisible(false);
                                                  rechctrl
                                                      .isRechageVisible(true);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      if (controller
                                                              .dashBoardModel[
                                                                  index]
                                                              .image !=
                                                          null)
                                                        SvgPicture.asset(
                                                          controller
                                                              .dashBoardModel[
                                                                  index]
                                                              .image!,
                                                          width:
                                                              screenWidth * 0.1,
                                                          height: screenHeight *
                                                              0.1,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        controller
                                                                .dashBoardModel[
                                                                    index]
                                                                .title ??
                                                            '',overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                          color: Colors.white,
                                                          fontSize: screenWidth *
                                                              0.04, // Responsive font size
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            childCount: controller
                                                .dashBoardModel.length,
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
                    color: Theme.of(context).primaryColor),
                unselectedItemColor: Colors.grey,
                currentIndex: controller.currentPage.value,
                // currentIndex: controller.currentPage.value,
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
                    activeIcon: SvgPicture.asset(
                      'assets/clock-five.svg',
                      height: 20,
                      width: 20,
                      fit: BoxFit.fill,
                    ),
                    label: 'Activities',
                    tooltip: 'Activities',
                    icon: SvgPicture.asset(
                      'assets/clock-five.svg',
                      height: 20,
                      width: 20,
                      fit: BoxFit.fill,
                    ),
                  ),
                  BottomNavigationBarItem(
                    activeIcon: Image.asset(
                      'assets/settings.png',
                      height: 20,
                    ),
                    label: 'Settings',
                    tooltip: 'Settings',
                    icon: Image.asset(
                      'assets/settings.png',
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
