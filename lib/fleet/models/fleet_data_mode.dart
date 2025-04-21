// ignore_for_file: unnecessary_getters_setters

class FleetModel {
  String? _code;
  Data? _data;
  String? _message;

  FleetModel({String? code, Data? data, String? message}) {
    if (code != null) {
      _code = code;
    }
    if (data != null) {
      _data = data;
    }
    if (message != null) {
      _message = message;
    }
  }

  String? get code => _code;
  set code(String? code) => _code = code;
  Data? get data => _data;
  set data(Data? data) => _data = data;
  String? get message => _message;
  set message(String? message) => _message = message;

  FleetModel.fromJson(Map<String, dynamic> json) {
    _code = json['Code'];
    _data = json['Data'] != null ? Data.fromJson(json['Data']) : null;
    _message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = _code;
    if (_data != null) {
      data['Data'] = _data!.toJson();
    }
    data['Message'] = _message;
    return data;
  }
}

class Data {
  List<PicturesURL>? _picturesURL;
  String? _address;
  int? _alertBal;
  int? _balance;
  int? _companyid;
  String? _contactNo;
  String? _contactPersonName;
  int? _cutoutBal;
  bool? _msgAlert;
  String? _name;
  int? _opBalance;
  int? _vehicleCount;

  Data({
    List<PicturesURL>? picturesURL,
    String? address,
    int? alertBal,
    int? balance,
    int? companyid,
    String? contactNo,
    String? contactPersonName,
    int? cutoutBal,
    bool? msgAlert,
    String? name,
    int? opBalance,
    int? vehicleCount,
  }) {
    if (picturesURL != null) {
      _picturesURL = picturesURL;
    }
    if (address != null) {
      _address = address;
    }
    if (alertBal != null) {
      _alertBal = alertBal;
    }
    if (balance != null) {
      _balance = balance;
    }
    if (companyid != null) {
      _companyid = companyid;
    }
    if (contactNo != null) {
      _contactNo = contactNo;
    }
    if (contactPersonName != null) {
      _contactPersonName = contactPersonName;
    }
    if (cutoutBal != null) {
      _cutoutBal = cutoutBal;
    }
    if (msgAlert != null) {
      _msgAlert = msgAlert;
    }
    if (name != null) {
      _name = name;
    }
    if (opBalance != null) {
      _opBalance = opBalance;
    }
    if (vehicleCount != null) {
      _vehicleCount = vehicleCount;
    }
  }

  List<PicturesURL>? get picturesURL => _picturesURL;
  set picturesURL(List<PicturesURL>? picturesURL) => _picturesURL = picturesURL;
  String? get address => _address;
  set address(String? address) => _address = address;
  int? get alertBal => _alertBal;
  set alertBal(int? alertBal) => _alertBal = alertBal;
  int? get balance => _balance;
  set balance(int? balance) => _balance = balance;
  int? get companyid => _companyid;
  set companyid(int? companyid) => _companyid = companyid;
  String? get contactNo => _contactNo;
  set contactNo(String? contactNo) => _contactNo = contactNo;
  String? get contactPersonName => _contactPersonName;
  set contactPersonName(String? contactPersonName) => _contactPersonName = contactPersonName;
  int? get cutoutBal => _cutoutBal;
  set cutoutBal(int? cutoutBal) => _cutoutBal = cutoutBal;
  bool? get msgAlert => _msgAlert;
  set msgAlert(bool? msgAlert) => _msgAlert = msgAlert;
  String? get name => _name;
  set name(String? name) => _name = name;
  int? get opBalance => _opBalance;
  set opBalance(int? opBalance) => _opBalance = opBalance;
  int? get vehicleCount => _vehicleCount;
  set vehicleCount(int? vehicelCount) => _vehicleCount = vehicelCount;

  Data.fromJson(Map<String, dynamic> json) {
    if (json['Pictures_URL'] != null) {
      _picturesURL = <PicturesURL>[];
      json['Pictures_URL'].forEach((v) {
        _picturesURL!.add(PicturesURL.fromJson(v));
      });
    }
    _address = json['address'];
    _alertBal = json['alert_bal'];
    _balance = json['balance'];
    _companyid = json['companyid'];
    _contactNo = json['contact_no'];
    _contactPersonName = json['contact_person_name'];
    _cutoutBal = json['cutout_bal'];
    _msgAlert = json['msg_alert'];
    _name = json['name'];
    _opBalance = json['op_balance'];
    _vehicleCount = json['vehicle_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_picturesURL != null) {
      data['Pictures_URL'] = _picturesURL!.map((v) => v.toJson()).toList();
    }
    data['address'] = _address;
    data['alert_bal'] = _alertBal;
    data['balance'] = _balance;
    data['companyid'] = _companyid;
    data['contact_no'] = _contactNo;
    data['contact_person_name'] = _contactPersonName;
    data['cutout_bal'] = _cutoutBal;
    data['msg_alert'] = _msgAlert;
    data['name'] = _name;
    data['op_balance'] = _opBalance;
    return data;
  }
}

class PicturesURL {
  String? _name;

  PicturesURL({String? name}) {
    if (name != null) {
      _name = name;
    }
  }

  String? get name => _name;
  set name(String? name) => _name = name;

  PicturesURL.fromJson(Map<String, dynamic> json) {
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = _name;
    return data;
  }
}
