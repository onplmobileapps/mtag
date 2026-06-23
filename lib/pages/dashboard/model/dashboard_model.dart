// ignore_for_file: non_constant_identifier_names

import 'package:get/get.dart';

class DashBoardModel {
  List<ActiveMtags>? activeMtags;
  String? code;
  int? creditCardRecharge;
  CustomerDetail? customerDetail;
  String? helpLineNumber;
  int? jazzCashRecharge;
  PicturesURL? picturesURL;
  PromotionalPopUpImage? promotionalPopUpImage;
  QuestionPending? questionPending;
  int? rechargeMaxAmount;
  int? rechargeMinAmount;
  VersionCheck? versionCheck;

  DashBoardModel({
    this.activeMtags,
    this.code,
    this.creditCardRecharge,
    this.customerDetail,
    this.helpLineNumber,
    this.jazzCashRecharge,
    this.picturesURL,
    this.promotionalPopUpImage,
    this.questionPending,
    this.rechargeMaxAmount,
    this.rechargeMinAmount,
    this.versionCheck,
  });

  DashBoardModel.fromJson(Map<String, dynamic> json) {
    if (json['ActiveMtags'] != null) {
      activeMtags = <ActiveMtags>[];
      json['ActiveMtags'].forEach((v) {
        activeMtags?.add(ActiveMtags.fromJson(v));
      });
    }
    code = json['Code'];
    creditCardRecharge = json['Credit_Card_Recharge'];
    customerDetail = json['Customer_Detail'] != null
        ? CustomerDetail.fromJson(json['Customer_Detail'])
        : null;
    helpLineNumber = json['HelpLineNumber'];
    jazzCashRecharge = json['Jazz_Cash_Recharge'];
    picturesURL = json['Pictures_URL'] != null
        ? PicturesURL.fromJson(json['Pictures_URL'])
        : null;
    promotionalPopUpImage = json['Promotional_PopUp_Image'] != null
        ? PromotionalPopUpImage.fromJson(json['Promotional_PopUp_Image'])
        : null;
    questionPending = json['Question_Pending'] != null
        ? QuestionPending.fromJson(json['Question_Pending'])
        : null;
    rechargeMaxAmount = json['Recharge_Max_Amount'];
    rechargeMinAmount = json['Recharge_Min_Amount'];
    versionCheck = json['Version_Check'] != null
        ? VersionCheck.fromJson(json['Version_Check'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (activeMtags != null) {
      data['ActiveMtags'] = activeMtags?.map((v) => v.toJson()).toList();
    }
    data['Code'] = code;
    data['Credit_Card_Recharge'] = creditCardRecharge;
    if (customerDetail != null) {
      data['Customer_Detail'] = customerDetail?.toJson();
    }
    data['HelpLineNumber'] = helpLineNumber;
    data['Jazz_Cash_Recharge'] = jazzCashRecharge;
    if (picturesURL != null) {
      data['Pictures_URL'] = picturesURL?.toJson();
    }
    if (promotionalPopUpImage != null) {
      data['Promotional_PopUp_Image'] = promotionalPopUpImage?.toJson();
    }
    if (questionPending != null) {
      data['Question_Pending'] = questionPending?.toJson();
    }
    data['Recharge_Max_Amount'] = rechargeMaxAmount;
    data['Recharge_Min_Amount'] = rechargeMinAmount;
    if (versionCheck != null) {
      data['Version_Check'] = versionCheck?.toJson();
    }
    return data;
  }
}

class ActiveMtags {
  String? balance;
  int? isactive;
  String? issuedate;
  String? mobilenum;
  int? ownNumber;
  String? ownername;
  String? registration;
  String? smsStaus;
  String? tokenno;
  String? vehicletype;
  String? amount;
  String? payId;
  RxBool? isObscured;
  String? chassis_number;
  double? block_amount;
  bool? eto_verified;
  int? block_status;
  String? tag_expiry_date;
  bool? is_expired;

  ActiveMtags({
    this.balance,
    this.isactive,
    this.issuedate,
    this.mobilenum,
    this.ownNumber,
    this.ownername,
    this.registration,
    this.smsStaus,
    this.tokenno,
    this.vehicletype,
    this.amount,
    this.payId,
    this.isObscured,
    this.chassis_number,
    this.block_amount,
    this.eto_verified,
    this.block_status,
    this.tag_expiry_date,
    this.is_expired,
  });

  ActiveMtags.fromJson(Map<String, dynamic> json) {
    balance = json['balance'];
    isactive = json['isactive'] == null
        ? 0
        : (json['isactive'] as num?)?.toInt() ??
              int.tryParse(json['isactive'].toString()) ??
              0;
    issuedate = json['issuedate'];
    mobilenum = json['mobilenum'];
    ownNumber = json['own_number'];
    ownername = json['ownername'];
    registration = json['registration'];
    smsStaus = json['sms_staus'];
    tokenno = json['tokenno'];
    vehicletype = json['vehicletype'];
    chassis_number = json['chassis_number'];
    block_amount = (json['block_amount'] as num?)?.toDouble();
    eto_verified = json['eto_verified'];
    block_status = json['block_status'] == null
        ? 0
        : (json['block_status'] as num?)?.toInt() ??
              int.tryParse(json['block_status'].toString()) ??
              0;
    tag_expiry_date = json['tag_expiry_date'];
    is_expired = json['is_expired'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['balance'] = balance;
    data['isactive'] = isactive;
    data['issuedate'] = issuedate;
    data['mobilenum'] = mobilenum;
    data['own_number'] = ownNumber;
    data['ownername'] = ownername;
    data['registration'] = registration;
    data['sms_staus'] = smsStaus;
    data['tokenno'] = tokenno;
    data['vehicletype'] = vehicletype;
    data['chassis_number'] = chassis_number;
    data['block_amount'] = block_amount;
    data['eto_verified'] = eto_verified;
    data['block_status'] = block_status;
    data['tag_expiry_date'] = tag_expiry_date;
    data['is_expired'] = is_expired;
    return data;
  }
}

class CustomerDetail {
  String? cNIC;
  String? email;
  String? fullName;
  String? mobileNumber;
  String? password;
  int? sim_operator;

  CustomerDetail({
    this.cNIC,
    this.email,
    this.fullName,
    this.mobileNumber,
    this.password,
    this.sim_operator,
  });

  CustomerDetail.fromJson(Map<String, dynamic> json) {
    cNIC = json['CNIC'];
    email = json['Email'];
    fullName = json['Full_Name'];
    mobileNumber = json['Mobile_Number'];
    password = json['Password'];
    sim_operator = json['sim_operator'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CNIC'] = cNIC;
    data['Email'] = email;
    data['Full_Name'] = fullName;
    data['Mobile_Number'] = mobileNumber;
    data['Password'] = password;
    data['sim_operator'] = sim_operator;
    return data;
  }
}

class PicturesURL {
  List<Imgs>? imgs;

  PicturesURL({this.imgs});

  PicturesURL.fromJson(Map<String, dynamic> json) {
    if (json['imgs'] != null) {
      imgs = <Imgs>[];
      json['imgs'].forEach((v) {
        imgs?.add(Imgs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (imgs != null) {
      data['imgs'] = imgs?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Imgs {
  String? name;

  Imgs({this.name});

  Imgs.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}

class PromotionalPopUpImage {
  String? buttonText;
  String? buttonURL;
  String? code;
  String? imgURL;
  String? termsURL;
  String? dialogBtnText;
  String? dialogText;

  PromotionalPopUpImage({
    this.buttonText,
    this.buttonURL,
    this.code,
    this.imgURL,
    this.termsURL,
    this.dialogBtnText,
    this.dialogText,
  });

  PromotionalPopUpImage.fromJson(Map<String, dynamic> json) {
    buttonText = json['ButtonText'];
    buttonURL = json['ButtonURL'];
    code = json['Code'];
    imgURL = json['ImgURL'];
    termsURL = json['TermsURL'];
    dialogBtnText = json['dialog_btn_text'];
    dialogText = json['dialog_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ButtonText'] = buttonText;
    data['ButtonURL'] = buttonURL;
    data['Code'] = code;
    data['ImgURL'] = imgURL;
    data['TermsURL'] = termsURL;
    data['dialog_btn_text'] = dialogBtnText;
    data['dialog_text'] = dialogText;
    return data;
  }
}

class QuestionPending {
  Data? data;
  int? qCnt;

  QuestionPending({this.data, this.qCnt});

  QuestionPending.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? Data.fromJson(json['Data']) : null;
    qCnt = json['q_cnt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    data['q_cnt'] = qCnt;
    return data;
  }
}

class Data {
  String? qId;
  String? question;

  Data({this.qId, this.question});

  Data.fromJson(Map<String, dynamic> json) {
    qId = json['Q_id'];
    question = json['Question'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Q_id'] = qId;
    data['Question'] = question;
    return data;
  }
}

class VersionCheck {
  String? code;
  String? message;

  VersionCheck({this.code, this.message});

  VersionCheck.fromJson(Map<String, dynamic> json) {
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
