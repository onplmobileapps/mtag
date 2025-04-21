class StationsModel {
  String? code;
  List<StData>? data;
  String? message;

  StationsModel({this.code, this.data, this.message});

  StationsModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    if (json['Data'] != null) {
      data = <StData>[];
      json['Data'].forEach((v) {
        data?.add(StData.fromJson(v));
      });
    }
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    if (this.data != null) {
      data['Data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['Message'] = message;
    return data;
  }
}

class StData {
  String? stid;
  String? stname;

  StData({this.stid, this.stname});

  StData.fromJson(Map<String, dynamic> json) {
    stid = json['stid']?.toString();
    stname = json['stname']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stid'] = stid;
    data['stname'] = stname;
    return data;
  }
}