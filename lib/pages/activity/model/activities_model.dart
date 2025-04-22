class ActivitiesModel {
  List<CardDataX>? cardData;
  String? code;
  String? message;
  List<TransData>? transData;
  List<JazzcashData>? jazzcashData;

  ActivitiesModel({this.cardData, this.code, this.message, this.transData, this.jazzcashData});

  ActivitiesModel.fromJson(Map<String, dynamic> json) {
    if (json['Card_Data'] != null) {
      cardData = <CardDataX>[];
      json['Card_Data'].forEach((v) {
        cardData?.add(CardDataX.fronJson(v));
      });
    }
    code = json['Code'];
    message = json['Message'];
    if (json['Trans_Data'] != null) {
      transData = <TransData>[];
      json['Trans_Data'].forEach((v) {
        transData?.add(TransData.fromJson(v));
      });
    }
    if (json['jazzcash_Data'] != null) {
      jazzcashData = <JazzcashData>[];
      json['jazzcash_Data'].forEach((v) {
        jazzcashData?.add(JazzcashData.fromjson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cardData != null) {
      data['Card_Data'] = cardData?.map((v) => v.toString()).toList();
    }
    data['Code'] = code;
    data['Message'] = message;
    if (transData != null) {
      data['Trans_Data'] = transData?.map((v) => v.toJson()).toList();
    }
    if (jazzcashData != null) {
      data['jazzcash_Data'] = jazzcashData?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CardDataX {
  String? id, token, brand, expiry, fundingMethod, cardNumber, isActive, issuer, nameOnCard, cnt;
  CardDataX({
    this.brand,
    this.id,
    this.cardNumber,
    this.token,
    this.cnt,
    this.expiry,
    this.fundingMethod,
    this.isActive,
    this.issuer,
    this.nameOnCard,
  });
  factory CardDataX.fronJson(Map<String, dynamic> json) {
    return CardDataX(
      id: json['Id'],
      token: json['TOKEN'],
      brand: json['BRAND'],
      expiry: json['EXPIRY'],
      fundingMethod: json['FUNDINGMETHOD'],
      cardNumber: json['CARD_NUMBER'],
      isActive: json['IS_ACTIVE'],
      issuer: json['ISSUER'],
      nameOnCard: json['NAMEONCARD'],
      cnt: json['cnt'],
    );
  }
}

class JazzcashData {
  String? cardNumber, issuer, isActive, id, nsmeOnCard, token, cnt;
  JazzcashData({
    this.cardNumber,
    this.cnt,
    this.id,
    this.isActive,
    this.issuer,
    this.nsmeOnCard,
    this.token,
  });
  factory JazzcashData.fromjson(Map<String, dynamic> json) {
    return JazzcashData(
      cardNumber: json['CARD_NUMBER'],
      id: json['Id'],
      isActive: json['IS_ACTIVE'],
      issuer: json['ISSUER'],
      nsmeOnCard: json['NAMEONCARD'],
      cnt: json['cnt'],
      token: json['TOKEN'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CARD_NUMBER': cardNumber,
      'IS_ACTIVE': isActive,
      'ISSUER': issuer,
      'NAMEONCARD': nsmeOnCard,
      'cnt': cnt,
    };
  }
}

class TransData {
  String? amount;
  String? autoId;
  String? cardNumber;
  String? cnt;
  String? logDate;
  String? mtagId;
  String? orderId;
  String? registration;

  TransData(
      {this.amount,
      this.autoId,
      this.cardNumber,
      this.cnt,
      this.logDate,
      this.mtagId,
      this.orderId,
      this.registration});

  TransData.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    autoId = json['auto_id'];
    cardNumber = json['card_number'];
    cnt = json['cnt'];
    logDate = json['log_date'];
    mtagId = json['mtag_id'];
    orderId = json['order_id'];
    registration = json['registration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['auto_id'] = autoId;
    data['card_number'] = cardNumber;
    data['cnt'] = cnt;
    data['log_date'] = logDate;
    data['mtag_id'] = mtagId;
    data['order_id'] = orderId;
    data['registration'] = registration;
    return data;
  }
}
