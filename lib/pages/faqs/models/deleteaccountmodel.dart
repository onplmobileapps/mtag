// ignore_for_file: unnecessary_getters_setters

class DeleteAccountModel {
  String? _code;
  String? _msg;

  DeleteAccountModel({String? code, String? msg}) {
    if (code != null) {
      _code = code;
    }
    if (msg != null) {
      _msg = msg;
    }
  }

  String? get code => _code;
  set code(String? code) => _code = code;
  String? get msg => _msg;
  set msg(String? msg) => _msg = msg;

  DeleteAccountModel.fromJson(Map<String, dynamic> json) {
    _code = json['Code'];
    _msg = json['Msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = _code;
    data['Msg'] = _msg;
    return data;
  }
}
