import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/pages/tolcalator/toll_calculator_cities.dart';
import '../../widgets/search_stations_dialog.dart';
import 'controller/toll_calculator_static_controller.dart';

class TollCalculatorLocalTabs extends StatefulWidget {
  const TollCalculatorLocalTabs({super.key});

  static const String title = 'Toll Calculator';

  @override
  State<TollCalculatorLocalTabs> createState() => _TollCalculatorLocalState();
}

class _TollCalculatorLocalState extends State<TollCalculatorLocalTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(TollCalculatorLocalTabs.title)),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                TollPlazaTab(
                  animationController: _animationController,
                  fadeAnimation: _fadeAnimation,
                ),
                CitiesTab(
                  animationController: _animationController,
                  fadeAnimation: _fadeAnimation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDarkMode ? Colors.redAccent : Theme.of(context).primaryColor;

    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withAlpha(28),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.circular(25),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDarkMode ? Colors.grey[400] : borderColor,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashBorderRadius: BorderRadius.circular(25),
        dividerColor: Colors.transparent,
        tabs:  [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Calculate Toll by Plazas',style: Theme.of(context).tabBarTheme.labelStyle,),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('Calculate Toll by Cities',style: Theme.of(context).tabBarTheme.labelStyle,),
            ),
          ),
        ],
      ),
    );
  }
}

class TollPlazaTab extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  const TollPlazaTab({
    super.key,
    required this.animationController,
    required this.fadeAnimation,
  });

  @override
  State<TollPlazaTab> createState() => _TollPlazaTabState();
}

class _TollPlazaTabState extends State<TollPlazaTab> {
  final controller = Get.find<MotorwayStaticController>();
  final _scrollController = ScrollController();
  int _selectedMotorway = -1;
  int _selectedVehicle = -1;
  String? _entryStation;
  String? _exitStation;
  String? _calculatedToll = '0';
  bool _showToll = false;
  bool _isCalculating = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _calculateToll() async {
    if (_selectedMotorway == -1) {
      _showSnackBar('Please select a motorway first');
      return;
    }
    if (_entryStation == null || _exitStation == null) {
      _showSnackBar('Please select both entry and exit stations');
      return;
    }
    if (_entryStation == _exitStation) {
      _showSnackBar('Entry and exit stations must be different');
      return;
    }
    if (_selectedVehicle == -1) {
      _showSnackBar('Please select a vehicle type');
      return;
    }

    setState(() => _isCalculating = true);
    try {
      final entryId = controller.fullStationsList
          .firstWhere((s) => s.stname == _entryStation)
          .stid;
      final exitId = controller.fullStationsList
          .firstWhere((s) => s.stname == _exitStation)
          .stid;

      if (entryId == null || exitId == null) {
        throw Exception('Station ID not found');
      }

      final result = await controller.calculateToll(
        entry: entryId,
        exit: exitId,
        type: controller.vehicleList[_selectedVehicle].id.toString(),
      );

      if (result['Code'] == '00' && result['Data'] != null) {
        widget.animationController.reset();
        setState(() {
          _calculatedToll = result['Data']['toll'];
          _showToll = true;
        });
        widget.animationController.forward();
        _scrollToBottom();
      } else {
        _showSnackBar(result['Message'] ?? 'Failed to calculate toll');
      }
    } catch (e) {
      _showSnackBar('Calculation failed: ${e.toString()}');
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showStationSelectionDialog(bool isEntry) async {
    if (_selectedMotorway == -1) {
      _showSnackBar('Please select a motorway first');
      return;
    }
    if (controller.stations.isEmpty) {
      _showSnackBar('No stations available');
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (_) => StationSearchDialog(
        items: controller.stations,
        selectedItem: isEntry ? _entryStation : _exitStation,
        title: isEntry ? 'Select Entry Station' : 'Select Exit Station',
        hintText: 'Search Station',
        leadingIcon: Icons.location_on,
        trailingIconBuilder: (item) =>
            item == (isEntry ? _entryStation : _exitStation)
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  )
                : null,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isEntry) {
          _entryStation = selected;
          if (_exitStation == _entryStation) {
            _exitStation = null;
            _showSnackBar('Exit station reset: Select a different station');
          }
        } else {
          if (selected == _entryStation) {
            _showSnackBar('Exit station must be different from entry');
            return;
          }
          _exitStation = selected;
        }
        _selectedVehicle = -1;
        _showToll = false;
      });

      if (isEntry && _exitStation == null) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _showStationSelectionDialog(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isLargeScreen = constraints.maxWidth > 600;
      final padding = isLargeScreen ? 18.0 : 10.0;
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: 800, minHeight: constraints.maxHeight),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildSection(_buildMotorwaySelector(isLargeScreen), context),
              const SizedBox(height: 12),
              _buildSection(_buildStationSelector(padding), context),
              const SizedBox(height: 12),
              _buildSection(_buildVehicleSelector(isLargeScreen), context),
              if (_showToll) ...[
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: widget.fadeAnimation,
                  child: _buildSection(
                    TollDisplay(
                      padding: padding,
                      isCalculating: _isCalculating,
                      entry: _entryStation,
                      exit: _exitStation,
                      vehicleName: _selectedVehicle != -1
                          ? controller.vehicleList[_selectedVehicle].name
                          : null,
                      toll: _calculatedToll,
                    ),
                    context,
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSection(Widget child, BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).disabledColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: child,
      );

  Widget _buildMotorwaySelector(bool isLargeScreen) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          children: [
           Text('Select Motorway', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: isLargeScreen ? 120 : 110,
              child: ListView.builder(padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: controller.mwNameList.length,
                itemBuilder: (context, index) =>
                    _buildMotorwayItem(index, isLargeScreen),
              ),
            ),
                const SizedBox(height: 12),
          ],
        ),
      );

