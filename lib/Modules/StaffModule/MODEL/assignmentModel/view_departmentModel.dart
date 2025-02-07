import 'dart:convert';
ViewDepartmentModel viewDepartmentModelFromJson(String str) => ViewDepartmentModel.fromJson(json.decode(str));
String viewDepartmentModelToJson(ViewDepartmentModel data) => json.encode(data.toJson());

class ViewDepartmentModel {
  Data ? data;
  int status;

  ViewDepartmentModel({
     this.data,
    required this.status,
  });

  factory ViewDepartmentModel.fromJson(Map<String, dynamic> json) => ViewDepartmentModel(
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "status": status,
  };
}

class Data {
  int id;
  String ? deptName;
  String ?slug;
  // String ?clientSlug;
  String ?location;
  String ?details;
  // DateTime ?createdAt;
  // DateTime? updatedAt;

  Data({
    required this.id,
     this.deptName,
     this.slug,
     // this.clientSlug,
     this.location,
     this.details,
     // this.createdAt,
     // this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    deptName: json["dept_name"],
    slug: json["slug"],
    // clientSlug: json["client_slug"],
    location: json["location"],
    details: json["details"],
    // createdAt: DateTime.parse(json["created_at"]),
    // updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dept_name": deptName,
    "slug": slug,
    // "client_slug": clientSlug,
    "location": location,
    "details": details,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
  };
}
