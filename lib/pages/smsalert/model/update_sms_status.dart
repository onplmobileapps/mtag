class UpdateSmsStatusModel {
  String? code;
  String? message;

  UpdateSmsStatusModel({this.code, this.message});

  UpdateSmsStatusModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    data['Message'] = message;
    return data;
  }
}
