import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../constants/call_helper.dart';
import '../../features/promotion_page.dart';
import '../../features/story_view_page.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../../pages/mtag/controller/delink_controller.dart';
import '../../pages/notification/notification_screen.dart';
import '../../widgets/balance_widget.dart';
import '../../widgets/bottomsheet/balance_transfer_bs.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/dialog/chassis_num.dart';
import '../../widgets/dialog/delink_dialog.dart';
import '../../api/user_repo.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../features/recharge_center_locator.dart';
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
    BuildContext context,
    HomeController controller,
  ) {
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeMtags =
          widget.controller.dashboradData.value.activeMtags ?? [];
      if (activeMtags.isNotEmpty) {
        widget.controller.selectedMtagIndex.value = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          expandedHeight: widget.screenHeight * 0.47,
          flexibleSpace: _MtagHeaderSection(
            controller: widget.controller,
            otherConstants: widget.otherConstants,
            screenHeight: widget.screenHeight,
            // Removed pageController parameter
          ),
        ),
        _DashboardGridSection(
          controller: widget.controller,
          otherConstants: widget.otherConstants,
        ),
        _SliderSection(),
        _HelpSection(),
      ],
    );
  }
}

class _MtagHeaderSection extends StatelessWidget {
  final HomeController controller;
  final OtherConsts otherConstants;
  final double screenHeight;

  const _MtagHeaderSection({
    required this.controller,
    required this.otherConstants,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      titlePadding: EdgeInsets.zero,
      background: Obx(() {
        final activeMtags = controller.dashboradData.value.activeMtags ?? [];
        if (activeMtags.isEmpty) return const SizedBox();

        return _MtagContent(
          controller: controller,
          otherConstants: otherConstants,
          activeMtags: activeMtags,
          screenHeight: screenHeight,
        );
      }),
    );
  }
}

class _MtagContent extends StatefulWidget {
  final HomeController controller;
  final OtherConsts otherConstants;
  final List<dynamic> activeMtags;
  final double screenHeight;

  const _MtagContent({
    required this.controller,
    required this.otherConstants,
    required this.activeMtags,
    required this.screenHeight,
  });

  @override
  State<_MtagContent> createState() => _MtagContentState();
}

