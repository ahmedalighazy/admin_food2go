class OrderList {
  OrderList({
      this.orders,});

  OrderList.fromJson(dynamic json) {
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders?.add(Orders.fromJson(v));
      });
    }
  }
  List<Orders>? orders;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (orders != null) {
      map['orders'] = orders?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Orders {
  Orders({
      this.id, 
      this.orderNumber, 
      this.createdAt, 
      this.amount, 
      this.operationStatus, 
      this.orderStatus, 
      this.source, 
      this.status, 
      this.points, 
      this.rejectedReason, 
      this.transactionId, 
      this.user, 
      this.branch, 
      this.address, 
      this.admin, 
      this.paymentMethod, 
      this.schedule, 
      this.delivery,});

  Orders.fromJson(dynamic json) {
    id = json['id'];
    orderNumber = json['order_number'];
    createdAt = json['created_at'];
    amount = json['amount'];
    operationStatus = json['operation_status'];
    orderStatus = json['order_status'];
    source = json['source'];
    status = json['status'];
    points = json['points'];
    rejectedReason = json['rejected_reason'];
    transactionId = json['transaction_id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    branch = json['branch'] != null ? Branch.fromJson(json['branch']) : null;
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    admin = json['admin'] != null ? Admin.fromJson(json['admin']) : null;
    paymentMethod = json['payment_method'] != null ? PaymentMethod.fromJson(json['payment_method']) : null;
    schedule = json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null;
    delivery = json['delivery'] != null ? Delivery.fromJson(json['delivery']) : null;
  }
  num? id;
  String? orderNumber;
  String? createdAt;
  num? amount;
  String? operationStatus;
  String? orderStatus;
  String? source;
  dynamic status;
  num? points;
  dynamic rejectedReason;
  dynamic transactionId;
  User? user;
  Branch? branch;
  Address? address;
  Admin? admin;
  PaymentMethod? paymentMethod;
  Schedule? schedule;
  Delivery? delivery;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['order_number'] = orderNumber;
    map['created_at'] = createdAt;
    map['amount'] = amount;
    map['operation_status'] = operationStatus;
    map['order_status'] = orderStatus;
    map['source'] = source;
    map['status'] = status;
    map['points'] = points;
    map['rejected_reason'] = rejectedReason;
    map['transaction_id'] = transactionId;
    if (user != null) {
      map['user'] = user?.toJson();
    }
    if (branch != null) {
      map['branch'] = branch?.toJson();
    }
    if (address != null) {
      map['address'] = address?.toJson();
    }
    if (admin != null) {
      map['admin'] = admin?.toJson();
    }
    if (paymentMethod != null) {
      map['payment_method'] = paymentMethod?.toJson();
    }
    if (schedule != null) {
      map['schedule'] = schedule?.toJson();
    }
    if (delivery != null) {
      map['delivery'] = delivery?.toJson();
    }
    return map;
  }

}

class Delivery {
  Delivery({
      this.name,});

  Delivery.fromJson(dynamic json) {
    name = json['name'];
  }
  dynamic name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }

}

class Schedule {
  Schedule({
      this.name,});

  Schedule.fromJson(dynamic json) {
    name = json['name'];
  }
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }

}

class PaymentMethod {
  PaymentMethod({
      this.name,});

  PaymentMethod.fromJson(dynamic json) {
    name = json['name'];
  }
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }

}

class Admin {
  Admin({
      this.name,});

  Admin.fromJson(dynamic json) {
    name = json['name'];
  }
  dynamic name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }

}

class Address {
  Address({
      this.zone,});

  Address.fromJson(dynamic json) {
    zone = json['zone'] != null ? Zone.fromJson(json['zone']) : null;
  }
  Zone? zone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (zone != null) {
      map['zone'] = zone?.toJson();
    }
    return map;
  }

}

class Zone {
  Zone({
      this.zone,});

  Zone.fromJson(dynamic json) {
    zone = json['zone'];
  }
  String? zone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['zone'] = zone;
    return map;
  }

}

class Branch {
  Branch({
      this.name,});

  Branch.fromJson(dynamic json) {
    name = json['name'];
  }
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    return map;
  }

}

class User {
  User({
      this.fName, 
      this.lName, 
      this.phone,});

  User.fromJson(dynamic json) {
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
  }
  String? fName;
  String? lName;
  String? phone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['f_name'] = fName;
    map['l_name'] = lName;
    map['phone'] = phone;
    return map;
  }

}