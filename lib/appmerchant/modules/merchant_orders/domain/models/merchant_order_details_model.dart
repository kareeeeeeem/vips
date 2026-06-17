class MerchantOrderDetailsModel {
  int? id;
  int? itemId;
  int? orderId;
  double? price;
  List<MerchantVariation>? variation;
  List<MerchantAddOn>? addOns;
  double? discountOnItem;
  String? discountType;
  int? quantity;
  double? taxAmount;
  String? variant;
  String? createdAt;
  String? updatedAt;
  int? itemCampaignId;
  double? totalAddOnPrice;
  String? itemName;
  String? itemImageFullUrl;
  String? itemDescription;

  MerchantOrderDetailsModel({
    this.id,
    this.itemId,
    this.orderId,
    this.price,
    this.variation,
    this.addOns,
    this.discountOnItem,
    this.discountType,
    this.quantity,
    this.taxAmount,
    this.variant,
    this.createdAt,
    this.updatedAt,
    this.itemCampaignId,
    this.totalAddOnPrice,
    this.itemName,
    this.itemImageFullUrl,
    this.itemDescription,
  });

  MerchantOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    itemId = json['item_id'];
    orderId = json['order_id'];
    price = json['price'] != null ? json['price']?.toDouble() : 0.0;
    variation = [];

    if (json['variation'] != null) {
      variation = [];
      json['variation'].forEach((v) {
        variation!.add(MerchantVariation.fromJson(v));
      });
    }

    if (json['add_ons'] != null) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns!.add(MerchantAddOn.fromJson(v));
      });
    }
    discountOnItem = json['discount_on_item']?.toDouble();
    discountType = json['discount_type'];
    quantity = json['quantity'];
    taxAmount = json['tax_amount']?.toDouble();
    variant = json['variant'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    itemCampaignId = json['item_campaign_id'];
    totalAddOnPrice = json['total_add_on_price']?.toDouble();
    itemName = json['item_name'];
    itemImageFullUrl = json['item_image_full_url'];
    itemDescription = json['item_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['item_id'] = itemId;
    data['order_id'] = orderId;
    data['price'] = price;

    if (variation != null) {
      data['variation'] = variation!.map((v) => v.toJson()).toList();
    }

    data['discount_on_item'] = discountOnItem;
    data['discount_type'] = discountType;
    data['quantity'] = quantity;
    data['tax_amount'] = taxAmount;
    data['variant'] = variant;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['item_campaign_id'] = itemCampaignId;
    data['total_add_on_price'] = totalAddOnPrice;
    data['item_name'] = itemName;
    data['item_image_full_url'] = itemImageFullUrl;
    data['item_description'] = itemDescription;
    return data;
  }
}

class MerchantVariation {
  String? type;
  double? price;

  MerchantVariation({this.type, this.price});

  MerchantVariation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    price = json['price']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['price'] = price;
    return data;
  }
}

class MerchantAddOn {
  String? name;
  double? price;
  int? quantity;

  MerchantAddOn({this.name, this.price, this.quantity});

  MerchantAddOn.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price'] != null ? json['price']?.toDouble() : 0.0;
    quantity = int.parse(json['quantity'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}

class MerchantOrderStatusUpdateBody {
  String? token;
  int? orderId;
  String? status;
  String? otp;
  String? processingTime;
  String method = 'put';
  String? reason;

  MerchantOrderStatusUpdateBody({
    this.token,
    this.orderId,
    this.status,
    this.otp,
    this.reason,
    this.processingTime,
  });

  MerchantOrderStatusUpdateBody.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    orderId = json['order_id'];
    status = json['status'];
    otp = json['otp'];
    processingTime = json['processing_time'];
    status = json['_method'];
    reason = json['reason'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['token'] = token ?? '';
    data['order_id'] = orderId.toString();
    data['status'] = status!;
    data['otp'] = otp ?? '';
    data['processing_time'] = processingTime ?? '';
    data['_method'] = method;
    if (reason != '' && reason != null) {
      data['reason'] = reason!;
    }
    return data;
  }
}