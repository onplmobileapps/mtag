import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mtag_flutterapp/constants/other_consts.dart';
import 'controller/toll_calculator_static_controller.dart';

class TollCalculatorLocal extends StatefulWidget {
  const TollCalculatorLocal({super.key});

  static const String title = 'Toll Calculator';

  @override
  State<TollCalculatorLocal> createState() => _TollCalculatorLocalState();
}

class _TollCalculatorLocalState extends State<TollCalculatorLocal>
    with SingleTickerProviderStateMixin {
  final controller = Get.find<MotorwayStaticController>();
  final _scrollController = ScrollController();
  int _selectedMotorway = -1, _selectedVehicle = -1;
  String? _entryStation, _exitStation, _calculatedToll = '0';
  bool _showToll = false, _isCalculating = false;
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
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
log(result.toString());
      if (result['Code'] == '00' && result['Data'] != null) {
        _animationController.reset();
        setState(() {
          _calculatedToll = result['Data']['toll'];
          _showToll = true;
        });
        _animationController.forward();
        _scrollToBottom();
      } else {
        _showSnackBar("${result['Message'] ?? 'Failed to calculate toll'}");
      }
    } catch (e) {
      _showSnackBar('Calculation failed: ${OtherConsts.exception}');
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
      _showSnackBar('No stations available for this motorway');
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (_) => _StationSearchDialog(
        stations: controller.stations,
        selectedStation: isEntry ? _entryStation : _exitStation,
        title: isEntry ? 'Select Entry Station' : 'Select Exit Station',
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
    return Scaffold(
      appBar: AppBar(title: const Text(TollCalculatorLocal.title)),
      body: LayoutBuilder(builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final padding = isLargeScreen ? 24.0 : 16.0;
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
                    opacity: _fadeAnimation,
                    child: _buildSection(_buildTollDisplay(padding), context),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text('Select Motorway', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: isLargeScreen ? 160 : 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.mwNameList.length,
                  itemBuilder: (context, index) =>
                      _buildMotorwayItem(index, isLargeScreen),
                ),
              ),
            ],
          ),
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
            controller.fetchStations(controller.mwNameList[index].motorwayID!);
            _selectedMotorway = index;
            _selectedVehicle = -1;
            _showToll = false;
            _entryStation = _exitStation = null;
          },
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isLargeScreen ? 160 : 120,
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
                height: isLargeScreen ? 48 : 40,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).primaryColor, BlendMode.srcIn),
              ),
              Text(controller.mwNameList[index].motorwayAbbrivation!,
                  style: TextStyle(
                      fontSize: isLargeScreen ? 14 : 12,
                      color: Theme.of(context).primaryColor)),
              Text(controller.mwNameList[index].motorwayName!,
                  style: TextStyle(
                      fontSize: isLargeScreen ? 20 : 18,
                      color: Theme.of(context).primaryColor)),
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
            children: [
              const Text('Select Interchange', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              _buildDropdown('Select Entry Station', _entryStation,
                  () => _showStationSelectionDialog(true)),
              const SizedBox(height: 16),
              _buildDropdown('Select Exit Station', _exitStation,
                  () => _showStationSelectionDialog(false)),
            ],
          ),
        ),
      );

  Widget _buildDropdown(String label, String? value, VoidCallback onTap) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDarkMode ? Colors.redAccent : Theme.of(context).primaryColor;
    final textColor = value != null
        ? (isDarkMode ? Colors.white : Theme.of(context).primaryColor)
        : Colors.grey[600];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border:
                  Border.all(color: value == null ? Colors.grey : borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? label,
                    style: TextStyle(color: textColor),
                  ),
                ),
                Icon(Icons.arrow_drop_down_circle_outlined,
                    color: isDarkMode
                        ? Colors.grey
                        : Theme.of(context).primaryColor),
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Text('Select Vehicle Type', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: isLargeScreen ? 160 : 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.vehicleList.length,
                  itemBuilder: (context, index) =>
                      _buildVehicleItem(index, isLargeScreen),
                ),
              ),
            ],
          ),
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
              SvgPicture.asset(
                controller.vehicleList[index].image!,
                height: isLargeScreen ? 48 : 40,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).primaryColor, BlendMode.srcIn),
              ),
              Text(controller.vehicleList[index].name!,
                  style: TextStyle(
                      fontSize: isLargeScreen ? 18 : 16,
                      color: Theme.of(context).primaryColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTollDisplay(double padding) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              const Text('Toll Details', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              _buildDetailRow('Route', '$_entryStation - $_exitStation'),
              _buildDetailRow('Vehicle',
                  controller.vehicleList[_selectedVehicle].name ?? 'Unknown'),
              const Divider(height: 24),
              _isCalculating
                  ? const CircularProgressIndicator()
                  : _buildDetailRow('Total Toll', '$_calculatedToll PKR',
                      isTotal: true),
            ],
          ),
        ),
      );

  Widget _buildDetailRow(String label, String? value, {bool isTotal = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.redAccent)),
            Text(value ?? 'N/A',
                style: TextStyle(
                    fontSize: isTotal ? 18 : 14,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    color: Colors.green)),
          ],
        ),
      );
}

class _StationSearchDialog extends StatefulWidget {
  final RxList<String> stations;
  final String? selectedStation;
  final String title;

  const _StationSearchDialog(
      {required this.stations, this.selectedStation, required this.title});

  @override
  State<_StationSearchDialog> createState() => _StationSearchDialogState();
}

class _StationSearchDialogState extends State<_StationSearchDialog> {
  late List<String> _filteredStations;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MotorwayStaticController>()) {
      Get.put(MotorwayStaticController);
    }
    _filteredStations = widget.stations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStations(String query) => setState(() {
        _filteredStations = widget.stations
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDarkMode ? Colors.redAccent : Theme.of(context).primaryColor;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, maxWidth: 500),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(widget.title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterStations,
                  cursorColor: borderColor,
                  style: TextStyle(color: borderColor),
                  decoration: InputDecoration(
                    hintText: 'Search Station',
                    hintStyle: TextStyle(color: borderColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: borderColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: borderColor),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredStations.length,
                  itemBuilder: (_, index) {
                    final station = _filteredStations[index];
                    return ListTile(
                      title: Text(station,
                          style: TextStyle(
                              color: isDarkMode
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor)),
                      leading: Icon(Icons.location_on,
                          color: isDarkMode
                              ? Colors.grey
                              : Theme.of(context).primaryColor),
                      trailing: widget.selectedStation == station
                          ? Icon(Icons.check,
                              color: isDarkMode
                                  ? Colors.grey
                                  : Theme.of(context).primaryColor)
                          : null,
                      onTap: () => Navigator.pop(context, station),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: borderColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
