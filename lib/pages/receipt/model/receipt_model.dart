// ignore_for_file: unnecessary_getters_setters

class ReceiptModel {
  String? _code;
  Data? _data;
  String? _message;

  ReceiptModel({String? code, Data? data, String? message}) {
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

  ReceiptModel.fromJson(Map<String, dynamic> json) {
    _code = json['Code'];
    _data = json['Data'] != null ? Data.fromJson(json['Data']) : null;
    _message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = _code;
    if (_data != null) {
      data['Data'] = _data?.toJson();
    }
    data['Message'] = _message;
    return data;
  }
}

class Data {
  int? _amount;
  String? _boothName;
  String? _cR;
  String? _mTagID;
  String? _paymentOption;
  String? _rechargeDate;
  String? _registration;
  String? _uID;
  String? _entryStation;
  String? _exitStation;
  String? _fare;
  String? _time;

  Data({
    int? amount,
    String? boothName,
    String? cR,
    String? mTagID,
    String? paymentOption,
    String? rechargeDate,
    String? registration,
    String? uID,
    String? entryStation,
    String? exitStation,
    String? fare,
    String? time,
  }) {
    if (amount != null) {
      _amount = amount;
    }
    if (boothName != null) {
      _boothName = boothName;
    }
    if (cR != null) {
      _cR = cR;
    }
    if (mTagID != null) {
      _mTagID = mTagID;
    }
    if (paymentOption != null) {
      _paymentOption = paymentOption;
    }
    if (rechargeDate != null) {
      _rechargeDate = rechargeDate;
    }
    if (registration != null) {
      _registration = registration;
    }
    if (uID != null) {
      _uID = uID;
    }
    if (fare != null) {
      _fare = fare;
    }
    if (entryStation != null) {
      _entryStation = entryStation;
    }
    if (exitStation != null) {
      _entryStation = _exitStation;
    }
    if (time != null) {
      _time = time;
    }
  }

  int? get amount => _amount;
  String? get fare => _fare;
  String? get entryStation => _entryStation;
  String? get exitStation => _exitStation;
  String? get time => _time;
  set amount(int? amount) => _amount = amount;
  String? get boothName => _boothName;
  set boothName(String? boothName) => _boothName = boothName;
  String? get cR => _cR;
  set cR(String? cR) => _cR = cR;
  String? get mTagID => _mTagID;
  set mTagID(String? mTagID) => _mTagID = mTagID;
  String? get paymentOption => _paymentOption;
  set paymentOption(String? paymentOption) => _paymentOption = paymentOption;
  String? get rechargeDate => _rechargeDate;
  set rechargeDate(String? rechargeDate) => _rechargeDate = rechargeDate;
  String? get registration => _registration;
  set registration(String? registration) => _registration = registration;
  String? get uID => _uID;
  set uID(String? uID) => _uID = uID;

  Data.fromJson(Map<String, dynamic> json) {
    _amount = json['Amount'];
    _fare = json['FARE'];
    _entryStation = json['ENTRY_STATION_NAME'];
    _exitStation = json['EXIT_STATION_NAME'];
    _time = json['TRANS_TIME'];
    _boothName = json['Booth_Name'];
    _cR = json['CR'];
    _mTagID = json['MTag_ID'];
    _paymentOption = json['Payment_Option'];
    _rechargeDate = json['RechargeDate'];
    _registration = json['Registration'];
    _uID = json['U_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Amount'] = _amount;
    data['Booth_Name'] = _boothName;
    data['CR'] = _cR;
    data['MTag_ID'] = _mTagID;
    data['Payment_Option'] = _paymentOption;
    data['RechargeDate'] = _rechargeDate;
    data['Registration'] = _registration;
    data['U_ID'] = _uID;
    return data;
  }
}
