import 'dart:convert';

MapApiget mapApigetFromJson(String str) => MapApiget.fromJson(json.decode(str));

String mapApigetToJson(MapApiget data) => json.encode(data.toJson());

class MapApiget {
  bool success;
  Location  location;

  MapApiget({
    required this.success,
    required this.location,
  });

  factory MapApiget.fromJson(Map<String, dynamic> json) => MapApiget(
    success: json["success"],
    location: Location.fromJson(json["location"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "location": location.toJson(),
  };
}

class Location {
  String? firstName;
  String ?lastName;
  String ?email;
  String ?slug;
  String ?latitude;
  String? longitude;

  Location({
    this.firstName,
    this.lastName,
    this.email,
    this.slug,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    slug: json["slug"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "slug": slug,
    "latitude": latitude,
    "longitude": longitude,
  };
}
