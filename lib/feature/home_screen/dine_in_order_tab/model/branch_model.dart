class BranchModel {
  BranchModel({
      this.branches,});

  BranchModel.fromJson(dynamic json) {
    if (json['branches'] != null) {
      branches = [];
      json['branches'].forEach((v) {
        branches?.add(Branches.fromJson(v));
      });
    }
  }
  List<Branches>? branches;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (branches != null) {
      map['branches'] = branches?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Branches {
  Branches({
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
      this.map,});

  Branches.fromJson(dynamic json) {
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
    map['map'] = map;
    return map;
  }

}