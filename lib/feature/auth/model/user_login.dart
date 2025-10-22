class UserLogin {
  UserLogin({
      this.admin, 
      this.token, 
      this.role,});

  UserLogin.fromJson(dynamic json) {
    admin = json['admin'] != null ? Admin.fromJson(json['admin']) : null;
    token = json['token'];
    role = json['role'];
  }
  Admin? admin;
  String? token;
  String? role;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (admin != null) {
      map['admin'] = admin?.toJson();
    }
    map['token'] = token;
    map['role'] = role;
    return map;
  }

}

class Admin {
  Admin({
      this.id, 
      this.name, 
      this.email, 
      this.phone, 
      this.image, 
      this.userPositionId, 
      this.status, 
      this.emailVerifiedAt, 
      this.createdAt, 
      this.updatedAt, 
      this.role, 
      this.token, 
      this.imageLink, 
      this.userPositions,});

  Admin.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'];
    userPositionId = json['user_position_id'];
    status = json['status'];
    emailVerifiedAt = json['email_verified_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    role = json['role'];
    token = json['token'];
    imageLink = json['image_link'];
    userPositions = json['user_positions'] != null ? UserPositions.fromJson(json['user_positions']) : null;
  }
  num? id;
  String? name;
  String? email;
  String? phone;
  dynamic image;
  num? userPositionId;
  num? status;
  dynamic emailVerifiedAt;
  dynamic createdAt;
  String? updatedAt;
  String? role;
  String? token;
  dynamic imageLink;
  UserPositions? userPositions;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['image'] = image;
    map['user_position_id'] = userPositionId;
    map['status'] = status;
    map['email_verified_at'] = emailVerifiedAt;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['role'] = role;
    map['token'] = token;
    map['image_link'] = imageLink;
    if (userPositions != null) {
      map['user_positions'] = userPositions?.toJson();
    }
    return map;
  }

}

class UserPositions {
  UserPositions({
      this.id, 
      this.name, 
      this.status, 
      this.createdAt, 
      this.updatedAt, 
      this.roles,});

  UserPositions.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['roles'] != null) {
      roles = [];
      json['roles'].forEach((v) {
        roles?.add(Roles.fromJson(v));
      });
    }
  }
  num? id;
  String? name;
  num? status;
  String? createdAt;
  String? updatedAt;
  List<Roles>? roles;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    if (roles != null) {
      map['roles'] = roles?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Roles {
  Roles({
      this.id, 
      this.userPositionId, 
      this.role, 
      this.action, 
      this.createdAt, 
      this.updatedAt,});

  Roles.fromJson(dynamic json) {
    id = json['id'];
    userPositionId = json['user_position_id'];
    role = json['role'];
    action = json['action'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  num? userPositionId;
  String? role;
  String? action;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['user_position_id'] = userPositionId;
    map['role'] = role;
    map['action'] = action;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

}