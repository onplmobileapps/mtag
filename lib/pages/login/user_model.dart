class UserModel {
  String? code;
  Data? data;

  UserModel({this.code, this.data});

  UserModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    data = json['Data'] != null ? Data.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    if (this.data != null) {
      data['Data'] = this.data?.toJson();
    }
    return data;
  }
}

class Data {
  String? cNICNUMBER;
  String? fULLNAME;
  String? mOBILENUMBER;
  String? accessToken;
  bool? iscoporate;

  Data({
    this.cNICNUMBER,
    this.fULLNAME,
    this.mOBILENUMBER,
    this.accessToken,
    this.iscoporate,
  });

  Data.fromJson(Map<String, dynamic> json) {
    cNICNUMBER = json['CNICNUMBER'];
    fULLNAME = json['FULLNAME'];
    mOBILENUMBER = json['MOBILENUMBER'];
    accessToken = json['access_token'];
    iscoporate = json['is_corporate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CNICNUMBER'] = cNICNUMBER;
    data['FULLNAME'] = fULLNAME;
    data['MOBILENUMBER'] = mOBILENUMBER;
    data['access_token'] = accessToken;
    data['is_corporate'] = iscoporate;
    return data;
  }
}
