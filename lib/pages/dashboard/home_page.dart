import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/call_helper.dart';
import 'package:mtag_flutterapp/features/promotion_page.dart';
import 'package:mtag_flutterapp/features/story_view_page.dart';
import 'package:mtag_flutterapp/pages/notification/notification_screen.dart';

import '../../api/user_repo.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../features/recharge_center_locator.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/shimmer_dashboard.dart';
import '../recharge/controller/recharge_controller.dart';
import '../settings/setting_screen.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final bottomNavigations = <Widget>[
    _HomeContent(),
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
          value: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterDocked,
            resizeToAvoidBottomInset: false,
            extendBody: false,
            floatingActionButton: _buildFloatingButton(context),
            body: bottomNavigations[controller.currentPage.value],
            bottomNavigationBar: _buildBottomNavigationBar(context, controller),
          ),
        );
      },
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return GestureDetector(
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
    );
  }

  Widget _buildBottomNavigationBar(
      BuildContext context, HomeController controller) {
    return BottomAppBar(
      height: 50,
      padding: const EdgeInsets.only(top: 8),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      elevation: 10,
      color: Colors.grey.withAlpha(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildCustomNavItem(
            context: context,
            index: 0,
            currentIndex: controller.currentPage.value,
            label: 'Home',
            asset: 'assets/house-blank.svg',
            onTap: () {
              if (controller.currentPage.value == 0 &&
                  _otherConstants.isRefresh.value) {
                controller.pullRefreshDashboardData();
              }
              controller.setCurrentIndex(0);
            },
          ),
          _buildCustomNavItem(
            context: context,
            index: 1,
            currentIndex: controller.currentPage.value,
            label: 'Promotions',
            asset: 'assets/promotion.svg',
            onTap: () => controller.setCurrentIndex(1),
          ),
          _buildCustomNavItem(
            context: context,
            index: 2,
            currentIndex: controller.currentPage.value,
            label: 'Notifications',
            asset: 'assets/allert.svg',
            onTap: () => controller.setCurrentIndex(2),
          ),
          _buildCustomNavItem(
            context: context,
            index: 3,
            currentIndex: controller.currentPage.value,
            label: 'Profile',
            asset: 'assets/user.svg',
            onTap: () => controller.setCurrentIndex(3),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavItem({
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
        : colorScheme.secondary.withAlpha(180);

    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            asset,
            height: 22,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: iconColor,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  _HomeContent();

  final HomeController controller = Get.find<HomeController>();
  final _otherConstants = OtherConsts();

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        final screenWidth = MediaQuery.sizeOf(context).width;

        if (controller.isLoading.value) {
          return buildShimmerEffect(screenWidth, screenHeight);
        }

        return _HomeContentBody(
          controller: controller,
          otherConstants: _otherConstants,
          screenHeight: screenHeight,
          screenWidth: screenWidth,
        );
      },
    );
  }
}

class _HomeContentBody extends StatefulWidget {
  final HomeController controller;
  final OtherConsts otherConstants;
  final double screenHeight;
  final double screenWidth;

  const _HomeContentBody({
    required this.controller,
    required this.otherConstants,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  State<_HomeContentBody> createState() => _HomeContentBodyState();
}

class _HomeContentBodyState extends State<_HomeContentBody> {
  final PageController _mtagPageController = PageController();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize with first M-Tag
      final activeMtags =
          widget.controller.dashboradData.value.activeMtags ?? [];
      if (activeMtags.isNotEmpty) {
        widget.controller.selectedMtagIndex.value = 0;
      }
    });
  }

  @override
  void dispose() {
    _mtagPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 2,
            expandedHeight: widget.screenHeight * 0.52,
            flexibleSpace: _MtagHeaderSection(
              controller: widget.controller,
              otherConstants: widget.otherConstants,
              screenHeight: widget.screenHeight,
              pageController: _mtagPageController,
              onPageChanged: (index) {
                widget.controller.selectedMtagIndex.value = index;
              },
            ),
          ),
        ];
      },
      body: 
        _DashboardGridSection(
          controller: widget.controller,
          otherConstants: widget.otherConstants,
        ),
      
    );
  }
}

class _MtagHeaderSection extends StatelessWidget {
  final HomeController controller;
  final OtherConsts otherConstants;
  final double screenHeight;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;

  const _MtagHeaderSection({
    required this.controller,
    required this.otherConstants,
    required this.screenHeight,
    required this.pageController,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      titlePadding: EdgeInsets.zero,
      background: Obx(() {
        final activeMtags = controller.dashboradData.value.activeMtags ?? [];
        if (activeMtags.isEmpty) return const SizedBox();

        return Column(
          children: [
            SizedBox(
              height: screenHeight * 0.52,
              child: PageView.builder(
                controller: pageController,
                onPageChanged: onPageChanged,
                itemCount: activeMtags.length,
                itemBuilder: (context, index) {
                  final e = activeMtags[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: mtagDataWidget(
                            context,
                            isBlock: e.isactive,
                            jazzCode: controller
                                .dashboradData.value.jazzCashRecharge
                                .toString(),
                            creditCode: controller
                                .dashboradData.value.creditCardRecharge
                                .toString(),
                            vehType: e.vehicletype,
                            mtagId: e.tokenno,
                            userName: e.ownername,
                            mobileNum: otherConstants.mobile.string,
                            cnic: otherConstants.ownerCNIC.string,
                            regId: e.registration,
                            ball: e.balance,
                            showTransferButton: activeMtags.length > 1,
                            balanceDashboard: e.balance,
                            showChassisBadge: e.chassis_number == null,
                            chassisNumber: e.chassis_number,
                          ),
                  );
                },
              ),
            ),
            if (activeMtags.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  activeMtags.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: controller.selectedMtagIndex.value == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _DashboardGridSection extends StatelessWidget {
  final HomeController controller;
  final OtherConsts otherConstants;

  const _DashboardGridSection({
    required this.controller,
    required this.otherConstants,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.sizeOf(context).width * 0.5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: MediaQuery.sizeOf(context).height * 0.11,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = controller.dashBoardModel[index];
                return InkWell(
                  onTap: () async {
                    final rechctrl = Get.find<RechargeController>();
                    // selected1linkOpt.value = -1;
                    
                    if (item.routeName != null) {
                      await Get.toNamed(
                        item.routeName!,
                        arguments: controller.dashboradData.value.activeMtags,
                      );
                    }
                    
                    // selected1linkOpt.value = -1;
                    rechctrl.isPaymentModdeVisible(false);
                    rechctrl.isSummaryVisible(false);
                    rechctrl.isRechageVisible(true);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).colorScheme.surfaceContainerLowest.withValues(alpha: 0.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (item.image != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              item.image!,
                              width: MediaQuery.sizeOf(context).width * 0.1,
                              height: MediaQuery.sizeOf(context).height * 0.1,
                              fit: BoxFit.contain,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
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
        const SliverToBoxAdapter(
          child: SizedBox(height: 8),
        ),
        _SliderSection(),
        _HelpSection(),
      ],
    );
  }
}

class _SliderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap to see what\'s new',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: OtherConsts.sliderImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final imageName = OtherConsts.sliderImages[index];
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
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).highlightColor,
                        ),
                        image: DecorationImage(
                          image: AssetImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            width: 0.1,
            color: Theme.of(context).colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/phone.svg',
              width: 50,
              height: 50,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help & Customer Support',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Call our helpline 1313 to get quick help on queries related to your M-Tag',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: CallWhatsappUtil.openCall1313,
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
                    iconAlignment: IconAlignment.end,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(70, 28),
                      maximumSize: const Size(70, 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}