class MotorwayModel {
  String? code;
  List<Data>? data;
  String? message;
  int? cnt;

  MotorwayModel({this.code, this.data, this.message, this.cnt});

  MotorwayModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    if (json['Data'] != null) {
      data = <Data>[];
      json['Data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
    message = json['Message'];
    cnt = json['cnt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    if (this.data != null) {
      data['Data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['Message'] = message;
    data['cnt'] = cnt;
    return data;
  }
}

class Data {
  String? mWDESC;
  String? mWID;
  String? mWNAME;
  String? mWSHORTNAME;

  Data({this.mWDESC, this.mWID, this.mWNAME, this.mWSHORTNAME});

  Data.fromJson(Map<String, dynamic> json) {
    mWDESC = json['MW_DESC'];
    mWID = json['MW_ID'];
    mWNAME = json['MW_NAME'];
    mWSHORTNAME = json['MW_SHORT_NAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['MW_DESC'] = mWDESC;
    data['MW_ID'] = mWID;
    data['MW_NAME'] = mWNAME;
    data['MW_SHORT_NAME'] = mWSHORTNAME;
    return data;
  }
}
