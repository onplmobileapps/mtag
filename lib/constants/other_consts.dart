import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';

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
  static const List<String> sliderImages=['7.jpg','8.jpg','2.jpg','3.jpg','4.jpg','5.jpg'];
  static const String exception='NO DATA FOUND!';
}