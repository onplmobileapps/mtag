// ignore_for_file: unnecessary_getters_setters

class PaymentCardModel {
  List<CardsData>? _cardsData;
  String? _code;
  String? _message;
  int? _cnt;

  PaymentCardModel({List<CardsData>? cardsData, String? code, String? message, int? cnt}) {
    if (cardsData != null) {
      _cardsData = cardsData;
    }
    if (code != null) {
      _code = code;
    }
    if (message != null) {
      _message = message;
    }
    if (cnt != null) {
      _cnt = cnt;
    }
  }

  List<CardsData>? get cardsData => _cardsData;
  set cardsData(List<CardsData>? cardsData) => _cardsData = cardsData;
  String? get code => _code;
  set code(String? code) => _code = code;
  String? get message => _message;
  set message(String? message) => _message = message;
  int? get cnt => _cnt;
  set cnt(int? cnt) => _cnt = cnt;

  PaymentCardModel.fromJson(Map<String, dynamic> json) {
    if (json['Cards_Data'] != null) {
      _cardsData = <CardsData>[];
      json['Cards_Data'].forEach((v) {
        _cardsData?.add(CardsData.fromJson(v));
      });
    }
    _code = json['Code'];
    _message = json['Message'];
    _cnt = json['cnt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_cardsData != null) {
      data['Cards_Data'] = _cardsData?.map((v) => v.toJson()).toList();
    }
    data['Code'] = _code;
    data['Message'] = _message;
    data['cnt'] = _cnt;
    return data;
  }
}

class CardsData {
  String? _bRAND;
  String? _cARDNUMBER;
  String? _eXPIRY;
  String? _fUNDINGMETHOD;
  String? _iSSUER;
  String? _iSACTIVE;
  String? _id;
  String? _tOKEN;
  bool? isSelected = false;

  CardsData({
    String? bRAND,
    String? cARDNUMBER,
    String? eXPIRY,
    String? fUNDINGMETHOD,
    String? iSSUER,
    String? iSACTIVE,
    String? id,
    String? tOKEN,
    this.isSelected,
  }) {
    if (bRAND != null) {
      _bRAND = bRAND;
    }
    if (cARDNUMBER != null) {
      _cARDNUMBER = cARDNUMBER;
    }
    if (eXPIRY != null) {
      _eXPIRY = eXPIRY;
    }
    if (fUNDINGMETHOD != null) {
      _fUNDINGMETHOD = fUNDINGMETHOD;
    }
    if (iSSUER != null) {
      _iSSUER = iSSUER;
    }
    if (iSACTIVE != null) {
      _iSACTIVE = iSACTIVE;
    }
    if (id != null) {
      _id = id;
    }
    if (tOKEN != null) {
      _tOKEN = tOKEN;
    }
  }

  String? get bRAND => _bRAND;
  set bRAND(String? bRAND) => _bRAND = bRAND;
  String? get cARDNUMBER => _cARDNUMBER;
  set cARDNUMBER(String? cARDNUMBER) => _cARDNUMBER = cARDNUMBER;
  String? get eXPIRY => _eXPIRY;
  set eXPIRY(String? eXPIRY) => _eXPIRY = eXPIRY;
  String? get fUNDINGMETHOD => _fUNDINGMETHOD;
  set fUNDINGMETHOD(String? fUNDINGMETHOD) => _fUNDINGMETHOD = fUNDINGMETHOD;
  String? get iSSUER => _iSSUER;
  set iSSUER(String? iSSUER) => _iSSUER = iSSUER;
  String? get iSACTIVE => _iSACTIVE;
  set iSACTIVE(String? iSACTIVE) => _iSACTIVE = iSACTIVE;
  String? get id => _id;
  set id(String? id) => _id = id;
  String? get tOKEN => _tOKEN;
  set tOKEN(String? tOKEN) => _tOKEN = tOKEN;

  CardsData.fromJson(Map<String, dynamic> json) {
    _bRAND = json['BRAND'];
    _cARDNUMBER = json['CARD_NUMBER'];
    _eXPIRY = json['EXPIRY'];
    _fUNDINGMETHOD = json['FUNDINGMETHOD'];
    _iSSUER = json['ISSUER'];
    _iSACTIVE = json['IS_ACTIVE'];
    _id = json['Id'];
    _tOKEN = json['TOKEN'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BRAND'] = _bRAND;
    data['CARD_NUMBER'] = _cARDNUMBER;
    data['EXPIRY'] = _eXPIRY;
    data['FUNDINGMETHOD'] = _fUNDINGMETHOD;
    data['ISSUER'] = _iSSUER;
    data['IS_ACTIVE'] = _iSACTIVE;
    data['Id'] = _id;
    data['TOKEN'] = _tOKEN;
    return data;
  }
}
