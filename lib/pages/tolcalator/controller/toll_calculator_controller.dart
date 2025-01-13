import 'package:get/get.dart';
import 'package:mtag_flutterapp/api/api_constants.dart';
import 'package:mtag_flutterapp/api/user_repo.dart';
import 'package:mtag_flutterapp/pages/tolcalator/model/motorway_model.dart';
import 'package:mtag_flutterapp/pages/tolcalator/model/stations_model.dart' as station;
import 'package:mtag_flutterapp/pages/tolcalator/model/vehicle_model.dart';
import 'package:mtag_flutterapp/widgets/dialog/cupertion_dialog.dart';

import '../../../controller/home_controller.dart';

class TollCalculatorController extends GetxController implements GetxService {
  final UserRepo userRepo;
  TollCalculatorController({required this.userRepo});
  Rx<MotorwayModel> motorways = MotorwayModel().obs;
  var motoStations = Rx<station.StationsModel?>(null);
  var selectedEntryItem = Rx<station.Data?>(null);
  var selectedExitItem = Rx<station.Data?>(null);

  void clearData() {
    selectedEntryItem.value = null;
    selectedExitItem.value = null;
    motoStations.value = null;
    totalToll.value = null;
    motorWayIndex = -1;
    vehicleIndex = -1;
  }

  var motorWayIndex = -1.obs;
  var vehicleIndex = -1.obs;
  var totalToll = Rx<String?>(null);
  RxString? exitStation = 'Select Exit Station'.obs;
  RxString? entryStaion = 'Select Entry Station'.obs;
  RxList<VehicleModel> vehicleList = [
    VehicleModel(
      image: 'assets/f1.svg',
      name: 'Car',
      id: 1,
    ),
    VehicleModel(
      name: 'Wagon',
      image: 'assets/f2.svg',
      id: 2,
    ),
    VehicleModel(
      name: 'Coaster',
      image: 'assets/f3.svg',
      id: 3,
    ),
    VehicleModel(
      name: 'Bus',
      image: 'assets/f4.svg',
      id: 4,
    ),
    VehicleModel(
      name: 'Truck',
      image: 'assets/f5.svg',
      id: 5,
    ),
    VehicleModel(
      name: 'Trailer',
      image: 'assets/f6.svg',
      id: 6,
    )
  ].obs;
  RxInt entryID = 0.obs;
  RxInt exitID = 0.obs;
  setEntry(station.Data? val) {
    selectedEntryItem.value = val;
    entryID.value = int.parse(val?.stid ?? '0');
  }

  setExit(station.Data val) {
    selectedExitItem.value = val;
    exitID.value = int.parse(val.stid ?? '0');
  }

  void resetValues() {
    selectedEntryItem.value = null;
    selectedExitItem.value = null;
    totalToll.value = null;
  }

  resetExitStation() {
    selectedExitItem.value = null;
  }

  Future<Map<String, dynamic>> getMotorWays() async {
    var response = await userRepo.getMotorWays();
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      motorways.value = MotorwayModel.fromJson(response[APIRESPONSE.SUCCESS]);
    } else if (response.containsKey(APIRESPONSE.ERROR)) {
      showPopDialog(response[APIRESPONSE.ERROR]['Message'], () {
        if (response['Code'] == 450) {
          Get.delete<HomeController>(force: true);
          Get.offAllNamed('/login');
        } else {
          Get.back();
        }
      });
    }
    return {APIRESPONSE.ERROR: response};
  }

  Future<Map<String, dynamic>> getMotStations({int? mwid}) async {
    var response = await userRepo.getStations(mwid: mwid);

    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      motoStations.refresh();
      motoStations.value = station.StationsModel.fromJson(response[APIRESPONSE.SUCCESS]);
    }
    return {APIRESPONSE.ERROR: response};
  }

  Future<Map<String, dynamic>> calCulateToll({
    int? id,
  }) async {
    var response = await userRepo.calCulateToll(
      id: id,
      entry: entryID.value,
      exit: exitID.value,
    );
    if (response.containsKey(APIRESPONSE.SUCCESS)) {
      totalToll.value = response[APIRESPONSE.SUCCESS]['Data']['toll'];
      return response;
    }

    return {APIRESPONSE.ERROR: response};
  }

  @override
  void onReady() async {
    super.onReady();
    Future.wait([
      getMotorWays(),
    ]);
  }
}
