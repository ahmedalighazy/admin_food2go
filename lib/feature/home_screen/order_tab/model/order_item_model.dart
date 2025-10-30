class OrderItemModel {
  OrderItemModel({
    this.order,
    this.deliveries,
    this.orderStatus,
    this.preparingTime,
    this.logOrder,
    this.branches,
  });

  OrderItemModel.fromJson(dynamic json) {
    order = json['order'] != null ? Order.fromJson(json['order']) : null;
    if (json['deliveries'] != null) {
      deliveries = [];
      json['deliveries'].forEach((v) {
        deliveries?.add(Deliveries.fromJson(v));
      });
    }
    orderStatus = json['order_status'] != null ? json['order_status'].cast<String>() : [];
    preparingTime = json['preparing_time'] != null ? PreparingTime.fromJson(json['preparing_time']) : null;
    if (json['log_order'] != null) {
      logOrder = [];
      json['log_order'].forEach((v) {
        logOrder?.add(v);
      });
    }
    if (json['branches'] != null) {
      branches = [];
      json['branches'].forEach((v) {
        branches?.add(Branches.fromJson(v));
      });
    }
  }

  Order? order;
  List<Deliveries>? deliveries;
  List<String>? orderStatus;
  PreparingTime? preparingTime;
  List<dynamic>? logOrder;
  List<Branches>? branches;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (order != null) {
      map['order'] = order?.toJson();
    }
    if (deliveries != null) {
      map['deliveries'] = deliveries?.map((v) => v.toJson()).toList();
    }
    map['order_status'] = orderStatus;
    if (preparingTime != null) {
      map['preparing_time'] = preparingTime?.toJson();
    }
    if (logOrder != null) {
      map['log_order'] = logOrder;
    }
    if (branches != null) {
      map['branches'] = branches?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Branches {
  Branches({
    this.name,
    this.id,
    this.role,
    this.imageLink,
    this.coverImageLink,
    this.map,
  });

  Branches.fromJson(dynamic json) {
    name = json['name'];
    id = json['id'];
    role = json['role'];
    imageLink = json['image_link'];
    coverImageLink = json['cover_image_link'];
    map = json['map'];
  }

  String? name;
  num? id;
  String? role;
  dynamic imageLink;
  dynamic coverImageLink;
  dynamic map;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['id'] = id;
    map['role'] = role;
    map['image_link'] = imageLink;
    map['cover_image_link'] = coverImageLink;
    map['map'] = this.map;
    return map;
  }
}

class PreparingTime {
  PreparingTime({
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
  });

  PreparingTime.fromJson(dynamic json) {
    days = json['days'];
    hours = json['hours'];
    minutes = json['minutes'];
    seconds = json['seconds'];
  }

  num? days;
  num? hours;
  num? minutes;
  num? seconds;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['days'] = days;
    map['hours'] = hours;
    map['minutes'] = minutes;
    map['seconds'] = seconds;
    return map;
  }
}

class Deliveries {
  Deliveries({
    this.id,
    this.fName,
    this.lName,
    this.role,
    this.imageLink,
    this.identityImageLink,
  });

  Deliveries.fromJson(dynamic json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    role = json['role'];
    imageLink = json['image_link'];
    identityImageLink = json['identity_image_link'];
  }

  num? id;
  String? fName;
  String? lName;
  String? role;
  dynamic imageLink;
  dynamic identityImageLink;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['f_name'] = fName;
    map['l_name'] = lName;
    map['role'] = role;
    map['image_link'] = imageLink;
    map['identity_image_link'] = identityImageLink;
    return map;
  }
}

class Order {
  Order({
    this.id,
    this.receipt,
    this.date,
    this.userId,
    this.branchId,
    this.amount,
    this.orderStatus,
    this.orderType,
    this.paymentStatus,
    this.totalTax,
    this.totalDiscount,
    this.createdAt,
    this.updatedAt,
    this.pos,
    this.deliveryId,
    this.addressId,
    this.source,
    this.notes,
    this.couponDiscount,
    this.orderNumber,
    this.paymentMethodId,
    this.orderDetails,
    this.status,
    this.points,
    this.rejectedReason,
    this.transactionId,
    this.customerCancelReason,
    this.adminCancelReason,
    this.secheduleSlotId,
    this.orderDate,
    this.statusPayment,
    this.orderDetailsData,
    this.delivery,
    this.paymentMethod,
    this.address,
    this.admin,
    this.schedule,
    this.user,
    this.branch,
  });

