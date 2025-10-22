class DineModel {
  DineModel({
    this.orders,
    this.tables,
  });

  DineModel.fromJson(dynamic json) {
    if (json['orders'] != null) {
      orders = [];
      json['orders'].forEach((v) {
        orders?.add(Orders.fromJson(v));
      });
    }
    if (json['tables'] != null) {
      tables = [];
      json['tables'].forEach((v) {
        tables?.add(Tables.fromJson(v));
      });
    }
  }

  List<Orders>? orders;
  List<Tables>? tables;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (orders != null) {
      map['orders'] = orders?.map((v) => v.toJson()).toList();
    }
    if (tables != null) {
      map['tables'] = tables?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Tables {
  Tables({
    this.id,
    this.tableNumber,
    this.capacity,
    this.branchId,
    this.isMerge,
    this.subTable,
    this.location,
  });

  Tables.fromJson(dynamic json) {
    id = json['id'];
    tableNumber = json['table_number'];
    capacity = json['capacity'];
    branchId = json['branch_id'];
    isMerge = json['is_merge'];
    if (json['sub_table'] != null) {
      subTable = [];
      json['sub_table'].forEach((v) {
        // Changed from Dynamic.fromJson(v) to just v
        // Since sub_table can contain any type of data
        subTable?.add(v);
      });
    }
    location = json['location'];
  }

  num? id;
  String? tableNumber;
  num? capacity;
  num? branchId;
  num? isMerge;
  List<dynamic>? subTable;
  String? location;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['table_number'] = tableNumber;
    map['capacity'] = capacity;
    map['branch_id'] = branchId;
    map['is_merge'] = isMerge;
    if (subTable != null) {
      map['sub_table'] = subTable;
    }
    map['location'] = location;
    return map;
  }
}

class Orders {
  Orders({
    this.id,
    this.branchId,
    this.amount,
    this.orderStatus,
    this.orderType,
    this.totalTax,
    this.totalDiscount,
    this.orderNumber,
    this.table,
    this.captain,
    this.type,
  });

  Orders.fromJson(dynamic json) {
    id = json['id'];
    branchId = json['branch_id'];
    amount = json['amount'];
    orderStatus = json['order_status'];
    orderType = json['order_type'];
    totalTax = json['total_tax'];
    totalDiscount = json['total_discount'];
    orderNumber = json['order_number'];
    table = json['table'];
    captain = json['captain'];
    type = json['type'];
  }

  num? id;
  num? branchId;
  num? amount;
  String? orderStatus;
  String? orderType;
  num? totalTax;
  num? totalDiscount;
  String? orderNumber;
  dynamic table;
  dynamic captain;
  String? type;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['branch_id'] = branchId;
    map['amount'] = amount;
    map['order_status'] = orderStatus;
    map['order_type'] = orderType;
    map['total_tax'] = totalTax;
    map['total_discount'] = totalDiscount;
    map['order_number'] = orderNumber;
    map['table'] = table;
    map['captain'] = captain;
    map['type'] = type;
    return map;
  }
}