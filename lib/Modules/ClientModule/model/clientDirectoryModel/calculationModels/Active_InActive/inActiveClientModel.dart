import 'dart:convert';

InActiveClientModel inActiveClientModelFromJson(String str) => InActiveClientModel.fromJson(json.decode(str));

String inActiveClientModelToJson(InActiveClientModel data) => json.encode(data.toJson());

class InActiveClientModel {
  List<Datum>? data;
  int status;

  InActiveClientModel({
    this.data,
    required this.status,
  });

  factory InActiveClientModel.fromJson(Map<String, dynamic> json) => InActiveClientModel(
    data: json["data"] != null ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))) : null,
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
    "status": status,
  };
}

class Datum {
  int id;
  // String? slug;
  // String? clientSlug;
  // String ?driverSlug;
  // String ?clientChargeRate;
  // String ?driverPayRate;
  // String ?offDays;
  // dynamic deptSlug;
  // String ?startTime;
  // String ?endTime;
  // String ?status;
  String ? AssignmentNumber;
  // DateTime? createdAt;
  // DateTime? updatedAt;
  Clients clients;
  Clients drivers;

  Datum({
    required this.id,
    // this.slug,
    // this.clientSlug,
    // this.driverSlug,
    // this.clientChargeRate,
    // this.driverPayRate,
    // this.offDays,
    // this.deptSlug,
    // this.startTime,
    // this.endTime,
    // this.status,
    this.AssignmentNumber,
    // this.createdAt,
    // this.updatedAt,
    required this.clients,
    required this.drivers,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    // slug: json["slug"],
    // clientSlug: json["client_slug"],
    // driverSlug: json["driver_slug"],
    // clientChargeRate: json["client_charge_rate"],
    // driverPayRate: json["driver_pay_rate"],
    // offDays: json["off_days"],
    // deptSlug: json["dept_slug"],
    // startTime: json["start_time"],
    // endTime: json["end_time"],
    // status: json["status"],
    AssignmentNumber: json["assignment_number"],
    // createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
    clients: Clients.fromJson(json["clients"]),
    drivers: Clients.fromJson(json["drivers"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    // "slug": slug,
    // "client_slug": clientSlug,
    // "driver_slug": driverSlug,
    // "client_charge_rate": clientChargeRate,
    // "driver_pay_rate": driverPayRate,
    // "off_days": offDays,
    // "dept_slug": deptSlug,
    // "start_time": startTime,
    // "end_time": endTime,
    // "status": status,
    "assignment_number":AssignmentNumber,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
    "clients": clients.toJson(),
    "drivers": drivers.toJson(),
  };
}

class Clients {
  dynamic id;
  // dynamic roleId;
  // String? name;
  // String? companyName;
  // String ?userName;
  // String? regNumber;
  // String ?slug;
  String? email;
  // dynamic? emailVerifiedAt;
  String? phone;
  // String ?role;
  String ?image;
  // String ?address;
  // String? fundingLimit;
  // String? description;
  // dynamic dayStartTime;
  // dynamic dayEndTime;
  // dynamic? website;
  // dynamic? facebook;
  // dynamic? linkedin;
  // dynamic ?twitter;
  // String ?status;
  // dynamic? file;
  // String? driverId;
  String? firstName;
  String? lastName;
  String? gender;
  String? driverType;
  // DateTime? dob;
  // String? niNumber;
  // dynamic roleType;
  // dynamic licenceType;
  // String? licenceNumber;
  // DateTime? licenceExpiry;
  // String? cpcNumber;
  // DateTime? cpcExpiry;
  // String? tachoCard;
  // String? tachoNumber;
  // String? drivingConvictions;
  // String? latitude;
  // String ?longitude;
  // DateTime ?createdAt;
  // DateTime? updatedAt;
  String? breakTime;

  Clients({
    this.id,
    // this.roleId,
    // this.name,
    // this.companyName,
    // this.userName,
    // this.regNumber,
    // this.slug,
    this.email,
    // this.emailVerifiedAt,
    this.phone,
    // this.role,
    this.image,
    // this.address,
    // this.fundingLimit,
    // this.description,
    // this.dayStartTime,
    // this.dayEndTime,
    // this.website,
    // this.facebook,
    // this.linkedin,
    // this.twitter,
    // this.status,
    // this.file,
    // this.driverId,
    this.firstName,
    this.lastName,
    this.gender,
    this.driverType,
    // this.dob,
    // this.niNumber,
    // this.roleType,
    // this.licenceType,
    // this.licenceNumber,
    // this.licenceExpiry,
    // this.cpcNumber,
    // this.cpcExpiry,
    // this.tachoCard,
    // this.tachoNumber,
    // this.drivingConvictions,
    // this.latitude,
    // this.longitude,
    // this.createdAt,
    // this.updatedAt,
    this.breakTime,
  });

  factory Clients.fromJson(Map<String, dynamic> json) => Clients(
    id: json["id"],
    // roleId: json["role_id"],
    // name: json["name"],
    // companyName: json["company_name"],
    // userName: json["user_name"],
    // regNumber: json["reg_number"],
    // slug: json["slug"],
    email: json["email"],
    // emailVerifiedAt: json["email_verified_at"],
    phone: json["phone"],
    // role: json["role"],
    image: json["image"],
    // address: json["address"],
    // fundingLimit: json["funding_limit"],
    // description: json["description"],
    // dayStartTime: json["day_start_time"],
    // dayEndTime: json["day_end_time"],
    // website: json["website"],
    // facebook: json["facebook"],
    // linkedin: json["linkedin"],
    // twitter: json["twitter"],
    // status: json["status"],
    // file: json["file"],
    // driverId: json["driver_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    gender: json["gender"],
    driverType: json["driver_type"],
    // dob: json["dob"] != null && json["dob"].toString().isNotEmpty ? DateTime.parse(json["dob"]) : null,
    // niNumber: json["ni_number"],
    // roleType: json["roleType"],
    // licenceType: json["licenceType"],
    // licenceNumber: json["licenceNumber"],
    // licenceExpiry: json["licenceExpiry"] != null && json["licenceExpiry"].toString().isNotEmpty ? DateTime.parse(json["licenceExpiry"]) : null,
    // cpcNumber: json["cpcNumber"],
    // cpcExpiry: json["cpcExpiry"] != null && json["cpcExpiry"].toString().isNotEmpty ? DateTime.parse(json["cpcExpiry"]) : null,
    // tachoCard: json["tachoCard"],
    // tachoNumber: json["tachoNumber"],
    // drivingConvictions: json["drivingConvictions"],
    // latitude: json["latitude"],
    // longitude: json["longitude"],
    // createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
    breakTime: json["break_time"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    // "role_id": roleId,
    // "name": name,
    // "company_name": companyName,
    // "user_name": userName,
    // "reg_number": regNumber,
    // "slug": slug,
    "email": email,
    // "email_verified_at": emailVerifiedAt,
    "phone": phone,
    // "role": role,
    "image": image,
    // "address": address,
    // "funding_limit": fundingLimit,
    // "description": description,
    // "day_start_time": dayStartTime,
    // "day_end_time": dayEndTime,
    // "website": website,
    // "facebook": facebook,
    // "linkedin": linkedin,
    // "twitter": twitter,
    // "status": status,
    // "file": file,
    // "driver_id": driverId,
    "first_name": firstName,
    "last_name": lastName,
    "gender": gender,
    "driver_type": driverType,
    // "dob": "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
    // "ni_number": niNumber,
    // "roleType": roleType,
    // "licenceType": licenceType,
    // "licenceNumber": licenceNumber,
    // "licenceExpiry": "${licenceExpiry!.year.toString().padLeft(4, '0')}-${licenceExpiry!.month.toString().padLeft(2, '0')}-${licenceExpiry!.day.toString().padLeft(2, '0')}",
    // "cpcNumber": cpcNumber,
    // "cpcExpiry": "${cpcExpiry!.year.toString().padLeft(4, '0')}-${cpcExpiry!.month.toString().padLeft(2, '0')}-${cpcExpiry!.day.toString().padLeft(2, '0')}",
    // "tachoCard": tachoCard,
    // "tachoNumber": tachoNumber,
    // "drivingConvictions": drivingConvictions,
    // "latitude": latitude,
    // "longitude": longitude,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
    "break_time": breakTime,
  };
}