  Order.fromJson(dynamic json) {
    id = json['id'];
    receipt = json['receipt'];
    date = json['date'];
    userId = json['user_id'];
    branchId = json['branch_id'];
    amount = json['amount'];
    orderStatus = json['order_status'];
    orderType = json['order_type'];
    paymentStatus = json['payment_status'];
    totalTax = json['total_tax'];
    totalDiscount = json['total_discount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    pos = json['pos'];
    deliveryId = json['delivery_id'];
    addressId = json['address_id'];
    source = json['source'];
    notes = json['notes'];
    couponDiscount = json['coupon_discount'];
    orderNumber = json['order_number'];
    paymentMethodId = json['payment_method_id'];
    if (json['order_details'] != null) {
      orderDetails = [];
      json['order_details'].forEach((v) {
        orderDetails?.add(OrderDetails.fromJson(v));
      });
    }
    status = json['status'];
    points = json['points'];
    rejectedReason = json['rejected_reason'];
    transactionId = json['transaction_id'];
    customerCancelReason = json['customer_cancel_reason'];
    adminCancelReason = json['admin_cancel_reason'];
    secheduleSlotId = json['sechedule_slot_id'];
    orderDate = json['order_date'];
    statusPayment = json['status_payment'];
    if (json['order_details_data'] != null) {
      orderDetailsData = [];
      json['order_details_data'].forEach((v) {
        orderDetailsData?.add(OrderDetailsData.fromJson(v));
      });
    }
    delivery = json['delivery'];
    paymentMethod = json['payment_method'] != null ? PaymentMethod.fromJson(json['payment_method']) : null;
    address = json['address'];
    admin = json['admin'];
    schedule = json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null;
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
  }

  num? id;
  dynamic receipt;
  String? date;
  num? userId;
  num? branchId;
  num? amount;
  String? orderStatus;
  String? orderType;
  dynamic paymentStatus;
  num? totalTax;
  num? totalDiscount;
  String? createdAt;
  String? updatedAt;
  num? pos;
  dynamic deliveryId;
  dynamic addressId;
  String? source;
  dynamic notes;
  num? couponDiscount;
  String? orderNumber;
  num? paymentMethodId;
  List<OrderDetails>? orderDetails;
  dynamic status;
  num? points;
  dynamic rejectedReason;
  dynamic transactionId;
  dynamic customerCancelReason;
  dynamic adminCancelReason;
  num? secheduleSlotId;
  String? orderDate;
  String? statusPayment;
  List<OrderDetailsData>? orderDetailsData;
  dynamic delivery;
  PaymentMethod? paymentMethod;
  dynamic address;
  dynamic admin;
  Schedule? schedule;
  User? user;
  Branch? branch;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['receipt'] = receipt;
    map['date'] = date;
    map['user_id'] = userId;
    map['branch_id'] = branchId;
    map['amount'] = amount;
    map['order_status'] = orderStatus;
    map['order_type'] = orderType;
    map['payment_status'] = paymentStatus;
    map['total_tax'] = totalTax;
    map['total_discount'] = totalDiscount;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['pos'] = pos;
    map['delivery_id'] = deliveryId;
    map['address_id'] = addressId;
    map['source'] = source;
    map['notes'] = notes;
    map['coupon_discount'] = couponDiscount;
    map['order_number'] = orderNumber;
    map['payment_method_id'] = paymentMethodId;
    if (orderDetails != null) {
      map['order_details'] = orderDetails?.map((v) => v.toJson()).toList();
    }
    map['status'] = status;
    map['points'] = points;
    map['rejected_reason'] = rejectedReason;
    map['transaction_id'] = transactionId;
    map['customer_cancel_reason'] = customerCancelReason;
    map['admin_cancel_reason'] = adminCancelReason;
    map['sechedule_slot_id'] = secheduleSlotId;
    map['order_date'] = orderDate;
    map['status_payment'] = statusPayment;
    if (orderDetailsData != null) {
      map['order_details_data'] = orderDetailsData?.map((v) => v.toJson()).toList();
    }
    map['delivery'] = delivery;
    if (paymentMethod != null) {
      map['payment_method'] = paymentMethod?.toJson();
    }
    map['address'] = address;
    map['admin'] = admin;
    if (schedule != null) {
      map['schedule'] = schedule?.toJson();
    }
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (branch != null) {
      map['branch'] = branch?.toJson();
    }
    return map;
  }
}

