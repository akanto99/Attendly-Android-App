import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  dynamic id;
  String ?message;
  String? role;
  String? image;
  String? name;
  String? token;
  String ?latitude;
  String ?longitude;

  UserModel({
    this.id,
    this.message,
    this.role,
    this.image,
    this.name,
    this.token,
    this.latitude,
    this.longitude,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    message: json["message"],
    role: json["role"],
    image: json["image"],
    name: json["name"],
    token: json["token"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "message": message,
    "role": role,
    "image": image,
    "name": name,
    "token": token,
    "latitude": latitude,
    "longitude": longitude,
  };
}

