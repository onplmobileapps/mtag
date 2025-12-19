import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

// Import your existing files...
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
import 'model/mtag_model.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Widget> bottomNavigations = [
    const _HomeContent(),
    const PromotionPage(),
    const NotificationScreen(),
    SettingScreen(),
  ];

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
            body: bottomNavigations[controller.currentPage.value],
            floatingActionButton: _buildFloatingButton(context),
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
      child: Container(
        height: 60,
        width: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF00296B), Color(0xFF8A2E87)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
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
        children: _buildNavigationItems(context, controller),
      ),
    );
  }

  List<Widget> _buildNavigationItems(
    BuildContext context,
    HomeController controller,
  ) {
    const navigationItems = [
      _NavigationItem(0, 'Home', 'assets/house-blank.svg'),
      _NavigationItem(1, 'Promotions', 'assets/promotion.svg'),
      _NavigationItem(2, 'Notifications', 'assets/allert.svg'),
      _NavigationItem(3, 'Profile', 'assets/user.svg'),
    ];

    return navigationItems.map((item) {
      return _NavigationButton(
        index: item.index,
        label: item.label,
        iconPath: item.iconPath,
        currentPage: controller.currentPage.value,
        onTap: () => _handleNavigationTap(controller, item.index),
      );
    }).toList();
  }

  void _handleNavigationTap(HomeController controller, int index) {
    final otherConstants = OtherConsts();
    if (controller.currentPage.value == 0 &&
        index == 0 &&
        otherConstants.isRefresh.value) {
      controller.pullRefreshDashboardData();
    }
    controller.setCurrentIndex(index);
  }
}

class _NavigationItem {
  final int index;
  final String label;
  final String iconPath;

  const _NavigationItem(this.index, this.label, this.iconPath);
}

class _NavigationButton extends StatelessWidget {
  final int index;
  final String label;
  final String iconPath;
  final int currentPage;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.index,
    required this.label,
    required this.iconPath,
    required this.currentPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentPage;
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
            iconPath,
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
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
      builder: (controller) {
        if (controller.isLoading.value) {
          final size = MediaQuery.sizeOf(context);
          return buildShimmerEffect(size.width, size.height);
        }

        return _HomeContentBody(controller: controller);
      },
    );
  }
}

class _HomeContentBody extends StatefulWidget {
  final HomeController controller;

  const _HomeContentBody({required this.controller});

  @override
  State<_HomeContentBody> createState() => _HomeContentBodyState();
}

class _HomeContentBodyState extends State<_HomeContentBody> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeMtags =
          widget.controller.dashboradData.value.activeMtags ?? [];
      if (activeMtags.isNotEmpty) {
        widget.controller.selectedMtagIndex.value = 0;
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          expandedHeight: size.height * 0.55,
          flexibleSpace: _MtagHeaderSection(
            controller: widget.controller,
            pageController: _pageController,
          ),
        ),
        _DashboardGridSection(controller: widget.controller),
        const _SliderSection(),
        const _HelpSection(),
      ],
    );
  }
}

class _MtagHeaderSection extends StatelessWidget {
  final HomeController controller;
  final PageController pageController;

  const _MtagHeaderSection({
    required this.controller,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      titlePadding: EdgeInsets.zero,
      background: Obx(() {
        final activeMtags = controller.dashboradData.value.activeMtags ?? [];
        if (activeMtags.isEmpty) return const SizedBox();

        return _MtagContent(
          activeMtags: activeMtags,
          controller: controller,
          pageController: pageController,
        );
      }),
    );
  }
}

class _MtagContent extends StatefulWidget {
  final List<ActiveMtags> activeMtags;
  final HomeController controller;
  final PageController pageController;

  const _MtagContent({
    required this.activeMtags,
    required this.controller,
    required this.pageController,
  });

  @override
  State<_MtagContent> createState() => _MtagContentState();
}