class Branch {
  Branch({
    this.id,
    this.name,
    this.address,
    this.email,
    this.phone,
    this.image,
    this.coverImage,
    this.foodPreparionTime,
    this.latitude,
    this.longitude,
    this.coverage,
    this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.cityId,
    this.main,
    this.phoneStatus,
    this.blockReason,
    this.role,
    this.imageLink,
    this.coverImageLink,
    this.map,
  });

  Branch.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'];
    coverImage = json['cover_image'];
    foodPreparionTime = json['food_preparion_time'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    coverage = json['coverage'];
    status = json['status'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cityId = json['city_id'];
    main = json['main'];
    phoneStatus = json['phone_status'];
    blockReason = json['block_reason'];
    role = json['role'];
    imageLink = json['image_link'];
    coverImageLink = json['cover_image_link'];
    map = json['map'];
  }

  num? id;
  String? name;
  String? address;
  String? email;
  String? phone;
  String? image;
  String? coverImage;
  String? foodPreparionTime;
  num? latitude;
  String? longitude;
  String? coverage;
  num? status;
  dynamic emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  num? cityId;
  num? main;
  num? phoneStatus;
  dynamic blockReason;
  String? role;
  String? imageLink;
  String? coverImageLink;
  String? map;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['address'] = address;
    map['email'] = email;
    map['phone'] = phone;
    map['image'] = image;
    map['cover_image'] = coverImage;
    map['food_preparion_time'] = foodPreparionTime;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['coverage'] = coverage;
    map['status'] = status;
    map['email_verified_at'] = emailVerifiedAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['city_id'] = cityId;
    map['main'] = main;
    map['phone_status'] = phoneStatus;
    map['block_reason'] = blockReason;
    map['role'] = role;
    map['image_link'] = imageLink;
    map['cover_image_link'] = coverImageLink;
    map['map'] = this.map;
    return map;
  }
}

class User {
  User({
    this.id,
    this.fName,
    this.lName,
    this.email,
    this.phone,
    this.image,
    this.wallet,
    this.status,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.points,
    this.bio,
    this.code,
    this.phone2,
    this.googleId,
    this.signupPos,
    this.deletedAt,
    this.dueStatus,
    this.maxDue,
    this.due,
    this.role,
    this.ordersCount,
    this.imageLink,
    this.name,
    this.type,
    this.ordersCountBranch,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'];
    wallet = json['wallet'];
    status = json['status'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    points = json['points'];
    bio = json['bio'];
    code = json['code'];
    phone2 = json['phone_2'];
    googleId = json['google_id'];
    signupPos = json['signup_pos'];
    deletedAt = json['deleted_at'];
    dueStatus = json['due_status'];
    maxDue = json['max_due'];
    due = json['due'];
    role = json['role'];
    ordersCount = json['orders_count'];
    imageLink = json['image_link'];
    name = json['name'];
    type = json['type'];
    ordersCountBranch = json['orders_count_branch'];
  }

  num? id;
  String? fName;
  String? lName;
  String? email;
  String? phone;
  String? image;
  num? wallet;
  num? status;
  dynamic emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  num? points;
  String? bio;
  dynamic code;
  String? phone2;
  dynamic googleId;
  num? signupPos;
  num? deletedAt;
  num? dueStatus;
  num? maxDue;
  num? due;
  String? role;
  num? ordersCount;
  String? imageLink;
  String? name;
  String? type;
  num? ordersCountBranch;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['f_name'] = fName;
    map['l_name'] = lName;
    map['email'] = email;
    map['phone'] = phone;
    map['image'] = image;
    map['wallet'] = wallet;
    map['status'] = status;
    map['email_verified_at'] = emailVerifiedAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['points'] = points;
    map['bio'] = bio;
    map['code'] = code;
    map['phone_2'] = phone2;
    map['google_id'] = googleId;
    map['signup_pos'] = signupPos;
    map['deleted_at'] = deletedAt;
    map['due_status'] = dueStatus;
    map['max_due'] = maxDue;
    map['due'] = due;
    map['role'] = role;
    map['orders_count'] = ordersCount;
    map['image_link'] = imageLink;
    map['name'] = name;
    map['type'] = type;
    map['orders_count_branch'] = ordersCountBranch;
    return map;
  }
}

class Schedule {
  Schedule({
    this.id,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Schedule.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  num? id;
  String? name;
  num? status;
  dynamic createdAt;
  dynamic updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}

class PaymentMethod {
  PaymentMethod({
    this.id,
    this.name,
    this.logo,
    this.logoLink,
  });

  PaymentMethod.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    logoLink = json['logo_link'];
  }

  num? id;
  String? name;
  String? logo;
  String? logoLink;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['logo'] = logo;
    map['logo_link'] = logoLink;
    return map;
  }
}

class OrderDetailsData {
  OrderDetailsData({
    this.extras,
    this.addons,
    this.excludes,
    this.product,
    this.variations,
  });

