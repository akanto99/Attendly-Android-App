// To parse this JSON data, do
//
//     final departmentIndexModel = departmentIndexModelFromJson(jsonString);

import 'dart:convert';

DepartmentIndexModel departmentIndexModelFromJson(String str) => DepartmentIndexModel.fromJson(json.decode(str));

String departmentIndexModelToJson(DepartmentIndexModel data) => json.encode(data.toJson());

class DepartmentIndexModel {
  Data? data;
  int? status;

  DepartmentIndexModel({
    this.data,
    this.status,
  });

  factory DepartmentIndexModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DepartmentIndexModel(); // Return an empty instance if json is null
    return DepartmentIndexModel(
      data: json["data"] != null ? Data.fromJson(json["data"]) : null,
      status: json["status"],
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      "data": data?.toJson(),
      "status": status,
    };
  }
}


class Data {
  int ? currentPage;
  List<Datum> data;
  String ? firstPageUrl;
  int ?from;
  int lastPage;
  String? lastPageUrl;
  List<Link> links;
  dynamic? nextPageUrl;
  String ?path;
  int ?perPage;
  dynamic? prevPageUrl;
  int? to;
  int ?total;

  Data({
    this.currentPage,
    required this.data,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    currentPage: json["current_page"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class Datum {
  int? id;
  String ?deptName;
  String? slug;
  // String? clientSlug;
  String? location;
  String ?details;
  // DateTime? createdAt;
  // DateTime? updatedAt;

  Datum({
    this.id,
    this.deptName,
    this.slug,
    // this.clientSlug,
    this.location,
    this.details,
    // this.createdAt,
    // this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    deptName: json["dept_name"],
    slug: json["slug"],
    // clientSlug: json["client_slug"],
    location: json["location"],
    details: json["details"],
    // createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
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

class Link {
  String ?url;
  String? label;
  bool? active;

  Link({
    this.url,
    this.label,
    this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}
