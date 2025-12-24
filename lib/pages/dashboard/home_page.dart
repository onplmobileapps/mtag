import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/utils/utils.dart';
import '../../features/recharge_center_locator.dart';

import '../../widgets/elevated_button.dart';
import '../../constants/call_helper.dart';
import '../../features/promotion_page.dart';
import '../../features/story_view_page.dart';
import '../../pages/dashboard/model/dashboard_model.dart';
import '../../pages/mtag/controller/delink_controller.dart';
import '../../widgets/balance_widget.dart';
import '../../widgets/bottomsheet/balance_transfer_bs.dart';
import '../../widgets/dashboard_widget.dart';
import '../../widgets/dialog/chassis_num.dart';
import '../../widgets/dialog/delink_dialog.dart';
import '../../api/user_repo.dart';
import '../../constants/other_consts.dart';
import '../../controller/home_controller.dart';
import '../../widgets/shimmer_dashboard.dart';
import '../recharge/controller/recharge_controller.dart';
import '../settings/setting_screen.dart';
import 'model/mtag_model.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Widget> bottomNavigations = [
    const _HomeContent(),
    const PromotionPage(),
    RechargeMapScreen(),
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
            resizeToAvoidBottomInset: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.miniCenterDocked,
            body: bottomNavigations[controller.currentPage.value],
            floatingActionButton: GestureDetector(
              onTap: () async {
                CallWhatsappUtil.openWhatsAppChat();
              },
              child: Image.asset('assets/whatsapp.png', height: 50, width: 50),
            ),
            bottomNavigationBar: _buildBottomNavigationBar(context, controller),
          ),
        );
      },
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
      _NavigationItem(2, 'Recharge Centres', 'assets/location.svg'),
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
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 1,
      initialPage: widget.controller.selectedMtagIndex.value,
    );
    _currentPageNotifier.value = widget.controller.selectedMtagIndex.value;

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
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          expandedHeight: size.height * 0.62,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxHeight: constraints.maxHeight,
                ),
                child: _MtagHeaderSection(
                  controller: widget.controller,
                  pageController: _pageController,
                  currentPageNotifier: _currentPageNotifier,
                ),
              );
            },
          ),
        ),
        _DashboardGridSection(controller: widget.controller),
        _SliderSection(),
        const _HelpSection(),
      ],
    );
  }
}

class _MtagHeaderSection extends StatelessWidget {
  final HomeController controller;
  final PageController pageController;
  final ValueNotifier<int> currentPageNotifier;

  const _MtagHeaderSection({
    required this.controller,
    required this.pageController,
    required this.currentPageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      collapseMode: CollapseMode.none,
      titlePadding: EdgeInsets.zero,
      background: Obx(() {
        final activeMtags = controller.dashboradData.value.activeMtags ?? [];

        if (activeMtags.isEmpty) return const SizedBox(height: 100);

        return _MtagContent(
          activeMtags: activeMtags,
          controller: controller,
          pageController: pageController,
          currentPageNotifier: currentPageNotifier,
        );
      }),
    );
  }
}

class _MtagContent extends StatefulWidget {
  final List<ActiveMtags> activeMtags;
  final HomeController controller;
  final PageController pageController;
  final ValueNotifier<int> currentPageNotifier;