  OrderDetailsData.fromJson(dynamic json) {
    if (json['extras'] != null) {
      extras = [];
      json['extras'].forEach((v) {
        extras?.add(v);
      });
    }
    if (json['addons'] != null) {
      addons = [];
      json['addons'].forEach((v) {
        addons?.add(v);
      });
    }
    if (json['excludes'] != null) {
      excludes = [];
      json['excludes'].forEach((v) {
        excludes?.add(v);
      });
    }
    if (json['product'] != null) {
      product = [];
      json['product'].forEach((v) {
        product?.add(ProductItem.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = [];
      json['variations'].forEach((v) {
        variations?.add(v);
      });
    }
  }

  List<dynamic>? extras;
  List<dynamic>? addons;
  List<dynamic>? excludes;
  List<ProductItem>? product;
  List<dynamic>? variations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (extras != null) {
      map['extras'] = extras;
    }
    if (addons != null) {
      map['addons'] = addons;
    }
    if (excludes != null) {
      map['excludes'] = excludes;
    }
    if (product != null) {
      map['product'] = product?.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      map['variations'] = variations;
    }
    return map;
  }
}

class ProductItem {
  ProductItem({
    this.product,
    this.count,
    this.notes,
  });

  ProductItem.fromJson(dynamic json) {
    product = json['product'] != null ? Product.fromJson(json['product']) : null;
    count = json['count'];
    notes = json['notes'];
  }

  Product? product;
  num? count;
  dynamic notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (product != null) {
      map['product'] = product?.toJson();
    }
    map['count'] = count;
    map['notes'] = notes;
    return map;
  }
}

class Product {
  Product({
    this.id,
    this.allExtras,
    this.taxes,
    this.name,
    this.description,
    this.image,
    this.categoryId,
    this.subCategoryId,
    this.itemType,
    this.stockType,
    this.number,
    this.price,
    this.priceAfterDiscount,
    this.priceAfterTax,
    this.discountVal,
    this.taxVal,
    this.productTimeStatus,
    this.from,
    this.to,
    this.discountId,
    this.taxId,
    this.status,
    this.recommended,
    this.points,
    this.imageLink,
    this.ordersCount,
    this.discount,
    this.tax,
    this.addons,
    this.favourite,
    this.createdAt,
    this.updatedAt,
    this.taxObj,
  });

