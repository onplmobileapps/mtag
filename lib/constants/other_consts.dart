import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

import '../pages/tolcalator/model/static_mw_model.dart';
import '../pages/tolcalator/model/vehicle_model.dart';

class OtherConsts {
  static final OtherConsts _instance = OtherConsts._internal();

  OtherConsts._internal();

  factory OtherConsts() => _instance;
  static final RxString _ownerName = ''.obs;

  RxString get ownerName => _ownerName;
  static final RxString _ownerCNIC = ''.obs;

  RxString get ownerCNIC => _ownerCNIC;
  static final RxString _mobile = ''.obs;

  RxString get mobile => _mobile;
  static final RxString _password = ''.obs;

  RxString get password => _password;
  static final RxString _email = ''.obs;

  RxString get email => _email;
  static final RxBool _isRefresh = false.obs;

  RxBool get isRefresh => _isRefresh;
  static final RxString _emergencySwitchProd = ''.obs;

  RxString get emergencySwitchProd => _emergencySwitchProd;
  static final RxString _emergencySwitchDebug = ''.obs;

  RxString get emergencySwitchDebug => _emergencySwitchDebug;
  static final RxBool _hasInternet = false.obs;

  RxBool get hasInternet => _hasInternet;
  static final RxInt _jazzCode = 0.obs;

  RxInt get jazzCode => _jazzCode;
  static final RxInt _creditCode = 0.obs;

  RxInt get creditCode => _creditCode;
  static final RxString _discountText = ''.obs;

  RxString get discountText => _discountText;
  static final RxInt _bageCount = 0.obs;

  RxInt get bageCount => _bageCount;

  static final RxString _promoPopUp = ''.obs;

  RxString get promoPopUp => _promoPopUp;

  static final RxString _blackList = '1'.obs;

  RxString get blackList => _blackList;

  static const List<String> sliderImages = [
    '8.webp',
    '7.jpg',
    '2.webp',
    '1.webp',
    '3.webp',
  ];
  static const String exception = 'NO DATA FOUND!';
  static List<VehicleModel> vehicleList = [
    VehicleModel(image: 'assets/f1.svg', name: 'Car', id: 1),
    VehicleModel(name: 'Wagon', image: 'assets/f2.svg', id: 2),
    VehicleModel(name: 'Coaster', image: 'assets/f3.svg', id: 3),
    VehicleModel(name: 'Bus', image: 'assets/f4.svg', id: 4),
    VehicleModel(name: 'Truck', image: 'assets/f5.svg', id: 5),
    VehicleModel(name: 'Trailer', image: 'assets/f6.svg', id: 6),
  ].obs;

  static List<StaticMotorwayModel> mwNameList = [
    StaticMotorwayModel(
      motorwayName: "M1",
      motorwayAbbrivation: "Isb-Psh",
      motorwayID: 4,
    ),
    StaticMotorwayModel(
      motorwayName: "M2",
      motorwayAbbrivation: "Isb-Lhr",
      motorwayID: 7,
    ),
    StaticMotorwayModel(
      motorwayName: "M3",
      motorwayAbbrivation: "Lhr-Abhk",
      motorwayID: 6,
    ),
    StaticMotorwayModel(
      motorwayName: "M4",
      motorwayAbbrivation: "Fsd-Pbht",
      motorwayID: 11,
    ),
    StaticMotorwayModel(
      motorwayName: "M5",
      motorwayAbbrivation: "Mlt-Skr",
      motorwayID: 5,
    ),
    StaticMotorwayModel(
      motorwayName: "M9",
      motorwayAbbrivation: "Kar-Hyd",
      motorwayID: 1,
    ),
    StaticMotorwayModel(
      motorwayName: "M11-LSM",
      motorwayAbbrivation: "Lhr-Siak",
      motorwayID: 2,
    ),
    StaticMotorwayModel(
      motorwayName: "M14",
      motorwayAbbrivation: "Yrk-Hak",
      motorwayID: 14,
    ),
    StaticMotorwayModel(
      motorwayName: "M15",
      motorwayAbbrivation: "Hazara",
      motorwayID: 10,
    ),
    StaticMotorwayModel(
      motorwayName: "M16-SMP",
      motorwayAbbrivation: "Swat",
      motorwayID: 3,
    ),
    StaticMotorwayModel(
      motorwayName: "N75",
      motorwayAbbrivation: "\t\t\tMurree\nExpressway",
      motorwayID: 200,
    ),
    StaticMotorwayModel(
      motorwayName: "EBP",
      motorwayAbbrivation: "\t\tEastern\n\t\tBypass",
      motorwayID: 300,
    ),
  ].obs;
}
