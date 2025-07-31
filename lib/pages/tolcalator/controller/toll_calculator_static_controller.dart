import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../../db/stations_database.dart';
import '../../../db/toll_database.dart';
import '../../../widgets/search_stations_dialog.dart';
import '../model/static_mw_model.dart';
import '../model/stations_model.dart';
import '../model/vehicle_model.dart';


class MotorwayStaticController extends GetxController implements GetxService {
  final RxList<String> stations = <String>[].obs;
  List<StData> fullStationsList = [];

  final StationsDatabase stationsDb = StationsDatabase.instance;
  final TollDatabase _tollDatabase = TollDatabase.instance;

  List<VehicleModel> vehicleList = [
    VehicleModel(image: 'assets/f1.svg', name: 'Car', id: 1),
    VehicleModel(name: 'Wagon', image: 'assets/f2.svg', id: 2),
    VehicleModel(name: 'Coaster', image: 'assets/f3.svg', id: 3),
    VehicleModel(name: 'Bus', image: 'assets/f4.svg', id: 4),
    VehicleModel(name: 'Truck', image: 'assets/f5.svg', id: 5),
    VehicleModel(name: 'Trailer', image: 'assets/f6.svg', id: 6)
  ].obs;

  List<StaticMotorwayModel> mwNameList = [
    StaticMotorwayModel(motorwayName: "M1", motorwayAbbrivation: "Isb-Psh", motorwayID: 4),
    StaticMotorwayModel(motorwayName: "M2", motorwayAbbrivation: "Isb-Lhr", motorwayID: 7),
    StaticMotorwayModel(motorwayName: "M3", motorwayAbbrivation: "Lhr-Abhk", motorwayID: 6),
    StaticMotorwayModel(motorwayName: "M4", motorwayAbbrivation: "Fsd-Pbht", motorwayID: 11),
    StaticMotorwayModel(motorwayName: "M5", motorwayAbbrivation: "Mlt-Skr", motorwayID: 5),
    StaticMotorwayModel(motorwayName: "M9", motorwayAbbrivation: "Kar-Hyd", motorwayID: 1),
    StaticMotorwayModel(motorwayName: "M11-LSM", motorwayAbbrivation: "Lhr-Siak", motorwayID: 2),
    StaticMotorwayModel(motorwayName: "M14", motorwayAbbrivation: "Yrk-Hak", motorwayID: 14),
    StaticMotorwayModel(motorwayName: "M15", motorwayAbbrivation: "Hazara", motorwayID: 10),
    StaticMotorwayModel(motorwayName: "M16-SMP", motorwayAbbrivation: "Swat", motorwayID: 3),
  ].obs;

  final ScrollController scrollController = ScrollController();
  final RxInt selectedVehicle = (-1).obs;
  final RxString entryCity = RxString('');
  final RxString exitCity = RxString('');
  final RxString calculatedToll = '0'.obs;
  final RxString calculatedRoute = RxString('');
  final RxBool showToll = false.obs;
  final RxBool isCalculating = false.obs;
  final RxBool isLoadingTollData = false.obs;
  final RxList<Map<String, dynamic>> tollData = <Map<String, dynamic>>[].obs;
  final RxList<String> majorCities = <String>[].obs;

  // TollPlazaTab specific state
  final RxInt selectedMotorway = (-1).obs;
  final RxString entryStation = RxString('');
  final RxString exitStation = RxString('');
  final RxString calculatedTollPlaza = '0'.obs;
  final RxBool showTollPlaza = false.obs;
  final RxBool isCalculatingPlaza = false.obs;

  final List<String> vehicleCategories = [
    'Car',
    'Wagon',
    'Coaster',
    'Bus',
    'Truck',
    'Trailer',
  ];

  @override
  void onInit() {
    super.onInit();
    loadTollData();
  }

  @override
  void onClose() {
    scrollController.dispose();
 
    super.onClose();
  }