class _MtagContentState extends State<_MtagContent> {
  late final OtherConsts _otherConstants = OtherConsts();
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.controller.selectedMtagIndex.value;
    widget.pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = widget.pageController.page?.round();
    if (page != null && page != _currentPage) {
      _currentPage = page;
      widget.controller.selectedMtagIndex.value = page;
      setState(() {});
    }
  }

  void _goToPage(int page) {
    final newPage = page.clamp(0, widget.activeMtags.length - 1);
    widget.pageController.animateToPage(
      newPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMtag = widget.activeMtags[_currentPage];

    return Column(
      children: [
        // Static Header
        _buildHeader(context, currentMtag),
        // Scrollable Content
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: ColorScheme.of(
                context,
              ).surfaceContainerLowest.withAlpha(102),
            ),
            child: Stack(
              children: [
                PageView.builder(
                  controller: widget.pageController,
                  itemCount: widget.activeMtags.length,
                  onPageChanged: (index) {
                    _currentPage = index;
                    widget.controller.selectedMtagIndex.value = index;
                  },
                  itemBuilder: (context, index) {
                    return _buildPageContent(widget.activeMtags[index]);
                  },
                ),
                if (widget.activeMtags.length > 1)
                  Positioned.fill(
                    top: -100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavigationArrow(
                          icon: Icons.arrow_back_ios_rounded,
                          enabled: _currentPage > 0,
                          onTap: () => _goToPage(_currentPage - 1),
                        ),
                        _buildNavigationArrow(
                          icon: Icons.arrow_forward_ios_rounded,
                          enabled: _currentPage < widget.activeMtags.length - 1,
                          onTap: () => _goToPage(_currentPage + 1),
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

  Widget _buildHeader(BuildContext context, ActiveMtags mtag) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: .circular(28),
          bottomRight: .circular(28),
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
          _MtagDetailRow(
            icon: 'assets/folder.png',
            label: 'M-TAG',
            value: mtag.tokenno,
          ),
          _MtagDetailRow(
            icon: 'assets/delivery.png',
            label: 'Vehicle No',
            value: mtag.registration,
          ),
          _MtagDetailRow.chassis(
            chassisNumber: mtag.chassis_number,
            registration: mtag.registration ?? '',
            tokenNo: mtag.tokenno ?? '',
            mobileNumber: _otherConstants.mobile.string,
            balance: mtag.balance ?? '',
            cnicNumber: _otherConstants.ownerCNIC.string,
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(ActiveMtags mtag) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(),
        Image.asset('assets/car2.png',height: 100,width: 100,),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Balance",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade700),
            ),
            BalanceWidget(
              balance: mtag.balance ?? '',
              fontSize: 34,
              iconSize: 24,
            ),
          ],
        ),
       
        _buildActionButtons(mtag),
      ],
    );
  }

  Widget _buildActionButtons(ActiveMtags mtag) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          label: "Transfer",
          icon: 'assets/send.png',
          onTap: () => _showBalanceTransferSheet(mtag),
        ),
        _ActionButton(
          label: "Recharge",
          icon: 'assets/plus1.png',
          onTap: () => _showRechargeBottomSheet(mtag),
        ),
        _ActionButton(
          label: "Delete",
          icon: 'assets/delete.png',
          onTap: () => _showDeleteDialog(mtag),
        ),
      ],
    );
  }

  void _showBalanceTransferSheet(ActiveMtags mtag) {
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
  }

  void _showRechargeBottomSheet(ActiveMtags mtag) {
    showPaymentBottomSheet(
      context,
      mtagId: mtag.tokenno,
      regId: mtag.registration,
      jazzCode: '1',
      creditCode: '0',
      blackListRecharge: false,
    );
  }

  void _showDeleteDialog(ActiveMtags mtag) {
    Get.dialog(
      DeLinkVehicleDialog(
        regId: mtag.registration ?? '',
        onCancel: Get.back,
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

  Widget _buildNavigationArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.3,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(margin: .all(4),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? Theme.of(context).colorScheme.primary.withAlpha(26)
                : Colors.grey.shade300,
            shape: BoxShape.circle,
            border: Border.all(
              color: enabled
                  ? Theme.of(context).colorScheme.primary.withAlpha(77)
                  : Colors.grey.shade300,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            
          ),
        ),
      ),
    );
  }
}