  const _MtagContent({
    required this.activeMtags,
    required this.controller,
    required this.pageController,
    required this.currentPageNotifier,
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
    _currentPage = widget.currentPageNotifier.value;
    widget.pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = widget.pageController.page?.round();
    if (page != null && page != _currentPage) {
      _currentPage = page;
      widget.currentPageNotifier.value = page;
      widget.controller.selectedMtagIndex.value = page;
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
    return ValueListenableBuilder<int>(
      valueListenable: widget.currentPageNotifier,
      builder: (context, currentPageIndex, child) {
        final currentMtag = widget.activeMtags[currentPageIndex];
        final hasblackListMtag = currentMtag.isactive == 8;

        return Column(
          children: [
            AppBar(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.light,
                statusBarColor: Colors.black,
              ),
              backgroundColor: Colors.transparent,
              title: Image.asset(Get.isDarkMode?'assets/darklogo.png': 'assets/logolight.png', height: 80, width: 80),
              centerTitle: true,
            ),
            // Static Header
            _buildHeader(context, currentMtag),
            // Scrollable Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    PageView.builder(
                      key: ValueKey('pageview_${widget.activeMtags.length}'),
                      pageSnapping: false,
                      physics: const PageScrollPhysics(),
                      controller: widget.pageController,
                      itemCount: widget.activeMtags.length,
                      onPageChanged: (index) {
                        _currentPage = index;
                        widget.currentPageNotifier.value = index;
                        widget.controller.selectedMtagIndex.value = index;
                      },
                      itemBuilder: (context, index) {
                        return _buildPageContent(widget.activeMtags[index]);
                      },
                    ),
                    if (widget.activeMtags.length > 1)
                      Positioned.fill(
                        top: hasblackListMtag ? 150 : 70,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildNavigationArrow(
                                icon: Icons.arrow_back_outlined,
                                enabled: currentPageIndex > 0,
                                onTap: () => _goToPage(currentPageIndex - 1),
                              ),
                              const Spacer(),
                              _buildNavigationArrow(
                                icon: Icons.arrow_forward_outlined,
                                enabled:
                                    currentPageIndex <
                                    widget.activeMtags.length - 1,
                                onTap: () => _goToPage(currentPageIndex + 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ActiveMtags mtag) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Column(
              children: [
                if (mtag.isactive == 8)
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/m-tag.svg',
                        height: 13,
                        colorFilter: const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'M-TAG:',
                          style: TextStyle(
                            color: const Color(0xff9E9EAD),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Text(
                              mtag.tokenno ?? '',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'BLACK LISTED',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 4),
                if (mtag.isactive != 8)
                  _MtagDetailRow(
                    icon: 'assets/folder.png',
                    label: 'M-TAG',
                    value: mtag.tokenno,
                  ),
                const SizedBox(height: 4),
                _MtagDetailRow(
                  icon: 'assets/delivery.png',
                  label: 'Vehicle No',
                  value: mtag.registration,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (mtag.isactive == 8)
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(2),
              child: _MtagDetailRow(
                icon: 'assets/card.png',
                label: 'Recovery Amount',
                color: Colors.white,
                value: "Rs. ${mtag.block_amount}",
              ),
            ),
       if(mtag.isactive != 8 &&
              (mtag.chassis_number?.isEmpty ?? false))   InkWell(
            onTap: () => showDialog(context: context, builder: (context)=> ChassisNumberDialog(
              chassissNo: mtag.chassis_number,
              registration: mtag.registration ?? '',
              tokenNo: mtag.tokenno ?? '',
              mobileNumber: _otherConstants.mobile.string,
              balance: mtag.balance ?? '',
              cnicNumber: _otherConstants.ownerCNIC.string,
            )),
            child: SvgPicture.asset(
              'assets/chassis.svg',
              width: 400,
              height: 40,
            ),
          ),
          if (mtag.isactive != 8 &&
              mtag.chassis_number != null &&
              (mtag.chassis_number?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: _MtagDetailRow.chassis(
                chassisNumber: mtag.chassis_number,
                registration: mtag.registration ?? '',
                tokenNo: mtag.tokenno ?? '',
                mobileNumber: _otherConstants.mobile.string,
                balance: mtag.balance ?? '',
                cnicNumber: _otherConstants.ownerCNIC.string,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageContent(ActiveMtags mtag) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Spacer(flex: 1),
        if (mtag.isactive == 8)
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.red.shade300, width: 1.5),
              ),
              child: Text(
                "M-Tag is blacklisted due to pending dues.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        const Spacer(flex: 3),
        Transform.scale(
          scale: MediaQuery.of(context).size.aspectRatio * 5.09,
          child: Image.asset(
            getVehicleImagePath(mtag.vehicletype),
            height: MediaQuery.of(context).size.height * 0.09,
            width: 100,
          ),
        ),
        const Spacer(flex: 3,),
        if (mtag.isactive != 8.0)
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
        const Spacer(),
        mtag.isactive == 8
            ? ElevatedButton1(
                onclick: () {
                  showPaymentBottomSheet(
                    context,
                    blackListRecharge: true,
                    mtagId: mtag.tokenno,
                    regId: mtag.registration,
                    recoveryAmount: mtag.block_amount,
                  );
                },
                text: "Pay Now".toUpperCase(),
                backgroundColor: Colors.redAccent.shade700,
              )
            : _buildActionButtons(mtag),
        const Spacer(),
      ],
    );
  }

  Widget _buildActionButtons(ActiveMtags mtag) {
    final allCars = Get.find<HomeController>().dashboradData.value.activeMtags!
        .where((car) => car.registration != mtag.registration)
        .map(
          (car) => {
            "carNumber": car.registration,
            "balance": double.tryParse(car.balance ?? '0.0') ?? 0.0,
            "mtagID": car.tokenno,
          },
        )
        .toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionButton(
          label: "Transfer",
          icon: 'assets/icons/send.png',
          onTap: () => _showBalanceTransferSheet(mtag, allCars),
        ),
        _ActionButton(
          label: "Recharge",
          icon: 'assets/icons/recharge.png',
          onTap: () => _showRechargeBottomSheet(mtag),
        ),
        _ActionButton(
          label: "Delete",
          icon: 'assets/icons/delete.png',
          onTap: () => _showDeleteDialog(mtag),
        ),
      ],
    );
  }

  void _showBalanceTransferSheet(
    ActiveMtags mtag,
    List<Map<String, dynamic>> allCars,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BalanceTransferSheet(
          carRegistration: mtag.registration,
          balance: mtag.balance,
          cnicNumber: _otherConstants.ownerCNIC.value,
          mobileNumber: mtag.mobilenum,
          mtagid: mtag.tokenno,
          dropDownCars: allCars,
        );
      },
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
        child: Container(
          margin: const EdgeInsets.all(8),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: Icon(icon, size: 18),
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
  final Color? color;

  const _MtagDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isChassis = false,
    this.onTap,
    this.color,
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
              chassissNo: chassisNumber,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(icon, width: 25, height: 25),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                color: color ?? const Color(0xff9E9EAD),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'N/A',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.w600,
                overflow: .ellipsis,
              ),
            ),
          ),
          if (isChassis)
            GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.edit_square, size: 22),
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
Widget actionBtn(
  BuildContext context, {
  required String label,
  required String icon,

  required double fontSize,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(backgroundColor: Get.isDarkMode?Colors.white: ColorScheme.of(context).surfaceContainerLowest,
            child: Image.asset(icon, height: 30, width: 30)),
          SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColorLight,
            ),
          ),
        ],
      ),
    ),
  );
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
          maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: MediaQuery.of(context).size.height * 0.1,
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
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            if (item.image != null) _buildImage(context),
            const SizedBox(width: 8),
            Expanded(child: _buildTitle(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        item.image ?? '',
        width: MediaQuery.of(context).size.width * 0.1,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      item.title ?? '',
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyLarge,
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

  static final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

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
            Column(
              children: [
                SizedBox(
                  height: 150,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        const itemWidth = 158;
                        final index = (notification.metrics.pixels / itemWidth)
                            .round();
                        if (index >= 0 &&
                            index < OtherConsts.sliderImages.length) {
                          // Only update if index actually changed
                          if (_currentIndex.value != index) {
                            _currentIndex.value = index;
                          }
                        }
                      }
                      return false;
                    },
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: OtherConsts.sliderImages.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return _SliderItem(imageIndex: index);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, currentIndex, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(OtherConsts.sliderImages.length, (
                        index,
                      ) {
                        return Container(
                          decoration: BoxDecoration(
                            color: currentIndex == index
                                ? Colors.black
                                : Colors.grey,
                            borderRadius: .circular(8),
                          ),
                          height: 8,
                          width: currentIndex == index ? 25 : 8,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                        );
                      }),
                    );
                  },
                ),
              ],
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
        MaterialPageRoute(builder: (_) => StoryViewPage(stories: [imageUrl])),
      ),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).highlightColor),
          image: DecorationImage(image: AssetImage(imageUrl), fit: BoxFit.fill),
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
            Image.asset('assets/help.png', width: 50, height: 50),
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
                  Row(
                    children: [
                      Expanded(
                        child: _buildCallButton(
                          onTap: CallWhatsappUtil.openCall1313,
                          text: '1313',
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildCallButton(
                          onTap: () => CallWhatsappUtil.openWhatsAppChat(),
                          text: 'WhatsApp',
                          icon: Image.asset(
                            'assets/whatsapp.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({String? text, Widget? icon, VoidCallback? onTap}) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon!,
      label: Text(
        text ?? '',
        style: TextStyle(
          color: text == 'WhatsApp' ? Colors.green : Colors.redAccent,
          fontSize: 12,
        ),
      ),
      iconAlignment: IconAlignment.end,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(double.infinity, 35),
        maximumSize: const Size(double.infinity, 35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        side: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}