  void reset() {
    selectedVehicle.value = -1;
    entryCity.value = '';
    exitCity.value = '';
    calculatedToll.value = '0';
    calculatedRoute.value = '';
    showToll.value = false;
    isCalculating.value = false;
    isLoadingTollData.value = false;
    selectedMotorway.value = -1;
    entryStation.value = '';
    exitStation.value = '';
    calculatedTollPlaza.value = '0';
    showTollPlaza.value = false;
    isCalculatingPlaza.value = false;
    stations.clear();
    fullStationsList.clear();
  
    
  }
  

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> loadTollData() async {
    isLoadingTollData.value = true;
    try {
      debugPrint('Loading assets/data/city_toll.csv');
      final String csvString = await DefaultAssetBundle.of(Get.context!).loadString(
        'assets/data/city_toll.csv',
        cache: false,
      );

      if (csvString.trim().isEmpty) throw Exception('CSV file is empty');

      debugPrint('Raw CSV content: ${csvString.length > 100 ? '${csvString.substring(0, 100)}...' : csvString}');
      debugPrint('Parsing CSV data');

      final csvTable = const CsvToListConverter().convert(csvString, eol: '\n');

      if (csvTable.isEmpty) throw Exception('CSV has no rows');

      final headers = csvTable.first.map((h) => h?.toString().trim().toLowerCase() ?? '').toList();
      final expectedHeaders = ['entry_city', 'exit_city', 'car', 'wagon', 'coaster', 'bus', 'truck', 'trailer', 'route'];

      if (!expectedHeaders.every((h) => headers.contains(h))) {
        throw Exception('Invalid CSV headers: Expected $expectedHeaders, got $headers');
      }

      final rows = csvTable.skip(1);
      final parsedData = <Map<String, dynamic>>[];
      final citySet = <String>{};

      debugPrint('Processing ${rows.length} rows');

      for (var row in rows) {
        if (row.length < expectedHeaders.length) {
          debugPrint('Skipping short row: $row');
          continue;
        }

        final entry = <String, dynamic>{};
        for (int i = 0; i < headers.length; i++) {
          entry[headers[i]] = row.length > i ? row[i]?.toString().trim() : '';
        }

        final entryCity = entry['entry_city'];
        final exitCity = entry['exit_city'];

        if (entryCity == null || entryCity.isEmpty || exitCity == null || exitCity.isEmpty) {
          debugPrint('Skipping row with empty cities: $entry');
          continue;
        }

        for (var vehicle in vehicleCategories) {
          final key = vehicle.toLowerCase();
          if (entry[key] != null && entry[key].isNotEmpty) {
            try {
              entry[key] = num.parse(entry[key]).toInt();
            } catch (e) {
              debugPrint('Invalid toll for $entryCity-$exitCity ($vehicle): ${entry[key]}');
              entry[key] = 0;
            }
          } else {
            entry[key] = 0;
          }
        }

        parsedData.add(entry);
        citySet.add(entryCity);
        citySet.add(exitCity);
      }

      if (parsedData.isEmpty) throw Exception('No valid data rows in CSV');
      if (citySet.length < 2) throw Exception('Not enough cities');

      final sortedCities = citySet.toList()..sort();

      tollData.assignAll(parsedData);
      majorCities.assignAll(sortedCities);

      debugPrint('Loaded ${parsedData.length} toll entries, ${sortedCities.length} cities: $sortedCities');
    } catch (e) {
      debugPrint('Error loading CSV: $e');
      majorCities.assignAll(['Karachi', 'Lahore']);
      Get.snackbar('Error', 'Failed to load toll data. Please try again.');
    } finally {
      isLoadingTollData.value = false;
    }
  }

