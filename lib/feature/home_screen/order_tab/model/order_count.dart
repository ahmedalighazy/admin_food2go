class OrderCount {
  OrderCount({
      this.orders, 
      this.pending, 
      this.confirmed, 
      this.processing, 
      this.outForDelivery, 
      this.delivered, 
      this.returned, 
      this.faildToDeliver, 
      this.refund, 
      this.canceled, 
      this.scheduled, 
      this.start, 
      this.end,});

  OrderCount.fromJson(dynamic json) {
    orders = json['orders'];
    pending = json['pending'];
    confirmed = json['confirmed'];
    processing = json['processing'];
    outForDelivery = json['out_for_delivery'];
    delivered = json['delivered'];
    returned = json['returned'];
    faildToDeliver = json['faild_to_deliver'];
    refund = json['refund'];
    canceled = json['canceled'];
    scheduled = json['scheduled'];
    start = json['start'];
    end = json['end'];
  }
  num? orders;
  num? pending;
  num? confirmed;
  num? processing;
  num? outForDelivery;
  num? delivered;
  num? returned;
  num? faildToDeliver;
  num? refund;
  num? canceled;
  num? scheduled;
  String? start;
  String? end;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['orders'] = orders;
    map['pending'] = pending;
    map['confirmed'] = confirmed;
    map['processing'] = processing;
    map['out_for_delivery'] = outForDelivery;
    map['delivered'] = delivered;
    map['returned'] = returned;
    map['faild_to_deliver'] = faildToDeliver;
    map['refund'] = refund;
    map['canceled'] = canceled;
    map['scheduled'] = scheduled;
    map['start'] = start;
    map['end'] = end;
    return map;
  }

}