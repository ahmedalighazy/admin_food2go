class ProfileModel {
  ProfileModel({
      this.name, 
      this.email, 
      this.phone, 
      this.image,});

  ProfileModel.fromJson(dynamic json) {
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'];
  }
  String? name;
  String? email;
  String? phone;
  String? image;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['image'] = image;
    return map;
  }

}