  Future<void> fetchStations(int mwid) async {
    try {
      final response = await stationsDb.getMotStations(mwid);

      if (response["Code"] == "00") {
        stations.clear();
        fullStationsList.clear();

        if (response["Data"] is String && response["Data"].isEmpty) {
          return;
        }

        if (response["Data"] is List) {
          final List<dynamic> data = response["Data"];
          for (var item in data) {
            if (item is Map && item.containsKey('stname')) {
              stations.add(item['stname'].toString());
              fullStationsList.add(StData.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      } else {
        stations.clear();
        fullStationsList.clear();
      }
    } catch (e) {
      stations.clear();
      fullStationsList.clear();
      rethrow;
    }
  }

  String? _getStationId(String stationName) {
    final station = fullStationsList.firstWhere(
      (station) => station.stname?.toLowerCase() == stationName.toLowerCase(),
      orElse: () => StData(stid: '', stname: ''),
    );
    return station.stid?.isNotEmpty??false ? station.stid : null;
  }

  Future<Map<String, dynamic>> calculateToll({
    required String entry,
    required String exit,
    required String type,
  }) async {
    try {
      final Database db = await _tollDatabase.database;
      String sqlToll = '''
        SELECT t_toll_r
        FROM veh_toll_cal_7
        WHERE e_sta_id = ?
        AND x_sta_id = ?
        AND v_cat = ?
      ''';
      List<Map<String, dynamic>> result = await db.rawQuery(sqlToll, [entry, exit, type]);

      if (result.isNotEmpty) {
        String tollCalc = result[0]['t_toll_r'].toString();
        return {"Code": "00", "Message": "Record Exists", "Data": {"toll": tollCalc}};
      } else {
        return {"Code": "00", "Message": "Record Doesn't Exist!", "Data": ""};
      }
    } catch (e) {
      return {"Code": "01", "Message": "An Error Occurred!", "Data": ""};
    }
  }

  Future<void> calculateTollUI(AnimationController animationController) async {
    if (entryCity.value.isEmpty || exitCity.value.isEmpty) {
      showSnackBar('Please select both entry and exit cities');
      return;
    }
    if (entryCity.value == exitCity.value) {
      showSnackBar('Entry and exit cities must be different');
      return;
    }
    if (selectedVehicle.value == -1) {
      showSnackBar('Please select a vehicle type');
      return;
    }
    if (isLoadingTollData.value) {
      showSnackBar('Toll data is still loading, please wait');
      return;
    }

    isCalculating.value = true;
    try {
      debugPrint('Calculating toll for ${entryCity.value} to ${exitCity.value}');
      final tollEntry = tollData.firstWhere(
        (entry) =>
            (entry['entry_city'].toString().trim().toLowerCase() == entryCity.value.trim().toLowerCase() &&
                entry['exit_city'].toString().trim().toLowerCase() == exitCity.value.trim().toLowerCase()) ||
            (entry['entry_city'].toString().trim().toLowerCase() == exitCity.value.trim().toLowerCase() &&
                entry['exit_city'].toString().trim().toLowerCase() == entryCity.value.trim().toLowerCase()),
        orElse: () => <String, dynamic>{},
      );

      if (tollEntry.isNotEmpty) {
        final vehicleName = vehicleList[selectedVehicle.value].name;
        final vehicleKey = vehicleName!.toLowerCase();
        final tollValue = tollEntry[vehicleKey] ?? 0;

        animationController.reset();
        calculatedToll.value = tollValue.toString();
        calculatedRoute.value = '${entryCity.value} - ${exitCity.value}';
        showToll.value = true;
        animationController.forward();
        scrollToBottom();
        debugPrint('Toll (CSV): ${calculatedToll.value}, Route: ${calculatedRoute.value}');
      } else {
        final entryStationId = _getStationId(entryCity.value);
        final exitStationId = _getStationId(exitCity.value);

        if (entryStationId == null || exitStationId == null) {
          throw Exception('Invalid station IDs for ${entryCity.value} or ${exitCity.value}');
        }

        final vehicleName = vehicleList[selectedVehicle.value].name;
        final result = await calculateToll(
          entry: entryStationId,
          exit: exitStationId,
          type: vehicleName!.toLowerCase(),
        );

        if (result['Code'] == '00' && result['Data'] != '') {
          animationController.reset();
          calculatedToll.value = result['Data']['toll'].toString();
          calculatedRoute.value = '${entryCity.value} - ${exitCity.value}';
          showToll.value = true;
          animationController.forward();
          scrollToBottom();
          debugPrint('Toll (DB): ${calculatedToll.value}, Route: ${calculatedRoute.value}');
        } else {
          throw Exception('No toll data found for ${entryCity.value} to ${exitCity.value}');
        }
      }
    } catch (e) {
      debugPrint('Toll calculation error: $e');
      showSnackBar('No toll information available for this route');
    } finally {
      isCalculating.value = false;
    }
  }

  Future<void> calculateTollPlaza(AnimationController animationController) async {
    if (selectedMotorway.value == -1) {
      showSnackBar('Please select a motorway first');
      return;
    }
    if (entryStation.value.isEmpty || exitStation.value.isEmpty) {
      showSnackBar('Please select both entry and exit stations');
      return;
    }
    if (entryStation.value == exitStation.value) {
      showSnackBar('Entry and exit stations must be different');
      return;
    }
    if (selectedVehicle.value == -1) {
      showSnackBar('Please select a vehicle type');
      return;
    }

    isCalculatingPlaza.value = true;
    try {
      final entryId = _getStationId(entryStation.value);
      final exitId = _getStationId(exitStation.value);

      if (entryId == null || exitId == null) {
        throw Exception('Station ID not found for ${entryStation.value} or ${exitStation.value}');
      }

      final result = await calculateToll(
        entry: entryId,
        exit: exitId,
        type: vehicleList[selectedVehicle.value].id.toString(),
      );

      if (result['Code'] == '00' && result['Data'] != '') {
        animationController.reset();
        calculatedTollPlaza.value = result['Data']['toll'].toString();
        showTollPlaza.value = true;
        animationController.forward();
        scrollToBottom();
        debugPrint('Toll (Plaza): ${calculatedTollPlaza.value}, Route: ${entryStation.value} - ${exitStation.value}');
      } else {
        throw Exception(result['Message'] ?? 'Failed to calculate toll');
      }
    } catch (e) {
      debugPrint('Toll plaza calculation error: $e');
      showSnackBar('Calculation failed: $e');
    } finally {
      isCalculatingPlaza.value = false;
    }
  }

  void showSnackBar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> showCitySelectionDialog(bool isEntry) async {
    final selected = await Get.dialog<String>(
      StationSearchDialog(
        items: majorCities,
        selectedItem: isEntry ? entryCity.value : exitCity.value,
        title: isEntry ? 'Select Entry City' : 'Select Exit City',
        hintText: 'Search City',
        leadingIcon: Icons.location_on,
        trailingIconBuilder: (item) => item == (isEntry ? entryCity.value : exitCity.value)
            ? Icon(
                Icons.check,
                color: Get.theme.brightness == Brightness.dark ? Colors.grey : Get.theme.primaryColor,
              )
            : null,
      ),
    );

    if (selected != null && selected.isNotEmpty) {
      if (isEntry) {
        entryCity.value = selected;
        if (exitCity.value == entryCity.value) {
          exitCity.value = '';
          showSnackBar('Exit city reset: Select a different city');
        }
      } else {
        if (selected == entryCity.value) {
          showSnackBar('Exit city must be different from entry');
          return;
        }
        exitCity.value = selected;
      }
      selectedVehicle.value = -1;
      showToll.value = false;

      if (isEntry && exitCity.value.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        await showCitySelectionDialog(false);
      }
    }
  }

  Future<void> showStationSelectionDialog(bool isEntry) async {
    if (selectedMotorway.value == -1) {
      showSnackBar('Please select a motorway first');
      return;
    }
    if (stations.isEmpty) {
      showSnackBar('No stations available');
      return;
    }

    final selected = await Get.dialog<String>(
      StationSearchDialog(
        items: stations,
        selectedItem: isEntry ? entryStation.value : exitStation.value,
        title: isEntry ? 'Select Entry Station' : 'Select Exit Station',
        hintText: 'Search Station',
        leadingIcon: Icons.location_on,
        trailingIconBuilder: (item) => item == (isEntry ? entryStation.value : exitStation.value)
            ? Icon(
                Icons.check,
                color: Get.theme.brightness == Brightness.dark ? Colors.grey : Get.theme.primaryColor,
              )
            : null,
      ),
    );

    if (selected != null && selected.isNotEmpty) {
      if (isEntry) {
        entryStation.value = selected;
        if (exitStation.value == entryStation.value) {
          exitStation.value = '';
          showSnackBar('Exit station reset: Select a different station');
        }
      } else {
        if (selected == entryStation.value) {
          showSnackBar('Exit station must be different from entry');
          return;
        }
        exitStation.value = selected;
      }
      selectedVehicle.value = -1;
      showTollPlaza.value = false;

      if (isEntry && exitStation.value.isEmpty) {
        await Future.delayed(const Duration(milliseconds: 300));
        await showStationSelectionDialog(false);
      }
    }
  }
}