  Widget _buildMotorwayItem(int index, bool isLargeScreen) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDarkMode ? Colors.redAccent : Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(
          () {
            controller
                .fetchStations(controller.mwNameList[index].motorwayID ?? 0);
            _selectedMotorway = index;
            _selectedVehicle = -1;
            _showToll = false;
            _entryStation = _exitStation = null;
          },
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isLargeScreen ? 150 : 120,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color:
                  _selectedMotorway == index ? borderColor : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _selectedMotorway == index
                ? [
                    BoxShadow(
                        color: borderColor.withValues(alpha: 20),
                        blurRadius: 0,
                        spreadRadius: 0)
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/line.svg',
                height: isLargeScreen ? 45 : 35,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).primaryColor, BlendMode.srcIn),
              ),
              Text(
                controller.mwNameList[index].motorwayAbbrivation!,
                style: TextStyle(
                    fontSize: isLargeScreen ? 14 : 12,
                    color: Theme.of(context).primaryColor),
              ),
              Text(
                controller.mwNameList[index].motorwayName!,
                style: TextStyle(
                    fontSize: isLargeScreen ? 20 : 18,
                    color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildStationSelector(double padding) => Card(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Select InterChange', style: Theme.of(context).textTheme.labelLarge)),
            const SizedBox(height: 10),
            _buildDropdownField(
              icon: Icon( Icons.location_on_outlined,color: Colors.green,),
              label: 'Entry Station',
              value: _entryStation,
              hint: 'Enter starting point',
              onTap: () => _showStationSelectionDialog(true),
            ),
            if (_entryStation != null) ...[
              const SizedBox(height: 10),
              _buildDropdownField(
                icon: Icon(Icons.location_on,color: Colors.redAccent,),
                label: 'Exit Station',
                value: _exitStation,
                hint: 'Enter destination',
                onTap: () => _showStationSelectionDialog(false),
              ),
            ],
          ],
        ),
      ),
    );

Widget _buildDropdownField({
  required Widget icon,
  required String label,
  required String? value,
  required String hint,
  required VoidCallback onTap,
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final borderColor =
      value == null ? Colors.grey : Theme.of(context).primaryColor;
  final textColor = value != null
      ? (isDarkMode ? Colors.white : Theme.of(context).primaryColor)
      : Colors.grey[600];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      const SizedBox(height: 6),
      InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
            icon,
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value ?? hint,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: textColor),
            ],
          ),
        ),
      ),
    ],
  );
}


  Widget _buildVehicleSelector(bool isLargeScreen) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Column(
          children: [
             Text('Select Vehicle Type', style:Theme.of(context).textTheme.labelLarge ),
            const SizedBox(height: 12),
            SizedBox(
              height: isLargeScreen ? 160 : 120,
              child: ListView.builder(padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: controller.vehicleList.length,
                itemBuilder: (context, index) =>
                    _buildVehicleItem(index, isLargeScreen),
              ),
            ),
            SizedBox(height: 10,)
          ],
        ),
      );

  Widget _buildVehicleItem(int index, bool isLargeScreen) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDarkMode ? Colors.redAccent : Theme.of(context).primaryColor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (_selectedMotorway == -1) {
            _showSnackBar('Please select a motorway first');
            return;
          }
          if (_entryStation == null || _exitStation == null) {
            _showSnackBar('Please select entry and exit stations first');
            return;
          }
          setState(() => _selectedVehicle = index);
          _calculateToll();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isLargeScreen ? 160 : 120,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color:
                  _selectedVehicle == index ? borderColor : Colors.transparent,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _selectedVehicle == index
                ? [
                    BoxShadow(
                        color: borderColor.withValues(alpha: 20),
                        blurRadius: 0,
                        spreadRadius: 0)
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  controller.vehicleList[index].image!,
                  height: isLargeScreen ? 48 : 40,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor, BlendMode.srcIn),
                ),
              ),
              Text(
                controller.vehicleList[index].name!,
                style: TextStyle(
                    fontSize: isLargeScreen ? 18 : 16,
                    color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