class _MtagDetailRow extends StatelessWidget {
  final String icon;
  final String label;
  final String? value;
  final bool isChassis;
  final VoidCallback? onTap;

  const _MtagDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isChassis = false,
    this.onTap,
  });

  factory _MtagDetailRow.chassis({
    required String? chassisNumber,
    required String registration,
    required String tokenNo,
    required String mobileNumber,
    required String balance,
    required String cnicNumber,
  }) {
    return _MtagDetailRow(
      icon: 'assets/document.png',
      label: 'Chassis No',
      value: chassisNumber,
      isChassis: true,
      onTap: () async {
        final context = Get.context;
        if (context != null) {
          await showDialog(
            context: context,
            builder: (_) => ChassisNumberDialog(
              registration: registration,
              tokenNo: tokenNo,
              mobileNumber: mobileNumber,
              balance: balance,
              cnicNumber: cnicNumber,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Image.asset(icon,width: 25,height: 25),
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
              child: const Icon(
                Icons.edit_square,
                size: 16,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return actionBtn(
      context,
      label: label,
      icon: icon,
      fontSize: 12,

      onTap: onTap,
    );
  }
}

class _DashboardGridSection extends StatelessWidget {
  final HomeController controller;

  const _DashboardGridSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(8),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: MediaQuery.sizeOf(context).width * 0.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: MediaQuery.sizeOf(context).height * 0.1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = controller.dashBoardModel[index];
          return _DashboardGridItem(item: item, controller: controller);
        }, childCount: controller.dashBoardModel.length),
      ),
    );
  }
}

class _DashboardGridItem extends StatelessWidget {
  final MtagModel item;
  final HomeController controller;

  const _DashboardGridItem({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleItemTap(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerLowest.withAlpha(102),
        ),
        child: Row(
          children: [
            if (item.image != null) _buildImage(context),
            const SizedBox(width: 8),
            Expanded(child: _buildTitle()),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        item.image!,
        width: MediaQuery.sizeOf(context).width * 0.1,
        height: MediaQuery.sizeOf(context).height * 0.1,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      item.title ?? '',
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w600),
      maxLines: 2,
    );
  }

  Future<void> _handleItemTap(BuildContext context) async {
    final rechargeController = Get.find<RechargeController>();

    if (item.routeName != null) {
      await Get.toNamed(
        item.routeName!,
        arguments: controller.dashboradData.value.activeMtags,
      );
    }

    // Reset recharge controller states
    rechargeController.isPaymentModdeVisible(false);
    rechargeController.isSummaryVisible(false);
    rechargeController.isRechageVisible(true);
  }
}

class _SliderSection extends StatelessWidget {
  const _SliderSection();

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
                  return _SliderItem(imageIndex: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderItem extends StatelessWidget {
  final int imageIndex;

  const _SliderItem({required this.imageIndex});

  @override
  Widget build(BuildContext context) {
    final imageName = OtherConsts.sliderImages[imageIndex];
    final imageUrl = 'assets/slider/$imageName';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StoryViewPage(stories: OtherConsts.sliderImages),
        ),
      ),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).highlightColor),
          image: DecorationImage(
            image: AssetImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection();

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
                  _buildCallButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    return OutlinedButton.icon(
      onPressed: CallWhatsappUtil.openCall1313,
      icon: const Icon(Icons.arrow_forward, size: 14, color: Colors.redAccent),
      label: const Text(
        '1313',
        style: TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
      iconAlignment: IconAlignment.end,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(70, 28),
        maximumSize: const Size(70, 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
