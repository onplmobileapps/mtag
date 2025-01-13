class UpdateEmailModel {
  String? code;
  String? msg;

  UpdateEmailModel({String? code, String? msg});

  UpdateEmailModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    msg = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    data['Message'] = msg;
    return data;
  }
}
