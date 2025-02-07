import 'dart:convert';

ClientAllMapMarkerModel clientAllMapMarkerModelFromJson(String str) => ClientAllMapMarkerModel.fromJson(json.decode(str));
String clientAllMapMarkerModelToJson(ClientAllMapMarkerModel data) => json.encode(data.toJson());

class ClientAllMapMarkerModel {
  bool? success;
  List<Datum>? data;
  int? status;

  ClientAllMapMarkerModel({
    this.success,
    this.data,
    this.status,
  });

  factory ClientAllMapMarkerModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ClientAllMapMarkerModel();
    return ClientAllMapMarkerModel(
      success: json["success"],
      data: (json["data"] != null)
          ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
          : null, // Handle null data
      status: json["status"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": (data != null) ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
      "status": status,
    };
  }
}

class Datum {
  String? slug;
  String? firstName;
  String? lastName;
  String? latitude;
  String? longitude;

  Datum({
    this.slug,
    this.firstName,
    this.lastName,
    this.latitude,
    this.longitude,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        slug: json["slug"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        latitude: json["latitude"],
        longitude: json["longitude"],
      );

  Map<String, dynamic> toJson() => {
        "slug": slug,
        "first_name": firstName,
        "last_name": lastName,
        "latitude": latitude,
        "longitude": longitude,
      };
}
