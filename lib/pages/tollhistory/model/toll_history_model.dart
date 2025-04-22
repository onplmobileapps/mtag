class TollHistoryModel {
  String? code;
  Data? data;
  String? message;

  TollHistoryModel({this.code, this.data, this.message});

  TollHistoryModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    data = json['Data'] != null ? Data.fromJson(json['Data']) : null;
    message = json['Message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    if (this.data != null) {
      data['Data'] = this.data?.toJson();
    }
    data['Message'] = message;
    return data;
  }
}

class Data {
  List<AllTransactions>? allTransactions;

  Data({this.allTransactions});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['AllTransactions'] != null) {
      allTransactions = <AllTransactions>[];
      json['AllTransactions'].forEach((v) {
        allTransactions!.add(AllTransactions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (allTransactions != null) {
      data['AllTransactions'] = allTransactions?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AllTransactions {
  String? cARREGISTRATION;
  String? cR;
  String? eNTRYSTATIONNAME;
  String? eXITSTATIONNAME;
  String? fARE;
  String? iD;
  String? iTOKKENNO;
  String? tRANSTIME;
  String? uID;

  AllTransactions(
      {this.cARREGISTRATION,
      this.cR,
      this.eNTRYSTATIONNAME,
      this.eXITSTATIONNAME,
      this.fARE,
      this.iD,
      this.iTOKKENNO,
      this.tRANSTIME,
      this.uID});

  AllTransactions.fromJson(Map<String, dynamic> json) {
    cARREGISTRATION = json['CAR_REGISTRATION'];
    cR = json['CR'];
    eNTRYSTATIONNAME = json['ENTRY_STATION_NAME'];
    eXITSTATIONNAME = json['EXIT_STATION_NAME'];
    fARE = json['FARE'];
    iD = json['ID'];
    iTOKKENNO = json['ITOKKENNO'];
    tRANSTIME = json['TRANS_TIME'];
    uID = json['U_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CAR_REGISTRATION'] = cARREGISTRATION;
    data['CR'] = cR;
    data['ENTRY_STATION_NAME'] = eNTRYSTATIONNAME;
    data['EXIT_STATION_NAME'] = eXITSTATIONNAME;
    data['FARE'] = fARE;
    data['ID'] = iD;
    data['ITOKKENNO'] = iTOKKENNO;
    data['TRANS_TIME'] = tRANSTIME;
    data['U_ID'] = uID;
    return data;
  }
}
