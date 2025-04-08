import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'controller/toll_calculator_static_controller.dart';
import 'model/stations_model.dart';

class TollCalculatorLocal extends StatefulWidget {
  const TollCalculatorLocal({super.key});
  static const String title = 'Toll Calculator';

  @override
  State<TollCalculatorLocal> createState() => _TollCalculatorLocalState();
}

class _TollCalculatorLocalState extends State<TollCalculatorLocal> {
  final controller = Get.find<MotorwayStaticController>();
  final _scrollController = ScrollController();
  int _selectedMotorway = -1, _selectedVehicle = -1;
  String? _entryStation, _exitStation, _calculatedToll = '0';
  bool _showToll = false, _isCalculating = false;

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
    if (_entryStation == null || _exitStation == null || _selectedVehicle == -1) {
      _showSnackBar('Please select all required fields');
      return;
    }

    setState(() => _isCalculating = true);
    try {
      final entryId = controller.fullStationsList.firstWhere((s) => s.stname == _entryStation).stid;
      final exitId = controller.fullStationsList.firstWhere((s) => s.stname == _exitStation).stid;
      if (entryId == null || exitId == null) throw Exception('Station ID not found');

      final result = await controller.calculateToll(
        entry: entryId,
        exit: exitId,
        type: controller.vehicleList[_selectedVehicle].id.toString(),
      );

      if (result['Code'] == '00' && result['Data'] != null) {
        setState(() {
          _calculatedToll = result['Data']['toll'];
          _showToll = true;
        });
        _scrollToBottom();
      } else {
        _showSnackBar(result['Message'] ?? 'Failed to calculate toll');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  void _showSnackBar(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(TollCalculatorLocal.title)),
      body: LayoutBuilder(builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final padding = isLargeScreen ? 24.0 : 16.0;
        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 24 : 8),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800, minHeight: constraints.maxHeight),
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
                  _buildSection(_buildTollDisplay(padding), context),
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
              itemBuilder: (context, index) => _buildMotorwayItem(index, isLargeScreen),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildMotorwayItem(int index, bool isLargeScreen) => Padding(
    padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() {
        controller.fetchStations(controller.mwNameList[index].motorwayID!);
        _selectedMotorway = index;
        _selectedVehicle = -1;
        _showToll = false;
        _entryStation = _exitStation = null;
      }),
      child: Container(
        width: isLargeScreen ? 160 : 120,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _selectedMotorway == index ? Theme.of(context).primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/line.svg', height: isLargeScreen ? 48 : 40, color: Theme.of(context).primaryColor),
            Text(controller.mwNameList[index].motorwayAbbrivation!, style: TextStyle(fontSize: isLargeScreen ? 14 : 12,color: Theme.of(context).primaryColor)),
            Text(controller.mwNameList[index].motorwayName!, style: TextStyle(fontSize: isLargeScreen ? 20 : 18,color: Theme.of(context).primaryColor)),
          ],
        ),
      ),
    ),
  );

  Widget _buildStationSelector(double padding) => Card(
    elevation: 0,
    color: Colors.transparent,
    child: Padding(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          const Text('Select Interchange', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          _buildDropdown('From', _entryStation, (value) => setState(() {
            _entryStation = value;
            _showToll = false;
          })),
          const SizedBox(height: 16),
          _buildDropdown('To', _exitStation, (value) {
            if (value == _entryStation) {
              _showSnackBar('Please select a different exit station');
              return;
            }
            setState(() {
              _exitStation = value;
              _showToll = false;
            });
          }),
        ],
      ),
    ),
  );

  Widget _buildDropdown(String label, String? value, ValueChanged<String?> onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 6),
      InkWell(
        onTap: () async {
          if (controller.stations.isEmpty) {
            _showSnackBar('No stations found');
            return;
          }
          final selected = await showDialog<String>(
            context: context,
            builder: (_) => _StationSearchDialog(
              stations: controller.stations,
              selectedStation: value,
              title: 'Select $label Station',
            ),
          );
          if (selected != null) onChanged(selected);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
          child: Row(children: [Expanded(child: Text(value ?? 'Select $label Station')), const Icon(Icons.arrow_drop_down_circle_outlined)]),
        ),
      ),
    ],
  );

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
              itemBuilder: (context, index) => _buildVehicleItem(index, isLargeScreen),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildVehicleItem(int index, bool isLargeScreen) => Padding(
    padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 8 : 6),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (_entryStation == null || _exitStation == null) {
          _showSnackBar('Please select entry and exit stations first');
          return;
        }
        setState(() => _selectedVehicle = index);
        _calculateToll();
      },
      child: Container(
        width: isLargeScreen ? 160 : 120,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: _selectedVehicle == index ? Theme.of(context).primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(controller.vehicleList[index].image!, height: isLargeScreen ? 48 : 40, color: Theme.of(context).primaryColor),
            Text(controller.vehicleList[index].name!, style: TextStyle(fontSize: isLargeScreen ? 18 : 16,color: Theme.of(context).primaryColor)),
          ],
        ),
      ),
    ),
  );

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
          _buildDetailRow('Vehicle', controller.vehicleList[_selectedVehicle].name ?? 'Unknown'),
          const Divider(height: 24),
          _isCalculating
              ? const CircularProgressIndicator()
              : _buildDetailRow('Total Toll', '$_calculatedToll PKR', isTotal: true),
        ],
      ),
    ),
  );

  Widget _buildDetailRow(String label, String? value, {bool isTotal = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.redAccent)),
        Text(value ?? 'N/A',
            style: TextStyle(
                fontSize: isTotal ? 18 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color:  Colors.green)),
      ],
    ),
  );
}

class _StationSearchDialog extends StatefulWidget {
  final RxList<String> stations;
  final String? selectedStation;
  final String title;

  const _StationSearchDialog({required this.stations, this.selectedStation, required this.title});

  @override
  State<_StationSearchDialog> createState() => _StationSearchDialogState();
}

class _StationSearchDialogState extends State<_StationSearchDialog> {
  late List<String> _filteredStations;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStations = widget.stations;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStations(String query) => setState(() {
    _filteredStations = widget.stations.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList();
  });

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7, maxWidth: 500),
      child: Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterStations,
              cursorColor: Theme.of(context).primaryColor, // Cursor color
              style: TextStyle(color: Theme.of(context).primaryColor), // Text color
              decoration: InputDecoration(
                hintText: 'Search Station',
                hintStyle: TextStyle(color: Theme.of(context).primaryColor,fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
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
                  title: Text(station,style: TextStyle(color: Theme.of(context).primaryColor),),
                  leading: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                  trailing: widget.selectedStation == station ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                  onTap: () => Navigator.pop(context, station),
                );
              },
            ),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      )),
    ),
  );
}