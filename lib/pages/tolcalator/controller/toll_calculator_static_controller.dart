import 'package:get/get.dart';
import 'package:mtag_flutterapp/db/stations_database.dart';
import 'package:sqflite/sqflite.dart';

import '../../../db/toll_database.dart';
import '../model/static_mw_model.dart';
import '../model/stations_model.dart';
import '../model/vehicle_model.dart';

class MotorwayStaticController extends GetxController implements GetxService {
  // Rx variable for MotorwayStations
  final RxList<String> stations = <String>[].obs;
  List<StData> fullStationsList = []; // Stores stid and stname

  final StationsDatabase stationsDb = StationsDatabase.instance;
  final TollDatabase _tollDatabase = TollDatabase.instance;

  // List of vehicles
  List<VehicleModel> vehicleList = [
    VehicleModel(image: 'assets/f1.svg', name: 'Car', id: 1),
    VehicleModel(name: 'Wagon', image: 'assets/f2.svg', id: 2),
    VehicleModel(name: 'Coaster', image: 'assets/f3.svg', id: 3),
    VehicleModel(name: 'Bus', image: 'assets/f4.svg', id: 4),
    VehicleModel(name: 'Truck', image: 'assets/f5.svg', id: 5),
    VehicleModel(name: 'Trailer', image: 'assets/f6.svg', id: 6)
  ].obs;

  // List of static motorways
  List<StaticMotorwayModel> mwNameList = [
    StaticMotorwayModel(
        motorwayName: "M1", motorwayAbbrivation: "Isb-Psh", motorwayID: 4),
    StaticMotorwayModel(
        motorwayName: "M2", motorwayAbbrivation: "Isb-Lhr", motorwayID: 7),
    StaticMotorwayModel(
        motorwayName: "M3", motorwayAbbrivation: "Lhr-Abhk", motorwayID: 6),
    StaticMotorwayModel(
        motorwayName: "M4", motorwayAbbrivation: "Fsd-Pbht", motorwayID: 11),
    StaticMotorwayModel(
        motorwayName: "M5", motorwayAbbrivation: "Mlt-Skr", motorwayID: 5),
    StaticMotorwayModel(
        motorwayName: "M9", motorwayAbbrivation: "Kar-Hyd", motorwayID: 1),
    StaticMotorwayModel(
        motorwayName: "M11-LSM",
        motorwayAbbrivation: "Lhr-Siak",
        motorwayID: 2),
    StaticMotorwayModel(
        motorwayName: "M14", motorwayAbbrivation: "Yrk-Hak", motorwayID: 14),
    StaticMotorwayModel(
        motorwayName: "M15", motorwayAbbrivation: "Hazara", motorwayID: 10),
    StaticMotorwayModel(
        motorwayName: "M16-SMP", motorwayAbbrivation: "Swat", motorwayID: 3),
  ].obs;

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
              // Update name list for dropdown
              stations.add(item['stname'].toString());

              fullStationsList
                  .add(StData.fromJson(Map<String, dynamic>.from(item)));
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

  //calculate toll
  Future<Map<String, dynamic>> calculateToll({
    required String entry,
    required String exit,
    required String type,
  }) async {
    try {
      // Get database instance
      final Database db = await _tollDatabase.database;

      // Prepare the query
      // Using parameterized query to prevent SQL injection
      String sqlToll = '''
        SELECT t_toll_r
        FROM veh_toll_cal_7
        WHERE e_sta_id = ?
        AND x_sta_id = ?
        AND v_cat = ?
      ''';

      // Execute query with parameters
      List<Map<String, dynamic>> result = await db.rawQuery(
        sqlToll,
        [entry, exit, type],
      );

      if (result.isNotEmpty) {
        String tollCalc = result[0]['t_toll_r'].toString();
        return {
          "Code": "00",
          "Message": "Record Exists",
          "Data": {"toll": tollCalc}
        };
      } else {
        return {"Code": "00", "Message": "Record Doesn't Exist!", "Data": ""};
      }
    } catch (e) {
      // Log error (you might want to use a proper logging package)
      return {"Code": "01", "Message": "An Error Occurred!", "Data": ""};
    }
  }
}