class _MtagContentState extends State<_MtagContent>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 0;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.controller.selectedMtagIndex.value.clamp(
      0,
      widget.activeMtags.length - 1,
    );

    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _pageController.addListener(_handlePageScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _handlePageScroll() {
    if (!_isScrolling) {
      _isScrolling = true;
    }

    // Calculate current page from scroll position
    final page = _pageController.page;
    if (page != null) {
      final newIndex = page.round();
      if (newIndex != _currentIndex) {
        _currentIndex = newIndex;
        widget.controller.selectedMtagIndex.value = _currentIndex;
        _animationController.reset();
        _animationController.forward();

        // Force rebuild to update header
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void _handlePageScrollEnd() {
    _isScrolling = false;
    // Ensure final index is set correctly
    if (_pageController.page != null) {
      final finalIndex = _pageController.page!.round();
      if (finalIndex != _currentIndex) {
        _currentIndex = finalIndex;
        widget.controller.selectedMtagIndex.value = _currentIndex;
      }
    }
  }

  void _jumpToPage(int index) {
    _currentIndex = index.clamp(0, widget.activeMtags.length - 1);
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    widget.controller.selectedMtagIndex.value = _currentIndex;
    _animationController.reset();
    _animationController.forward();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant _MtagContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.activeMtags.length != oldWidget.activeMtags.length) {
      _pageController.dispose();
      _pageController = PageController(
        initialPage: _currentIndex.clamp(0, widget.activeMtags.length - 1),
        viewportFraction: 1,
      );
      _pageController.addListener(_handlePageScroll);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageScroll);
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMtag = widget.activeMtags[_currentIndex];

    return Column(
      mainAxisSize: .min,
      children: [
        // Static Header Section - M-TAG Details (Updates with animation)
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Container(child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'M-TAG',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                _buildMtagDetailRow(
                  context,
                  icon: Icons.folder_outlined,
                  label: 'M-TAG',
                  value: currentMtag.tokenno,
                ),
                _buildMtagDetailRow(
                  context,
                  icon: Icons.delivery_dining,
                  label: 'Vehicle No',
                  value: currentMtag.registration,
                ),
                _buildMtagDetailRow(
                  context,
                  icon: Icons.description,
                  label: 'Chassis No',
                  value: currentMtag.chassis_number,
                  isChassis: true,
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => ChassisNumberDialog(
                        registration: currentMtag.registration ?? '',
                        tokenNo: currentMtag.tokenno ?? '',
                        mobileNumber: widget.otherConstants.mobile.string,
                        balance: currentMtag.balance ?? '',
                        cnicNumber: widget.otherConstants.ownerCNIC.string,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Scrollable Content Section - Car Image & Balance
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: ColorScheme.of(
                context,
              ).surfaceContainerLowest.withValues(alpha: 0.4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal scrollable content with PageView
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Horizontal scrollable content with PageView
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            NotificationListener<ScrollEndNotification>(
                              onNotification: (notification) {
                                _handlePageScrollEnd();
                                return false;
                              },
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  _currentIndex = index;
                                  widget.controller.selectedMtagIndex.value =
                                      index;
                                  _animationController.reset();
                                  _animationController.forward();

                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                itemCount: widget.activeMtags.length,
                                itemBuilder: (context, index) {
                                  final mtag = widget.activeMtags[index];
                                  return _buildScrollableContent(
                                    context,
                                    mtag,
                                    index,
                                  );
                                },
                              ),
                            ),

                            // Floating navigation arrows
                            if (widget.activeMtags.length > 1)
                              Positioned.fill(
                                top: -100,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: .center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Left arrow with fade effect
                                      Opacity(
                                        opacity: _currentIndex > 0 ? 1.0 : 0.3,
                                        child: IgnorePointer(
                                          ignoring:
                                              _currentIndex >=
                                              widget.activeMtags.length,
                                          child: _buildNavButton(
                                            context,
                                            icon: Icons.arrow_back_ios_rounded,
                                            onTap: () =>
                                                _jumpToPage(_currentIndex - 1),
                                            enabled: _currentIndex >= 0,
                                          ),
                                        ),
                                      ),

                                      // Right arrow with fade effect
                                      Opacity(
                                        opacity:
                                            _currentIndex <
                                                widget.activeMtags.length - 1
                                            ? 1.0
                                            : 0.3,
                                        child: IgnorePointer(
                                          ignoring:
                                              _currentIndex >=
                                              widget.activeMtags.length - 1,
                                          child: _buildNavButton(
                                            context,
                                            icon:
                                                Icons.arrow_forward_ios_rounded,
                                            onTap: () =>
                                                _jumpToPage(_currentIndex + 1),
                                            enabled: _currentIndex <= 0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
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
    );
  }
}

Widget _buildScrollableContent(
  BuildContext context,
  ActiveMtags mtag,
  int index,
) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: .start,
    children: [
      Spacer(),
      Center(
        child: Transform.scale(
          scaleY: 2.0,
          scaleX: 2.4,
          child: Image.asset("assets/honda.png", width: 80, fit: BoxFit.fill),
        ),
      ),
      Spacer(),
      // Balance Section
      Row(
        mainAxisAlignment: .center,
        children: [
          Text(
            "Balance",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
          ),

          BalanceWidget(
            balance: mtag.balance ?? '',
            fontSize: 24,
            iconSize: 24,
          ),
        ],
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // if (showTransferButton == false)
          actionBtn(
            context,
            label: "Transfer",
            icon: Icons.arrow_outward_outlined,
            avatarRadius: 24,
            fontSize: 12,
            iconSize: 30,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BalanceTransferSheet(
                  carRegistration: mtag.registration,
                  balance: mtag.balance,
                  cnicNumber: '24242424444',
                  mobileNumber: mtag.mobilenum,
                  mtagid: mtag.tokenno,
                  dropDownCars: [],
                ),
              );
            },
          ),

          actionBtn(
            context,
            label: "Recharge",
            icon: Icons.add,
            avatarRadius: 24,
            fontSize: 11,
            iconSize: 30,
            onTap: () {
              showPaymentBottomSheet(
                context,
                mtagId: mtag.tokenno,
                regId: mtag.registration,
                jazzCode: '1',
                creditCode: '0',
                blackListRecharge: false,
              );
            },
          ),

          actionBtn(
            context,
            label: "Delete",
            icon: Icons.delete_outline_rounded,
            avatarRadius: 24,
            fontSize: 12,
            iconSize: 30,
            onTap: () {
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
            },
          ),
        ],
      ),
    ],
  );
}

Widget _buildMtagDetailRow(
  BuildContext context, {
  required IconData icon,
  required String label,
  required String? value,
  bool isChassis = false,
  VoidCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xff9E9EAD), size: 20),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(color: Color(0xff9E9EAD), fontSize: 14),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value ?? 'N/A',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (isChassis && value == null)
          GestureDetector(
            onTap: onTap,
            child: const Icon(Icons.edit_square, size: 16, color: Colors.white),
          ),
      ],
    ),
  );
}

Widget _buildNavButton(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onTap,
  required bool enabled,
}) {
  return GestureDetector(
    onTap: enabled ? onTap : null,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: enabled
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(
          color: enabled
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Icon(
        icon,
        size: 18,
        color: enabled
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade400,
      ),
    ),
  );
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
    return SliverPadding(
      padding: const EdgeInsets.all(8.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: MediaQuery.sizeOf(context).width * 0.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: MediaQuery.sizeOf(context).height * 0.1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
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
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerLowest.withValues(alpha: 0.4),
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
        }, childCount: controller.dashBoardModel.length),
      ),
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
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final imageName = OtherConsts.sliderImages[index];
                  final imageUrl = 'assets/slider/$imageName';

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StoryViewPage(stories: OtherConsts.sliderImages),
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
            SvgPicture.asset('assets/phone.svg', width: 50, height: 50),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help & Customer Support',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
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
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
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
