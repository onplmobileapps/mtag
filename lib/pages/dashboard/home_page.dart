import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/call_helper.dart';
import 'package:mtag_flutterapp/features/promotion_page.dart';
import 'package:mtag_flutterapp/features/story_view_page.dart';
import 'package:mtag_flutterapp/theme/app_theme.dart';
import 'package:mtag_flutterapp/widgets/mtag_recovery_widget.dart';
import '../../api/user_repo.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../features/recharge_center_locator.dart';
import '../../widgets/bottomnavbar/bottomnavbar.dart';
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

    // const ActivityScreen(),
    RechargeMapScreen(),
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
      appBar: controller.currentPage.value == 0 ? AppBar() : null,
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
                              // SliverToBoxAdapter(child: Container(height: screenHeight*0.0,),),
                              controller.dashboradData.value.activeMtags !=
                                          null &&
                                      controller
                                          .dashboradData
                                          .value
                                          .activeMtags!
                                          .isNotEmpty
                                  ? SliverToBoxAdapter(
                                      child: SizedBox(
                                        height: screenHeight * 0.62,
                                        child: ListView.builder(
                                          scrollDirection: .horizontal,
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
                                                //recovery condition
                                                return e.isactive == 9
                                                    ? mtagRecoveryWidget(
                                                        context,
                                                        size: MediaQuery.sizeOf(
                                                          context,
                                                        ),
                                                        height:
                                                            screenHeight * 0.40,
                                                        isBlock: e.isactive,

                                                        mtagId: e.tokenno,

                                                        mobileNum:
                                                            _otherConstants
                                                                .mobile
                                                                .string,
                                                        cnic: _otherConstants
                                                            .ownerCNIC
                                                            .string,
                                                        regId: e.registration,
                                                        blockAmount:
                                                            e.block_amount,
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
                                                        mobileNum:
                                                            _otherConstants
                                                                .mobile
                                                                .string,
                                                        cnic: _otherConstants
                                                            .ownerCNIC
                                                            .string,
                                                        regId: e.registration,
                                                        ball: e.balance,
                                                        showTransferButton:
                                                            controller
                                                                    .dashboradData
                                                                    .value
                                                                    .activeMtags!
                                                                    .length ==
                                                                1
                                                            ? false
                                                            : true,
                                                        balanceDashboard:
                                                            e.balance,
                                                        showChassisBadge:
                                                            e.chassis_number ==
                                                                null
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
                                            color: Theme.of(
                                              context,
                                            ).disabledColor,
                                          ),
                                          child: Row(
                                            spacing: 8,
                                            mainAxisAlignment: .start,
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
                                                    fit: .contain,
                                                    alignment: .center,
                                                  ),
                                                ),
                                              const SizedBox(height: 8),
                                              Text(
                                                controller
                                                        .dashBoardModel[index]
                                                        .title ??
                                                    '',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextTheme.of(context)
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: primarSwatch,
                                                      fontWeight: .w600,
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
                                    height: 150, // fixed height for the list
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          OtherConsts.sliderImages.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final imageName =
                                            OtherConsts.sliderImages[index];
                                        final imageUrl =
                                            'assets/slider/$imageName';

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
                                              border: .all(color: primarSwatch),
                                              image: DecorationImage(
                                                image: AssetImage(imageUrl),
                                                fit: .fill,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: .all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: .all(width: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    spacing: 16,

                                    children: [
                                      SvgPicture.asset(
                                        'assets/phone.svg',
                                        width: 40,
                                        height: 40,
                                      ),

                                      Expanded(
                                        child: Column(
                                          spacing: 4,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Help & Customer Support',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.displayMedium,
                                            ),

                                            Text(
                                              'Call our helpline 1313 to get quick help on queries related to your M-Tag',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
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
                  );
                },
              ),
            )
          : bottomNavigations[controller.currentPage.value],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: controller.currentPage.value,
        canRefresh: _otherConstants.isRefresh.value,
        onRefreshDashboard: controller.pullRefreshDashboardData,
        onTap: (index) {
          controller.setCurrentIndex(index);
        },
      ),
    );
  }
}
