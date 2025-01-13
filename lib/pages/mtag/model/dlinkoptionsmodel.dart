// ignore_for_file: unnecessary_getters_setters

class Dlinkoptions {
  String? _code;
  List<Data>? _data;
  String? _message;
  int? _cnt;

  Dlinkoptions({String? code, List<Data>? data, String? message, int? cnt}) {
    if (code != null) {
      _code = code;
    }
    if (data != null) {
      _data = data;
    }
    if (message != null) {
      _message = message;
    }
    if (cnt != null) {
      _cnt = cnt;
    }
  }

  String? get code => _code;
  set code(String? code) => _code = code;
  List<Data>? get data => _data;
  set data(List<Data>? data) => _data = data;
  String? get message => _message;
  set message(String? message) => _message = message;
  int? get cnt => _cnt;
  set cnt(int? cnt) => _cnt = cnt;

  Dlinkoptions.fromJson(Map<String, dynamic> json) {
    _code = json['Code'];
    if (json['Data'] != null) {
      _data = <Data>[];
      json['Data'].forEach((v) {
        _data!.add(Data.fromJson(v));
      });
    }
    _message = json['Message'];
    _cnt = json['cnt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = _code;
    if (_data != null) {
      data['Data'] = _data?.map((v) => v.toJson()).toList();
    }
    data['Message'] = _message;
    data['cnt'] = _cnt;
    return data;
  }
}

class Data {
  String? _rDESC;
  String? _rID;

  Data({String? rDESC, String? rID}) {
    if (rDESC != null) {
      _rDESC = rDESC;
    }
    if (rID != null) {
      _rID = rID;
    }
  }

  String? get rDESC => _rDESC;
  set rDESC(String? rDESC) => _rDESC = rDESC;
  String? get rID => _rID;
  set rID(String? rID) => _rID = rID;

  Data.fromJson(Map<String, dynamic> json) {
    _rDESC = json['R_DESC'];
    _rID = json['R_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['R_DESC'] = _rDESC;
    data['R_ID'] = _rID;
    return data;
  }
}
