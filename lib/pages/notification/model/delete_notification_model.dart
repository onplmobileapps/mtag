// ignore_for_file: unnecessary_getters_setters

class DeleteNotificationModel {
  String? _code;
  String? _message;
  int? _cntDeleted;

  DeleteNotificationModel({String? code, String? message, int? cntDeleted}) {
    if (code != null) {
      _code = code;
    }
    if (message != null) {
      _message = message;
    }
    if (cntDeleted != null) {
      _cntDeleted = cntDeleted;
    }
  }

  String? get code => _code;
  set code(String? code) => _code = code;
  String? get message => _message;
  set message(String? message) => _message = message;
  int? get cntDeleted => _cntDeleted;
  set cntDeleted(int? cntDeleted) => _cntDeleted = cntDeleted;

  DeleteNotificationModel.fromJson(Map<String, dynamic> json) {
    _code = json['Code'];
    _message = json['Message'];
    _cntDeleted = json['cnt_deleted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = _code;
    data['Message'] = _message;
    data['cnt_deleted'] = _cntDeleted;
    return data;
  }
}
