class CustomerDetailsModel {
  String? code;
  Data? data;

  CustomerDetailsModel({this.code, this.data});

  CustomerDetailsModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    data = json['Data'] != null ? Data.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['Code'] = code;
    dataMap['Data'] =
        data?.toJson(); // Fixed: Use the 'data' field, not the map itself
    return dataMap;
  }
}

class Data {
  CustomerDetail? customerDetail;

  Data({this.customerDetail});

  Data.fromJson(Map<String, dynamic> json) {
    customerDetail = json['Customer_Detail'] != null
        ? CustomerDetail.fromJson(json['Customer_Detail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (customerDetail != null) {
      data['Customer_Detail'] = customerDetail?.toJson();
    }
    return data;
  }
}

class CustomerDetail {
  String? fullName;
  String? mobileNumber;
  String? cNIC;
  String? password;
  String? email;

  CustomerDetail(
      {this.fullName, this.mobileNumber, this.cNIC, this.password, this.email});

  CustomerDetail.fromJson(Map<String, dynamic> json) {
    fullName = json['Full Name'];
    mobileNumber = json['Mobile Number'];
    cNIC = json['CNIC'];
    password = json['Password'];
    email = json['Email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Full Name'] = fullName;
    data['Mobile Number'] = mobileNumber;
    data['CNIC'] = cNIC;
    data['Password'] = password;
    data['Email'] = email;
    return data;
  }
}
