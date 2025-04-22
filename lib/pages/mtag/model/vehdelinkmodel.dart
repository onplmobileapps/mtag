// ignore_for_file: unnecessary_getters_setters

class DeLinkVehicleModel {
  String? _code;
  String? _message;

  DeLinkVehicleModel({String? code, String? message}) {
    if (code != null) {
      _code = code;
    }
    if (message != null) {
      _message = message;
    }
  }

  String? get code => _code;
  set code(String? code) => _code = code;
  String? get message => _message;
  set message(String? message) => _message = message;

  DeLinkVehicleModel.fromJson(Map<String, dynamic> json) {
    _code = json['Code'];
    _message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = _code;
    data['Message'] = _message;
    return data;
  }
}