  Product.fromJson(dynamic json) {
    id = json['id'];
    if (json['allExtras'] != null) {
      allExtras = [];
      json['allExtras'].forEach((v) {
        allExtras?.add(v);
      });
    }
    taxes = json['taxes'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    categoryId = json['category_id'];
    subCategoryId = json['sub_category_id'];
    itemType = json['item_type'];
    stockType = json['stock_type'];
    number = json['number'];
    price = json['price'];
    priceAfterDiscount = json['price_after_discount'];
    priceAfterTax = json['price_after_tax'];
    discountVal = json['discount_val'];
    taxVal = json['tax_val'];
    productTimeStatus = json['product_time_status'];
    from = json['from'];
    to = json['to'];
    discountId = json['discount_id'];
    taxId = json['tax_id'];
    status = json['status'];
    recommended = json['recommended'];
    points = json['points'];
    imageLink = json['image_link'];
    ordersCount = json['orders_count'];
    discount = json['discount'];
    tax = json['tax'];
    if (json['addons'] != null) {
      addons = [];
      json['addons'].forEach((v) {
        addons?.add(v);
      });
    }
    favourite = json['favourite'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    taxObj = json['tax_obj'];
  }

  num? id;
  List<dynamic>? allExtras;
  String? taxes;
  String? name;
  dynamic description;
  String? image;
  num? categoryId;
  dynamic subCategoryId;
  String? itemType;
  String? stockType;
  dynamic number;
  num? price;
  num? priceAfterDiscount;
  num? priceAfterTax;
  num? discountVal;
  num? taxVal;
  num? productTimeStatus;
  dynamic from;
  dynamic to;
  dynamic discountId;
  dynamic taxId;
  num? status;
  num? recommended;
  num? points;
  String? imageLink;
  num? ordersCount;
  dynamic discount;
  dynamic tax;
  List<dynamic>? addons;
  bool? favourite;
  String? createdAt;
  String? updatedAt;
  dynamic taxObj;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    if (allExtras != null) {
      map['allExtras'] = allExtras;
    }
    map['taxes'] = taxes;
    map['name'] = name;
    map['description'] = description;
    map['image'] = image;
    map['category_id'] = categoryId;
    map['sub_category_id'] = subCategoryId;
    map['item_type'] = itemType;
    map['stock_type'] = stockType;
    map['number'] = number;
    map['price'] = price;
    map['price_after_discount'] = priceAfterDiscount;
    map['price_after_tax'] = priceAfterTax;
    map['discount_val'] = discountVal;
    map['tax_val'] = taxVal;
    map['product_time_status'] = productTimeStatus;
    map['from'] = from;
    map['to'] = to;
    map['discount_id'] = discountId;
    map['tax_id'] = taxId;
    map['status'] = status;
    map['recommended'] = recommended;
    map['points'] = points;
    map['image_link'] = imageLink;
    map['orders_count'] = ordersCount;
    map['discount'] = discount;
    map['tax'] = tax;
    if (addons != null) {
      map['addons'] = addons;
    }
    map['favourite'] = favourite;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['tax_obj'] = taxObj;
    return map;
  }
}

class OrderDetails {
  OrderDetails({
    this.extras,
    this.addons,
    this.excludes,
    this.product,
    this.variations,
  });

  OrderDetails.fromJson(dynamic json) {
    if (json['extras'] != null) {
      extras = [];
      json['extras'].forEach((v) {
        extras?.add(v);
      });
    }
    if (json['addons'] != null) {
      addons = [];
      json['addons'].forEach((v) {
        addons?.add(v);
      });
    }
    if (json['excludes'] != null) {
      excludes = [];
      json['excludes'].forEach((v) {
        excludes?.add(v);
      });
    }
    if (json['product'] != null) {
      product = [];
      json['product'].forEach((v) {
        product?.add(ProductItem.fromJson(v));
      });
    }
    if (json['variations'] != null) {
      variations = [];
      json['variations'].forEach((v) {
        variations?.add(v);
      });
    }
  }

  List<dynamic>? extras;
  List<dynamic>? addons;
  List<dynamic>? excludes;
  List<ProductItem>? product;
  List<dynamic>? variations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (extras != null) {
      map['extras'] = extras;
    }
    if (addons != null) {
      map['addons'] = addons;
    }
    if (excludes != null) {
      map['excludes'] = excludes;
    }
    if (product != null) {
      map['product'] = product?.map((v) => v.toJson()).toList();
    }
    if (variations != null) {
      map['variations'] = variations;
    }
    return map;
  }
}