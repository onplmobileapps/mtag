class StationsModel {
  String? code;
  List<Data>? data;
  String? message;

  StationsModel({this.code, this.data, this.message});

  StationsModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    if (json['Data'] != null) {
      data = <Data>[];
      json['Data'].forEach((v) {
        data?.add(Data.fromJson(v));
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

class Data {
  String? stid;
  String? stname;

  Data({this.stid, this.stname});

  Data.fromJson(Map<String, dynamic> json) {
    stid = json['stid'];
    stname = json['stname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stid'] = stid;
    data['stname'] = stname;
    return data;
  }
}
