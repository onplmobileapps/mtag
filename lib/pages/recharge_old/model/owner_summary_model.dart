// ignore_for_file: unnecessary_getters_setters

class OwnerRechargeModel {
  String? _code;
  List<Data>? _data;
  String? _message;

  OwnerRechargeModel({String? code, List<Data>? data, String? message}) {
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
  List<Data>? get data => _data;
  set data(List<Data>? data) => _data = data;
  String? get message => _message;
  set message(String? message) => _message = message;

  OwnerRechargeModel.fromJson(Map<String, dynamic> json) {
    _code = json['Code'];
    if (json['Data'] != null) {
      _data = <Data>[];
      json['Data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
    _message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = _code;
    if (_data != null) {
      data['Data'] = _data?.map((v) => v.toJson()).toList();
    }
    data['Message'] = _message;
    return data;
  }
}

class Data {
  String? _bankCharges;
  String? _iSACTIVE;
  String? _mTAGID;
  String? _mTagBalance;
  String? _oWNERNAME;
  int? _totalRechargeAmount;
  String? _vEHNO;

  Data(
      {String? bankCharges,
      String? iSACTIVE,
      String? mTAGID,
      String? mTagBalance,
      String? oWNERNAME,
      int? totalRechargeAmount,
      String? vEHNO}) {
    if (bankCharges != null) {
      _bankCharges = bankCharges;
    }
    if (iSACTIVE != null) {
      _iSACTIVE = iSACTIVE;
    }
    if (mTAGID != null) {
      _mTAGID = mTAGID;
    }
    if (mTagBalance != null) {
      _mTagBalance = mTagBalance;
    }
    if (oWNERNAME != null) {
      _oWNERNAME = oWNERNAME;
    }
    if (totalRechargeAmount != null) {
      _totalRechargeAmount = totalRechargeAmount;
    }
    if (vEHNO != null) {
      _vEHNO = vEHNO;
    }
  }

  String? get bankCharges => _bankCharges;
  set bankCharges(String? bankCharges) => _bankCharges = bankCharges;
  String? get iSACTIVE => _iSACTIVE;
  set iSACTIVE(String? iSACTIVE) => _iSACTIVE = iSACTIVE;
  String? get mTAGID => _mTAGID;
  set mTAGID(String? mTAGID) => _mTAGID = mTAGID;
  String? get mTagBalance => _mTagBalance;
  set mTagBalance(String? mTagBalance) => _mTagBalance = mTagBalance;
  String? get oWNERNAME => _oWNERNAME;
  set oWNERNAME(String? oWNERNAME) => _oWNERNAME = oWNERNAME;
  int? get totalRechargeAmount => _totalRechargeAmount;
  set totalRechargeAmount(int? totalRechargeAmount) => _totalRechargeAmount = totalRechargeAmount;
  String? get vEHNO => _vEHNO;
  set vEHNO(String? vEHNO) => _vEHNO = vEHNO;

  Data.fromJson(Map<String, dynamic> json) {
    _bankCharges = json['Bank_Charges'];
    _iSACTIVE = json['IS_ACTIVE'];
    _mTAGID = json['MTAG_ID'];
    _mTagBalance = json['M_Tag_Balance'];
    _oWNERNAME = json['OWNERNAME'];
    _totalRechargeAmount = json['Total_Recharge_Amount'];
    _vEHNO = json['VEH_NO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Bank_Charges'] = _bankCharges;
    data['IS_ACTIVE'] = _iSACTIVE;
    data['MTAG_ID'] = _mTAGID;
    data['M_Tag_Balance'] = _mTagBalance;
    data['OWNERNAME'] = _oWNERNAME;
    data['Total_Recharge_Amount'] = _totalRechargeAmount;
    data['VEH_NO'] = _vEHNO;
    return data;
  }
}
