import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../widgets/search_stations_dialog.dart';
import 'controller/toll_calculator_static_controller.dart';

class CitiesTab extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> fadeAnimation;

  const CitiesTab({
    super.key,
    required this.animationController,
    required this.fadeAnimation,
  });

  @override
  State<CitiesTab> createState() => _CitiesTabState();
}

class _CitiesTabState extends State<CitiesTab> {
  final controller = Get.find<MotorwayStaticController>();
  final _scrollController = ScrollController();
  int _selectedVehicle = -1;
  String? _entryCity;
  String? _exitCity;
  String? _calculatedToll = '0';
  String? _calculatedRoute;
  bool _showToll = false;
  bool _isCalculating = false;
  bool _isLoadingTollData = true;
  List<Map<String, dynamic>>? _tollData;
  final RxList<String> _majorCities = RxList<String>();

  // Define vehicle categories mapping to CSV columns
  final List<String> _vehicleCategories = [
    'Car',
    'Wagon',
    'Coaster',
    'Bus',
    'Truck',
    'Trailer'
  ];

  @override
  void initState() {
    super.initState();
    _loadTollData();
  }

  Future<void> _loadTollData() async {
    setState(() => _isLoadingTollData = true);
    try {
      debugPrint('Loading assets/data/city_toll.csv');
      final String csvString = await DefaultAssetBundle.of(context)
          .loadString('assets/data/city_toll.csv', cache: false);
      if (csvString.trim().isEmpty) {
        throw Exception('CSV file is empty');
      }

      debugPrint(
          'Raw CSV content: ${csvString.length > 100 ? '${csvString.substring(0, 100)}...' : csvString}');
      debugPrint('Parsing CSV data');
      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(csvString, eol: '\n');

      if (csvTable.isEmpty) {
        throw Exception('CSV has no rows');
      }

      // Validate headers
      final headers = csvTable.first
          .map((h) => h?.toString().trim().toLowerCase() ?? '')
          .toList();
      final expectedHeaders = [
        'entry_city',
        'exit_city',
        'car',
        'wagon',
        'coaster',
        'bus',
        'truck',
        'trailer',
        'route'
      ];
      if (!expectedHeaders.every((h) => headers.contains(h))) {
        throw Exception(
            'Invalid CSV headers: Expected $expectedHeaders, got $headers');
      }

      // Parse rows and collect unique cities
      final rows = csvTable.skip(1);
      final parsedData = <Map<String, dynamic>>[];
      final citySet = <String>{};

      debugPrint('Processing ${rows.length} rows');
      for (var row in rows) {
        debugPrint('Row: $row');
        if (row.length < expectedHeaders.length) {
          debugPrint('Skipping short row: $row');
          continue;
        }
        final entry = <String, dynamic>{};
        for (int i = 0; i < headers.length; i++) {
          entry[headers[i]] = row.length > i ? row[i]?.toString().trim() : '';
        }
        // Validate cities
        final entryCity = entry['entry_city'];
        final exitCity = entry['exit_city'];
        if (entryCity == null ||
            entryCity.isEmpty ||
            exitCity == null ||
            exitCity.isEmpty) {
          debugPrint('Skipping row with empty cities: $entry');
          continue;
        }
        // Parse tolls for each vehicle category
        for (var vehicle in _vehicleCategories) {
          final tollKey = vehicle.toLowerCase();
          if (entry[tollKey] != null && entry[tollKey].isNotEmpty) {
            try {
              entry[tollKey] = num.parse(entry[tollKey]).toInt();
            } catch (e) {
              debugPrint(
                  'Invalid toll for $entryCity-$exitCity ($vehicle): ${entry[tollKey]}');
              entry[tollKey] = 0;
            }
          } else {
            debugPrint('Missing toll for $entryCity-$exitCity ($vehicle)');
            entry[tollKey] = 0;
          }
        }
        parsedData.add(entry);
        citySet.add(entryCity);
        citySet.add(exitCity);
      }

      // Validate data
      if (parsedData.isEmpty) {
        throw Exception('No valid data rows in CSV after parsing');
      }
      if (citySet.length < 2) {
        throw Exception('Not enough cities in CSV to calculate tolls');
      }

      // Sort cities for UI
      final sortedCities = citySet.toList()..sort();

      setState(() {
        _tollData = parsedData;
        _majorCities.assignAll(sortedCities);
        _isLoadingTollData = false;
      });
      debugPrint(
          'Loaded ${_tollData!.length} toll entries, ${sortedCities.length} cities: $sortedCities');
    } catch (e) {
      debugPrint('Error loading CSV: $e');
      setState(() {
        _isLoadingTollData = false;
        // Fallback to minimal cities to avoid app crash
        _majorCities.assignAll(['Karachi', 'Lahore']);
      });
      _showSnackBar('Failed to load toll data. Please try again.');
    }
  }

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
    if (_entryCity == null || _exitCity == null) {
      _showSnackBar('Please select both entry and exit cities');
      return;
    }
    if (_entryCity == _exitCity) {
      _showSnackBar('Entry and exit cities must be different');
      return;
    }
    if (_selectedVehicle == -1) {
      _showSnackBar('Please select a vehicle type');
      return;
    }
    if (_isLoadingTollData) {
      _showSnackBar('Toll data is still loading, please wait');
      return;
    }
    if (_tollData == null || _tollData!.isEmpty) {
      _showSnackBar('Toll data not available');
      return;
    }

