class NotificationModel {
  String? code;
  String? message;
  int? cnt;
 
  List<Data>? data;

  NotificationModel({this.code, this.message, this.cnt, this.data,});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    
    message = json['Message'];
    cnt = json['cnt'];
    if (json['Data'] != null) {
      data = <Data>[];
      json['Data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Code'] = code;
    data['Message'] = message;
    data['cnt'] = cnt;
    if (this.data != null) {
      data['Data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? title;
  String? body;
  String? dateTime;
  String? datetimeSmall;
  String? imageLink;
   bool? isSelected=false;

  Data({this.id, this.title, this.body, this.dateTime, this.datetimeSmall, this.imageLink,this.isSelected});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    title = json['Title'];
    body = json['Body'];
    dateTime = json['DateTime'];
    datetimeSmall = json['datetime_small'];
    imageLink = json['image_link'];
 
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Title'] = title;
    data['Body'] = body;
    data['DateTime'] = dateTime;
    data['datetime_small'] = datetimeSmall;
    data['image_link'] = imageLink;
    return data;
  }
}