    setState(() => _isCalculating = true);
    try {
      debugPrint('Calculating toll for $_entryCity to $_exitCity');
      final tollEntry = _tollData!.firstWhere(
        (entry) =>
            (entry['entry_city'].toString().trim().toLowerCase() ==
                    _entryCity!.trim().toLowerCase() &&
                entry['exit_city'].toString().trim().toLowerCase() ==
                    _exitCity!.trim().toLowerCase()) ||
            (entry['entry_city'].toString().trim().toLowerCase() ==
                    _exitCity!.trim().toLowerCase() &&
                entry['exit_city'].toString().trim().toLowerCase() ==
                    _entryCity!.trim().toLowerCase()),
        orElse: () => <String, dynamic>{},
      );

      if (tollEntry.isEmpty) {
        throw Exception('No toll data found for $_entryCity to $_exitCity');
      }

      // Get the toll for the selected vehicle
      final vehicleName = controller.vehicleList[_selectedVehicle].name;
      final vehicleKey = vehicleName!.toLowerCase();
      final tollValue = tollEntry[vehicleKey] ?? 0;

      widget.animationController.reset();
      setState(() {
        _calculatedToll = tollValue.toString();
        _calculatedRoute =
            '$_entryCity - $_exitCity'; // Show only entry and exit cities
        _showToll = true;
      });
      widget.animationController.forward();
      _scrollToBottom();
      debugPrint('Toll: $_calculatedToll, Route: $_calculatedRoute');
    } catch (e) {
      debugPrint('Toll calculation error: $e');
      _showSnackBar('No toll information available for this route');
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showCitySelectionDialog(bool isEntry) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => StationSearchDialog(
        items: _majorCities,
        selectedItem: isEntry ? _entryCity : _exitCity,
        title: isEntry ? 'Select Entry City' : 'Select Exit City',
        hintText: 'Search City',
        leadingIcon: Icons.location_on,
        trailingIconBuilder: (item) =>
            item == (isEntry ? _entryCity : _exitCity)
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
          _entryCity = selected;
          if (_exitCity == _entryCity) {
            _exitCity = null;
            _showSnackBar('Exit city reset: Select a different city');
          }
        } else {
          if (selected == _entryCity) {
            _showSnackBar('Exit city must be different from entry');
            return;
          }
          _exitCity = selected;
        }
        _selectedVehicle = -1;
        _showToll = false;
      });

      if (isEntry && _exitCity == null) {
        await Future.delayed(const Duration(milliseconds: 300));
        await _showCitySelectionDialog(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
              const SizedBox(height: 20),
              _buildSection(_buildCitySelector(padding), context),
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
                      entry: _entryCity,
                      exit: _exitCity,
                      vehicleName: _selectedVehicle != -1
                          ? controller.vehicleList[_selectedVehicle].name
                          : null,
                      toll: _calculatedToll,
                      route: _calculatedRoute,
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

  Widget _buildCitySelector(double padding) => Card(
        elevation: 0,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Text('Select Your Route',
                      style: Theme.of(context).textTheme.labelLarge)),
              const SizedBox(height: 16),
              _buildCityDropdownField(
                icon: Icons.location_city_outlined,
                label: 'Entry City',
                value: _entryCity,
                hint: 'Select Entry City',
                onTap: () => _showCitySelectionDialog(true),
              ),
              if (_entryCity != null) ...[
                const SizedBox(height: 16),
                _buildCityDropdownField(
                  icon: Icons.location_city,
                  label: 'Exit City',
                  value: _exitCity,
                  hint: 'Select Exit City',
                  onTap: () => _showCitySelectionDialog(false),
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildCityDropdownField({
    required IconData icon,
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
                Icon(icon, color: textColor, size: 20),
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
            Text('Select Vehicle Type',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: isLargeScreen ? 140 : 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.vehicleList.length,
                itemBuilder: (context, index) =>
                    _buildVehicleItem(index, isLargeScreen),
              ),
            ),
            SizedBox(
              height: 12,
            )
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
          if (_entryCity == null || _exitCity == null) {
            _showSnackBar('Please select entry and exit cities first');
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
                height: isLargeScreen ? 45 : 35,
                colorFilter: ColorFilter.mode(
                    Theme.of(context).primaryColor, BlendMode.srcIn),
              ),
              Text(
                controller.vehicleList[index].name!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TollDisplay extends StatelessWidget {
  final double padding;
  final bool isCalculating;
  final String? entry;
  final String? exit;
  final String? vehicleName;
  final String? toll;
  final String? route;

  const TollDisplay({
    super.key,
    required this.padding,
    required this.isCalculating,
    required this.entry,
    required this.exit,
    required this.vehicleName,
    required this.toll,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Text('Toll Details', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            _buildDetailRow('Route', route ?? '$entry - $exit'),
            _buildDetailRow('Vehicle', vehicleName ?? 'Unknown'),
            const Divider(
              height: 1,
              color: Colors.grey,
            ),
            isCalculating
                ? const CircularProgressIndicator()
                : _buildDetailRow('Total Toll', '$toll PKR', isTotal: true,valueStyle: TextTheme.of(context).bodyMedium?.copyWith(color: Colors.red,fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    TextStyle? valueStyle,
    TextStyle? lableStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
            style: lableStyle,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
