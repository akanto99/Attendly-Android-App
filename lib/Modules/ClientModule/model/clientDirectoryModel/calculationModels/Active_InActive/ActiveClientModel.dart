import 'dart:convert';
ActiveClientStaffModel activeClientStaffModelFromJson(String str) => ActiveClientStaffModel.fromJson(json.decode(str));
String activeClientStaffModelToJson(ActiveClientStaffModel data) => json.encode(data.toJson());
class ActiveClientStaffModel {
  List<The0> the0;
  List<Datum> data;
  int status;
  ActiveClientStaffModel({
    required this.the0,
    required this.data,
    required this.status,
  });
  factory ActiveClientStaffModel.fromJson(Map<String, dynamic> json) => ActiveClientStaffModel(
    the0: List<The0>.from(json["0"].map((x) => The0.fromJson(x))),
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    status: json["status"],
  );
  Map<String, dynamic> toJson() => {
    "0": List<dynamic>.from(the0.map((x) => x.toJson())),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "status": status,
  };
}
class Datum {
  dynamic id;
  String ?slug;
  // String? clientSlug;
  String? driverSlug;
  // String ?clientChargeRate;
  // String? driverPayRate;
  // String? offDays;
  String ?deptSlug;
  String ?startTime;
  String ?endTime;
  // String ?status;
  String ?assignmentNumber;
  // String ?location;
  String ? assignStartDate;
  String? assignEndDate;
  // String?workingHour;
  // String? noticePeriod;
  // String? ir;
  // String ?supervision;
  // dynamic? additionalInfo;
  // DateTime? createdAt;
  // DateTime? updatedAt;
  Clients? clients;
  Clients? drivers;
  String? calculationMethod;
  Datum({
    this.id,
    this.slug,
    // this.clientSlug,
    this.driverSlug,
    // this.clientChargeRate,
    // this.driverPayRate,
    // this.offDays,
    this.deptSlug,
    this.startTime,
    this.endTime,
    // this.status,
    this.assignmentNumber,
    // this.location,
    this.assignStartDate,
    this.assignEndDate,
    // this.workingHour,
    // this.noticePeriod,
    // this.ir,
    // this.supervision,
    // this.additionalInfo,
    // this.createdAt,
    // this.updatedAt,
    this.clients,
    this.drivers,
    this.calculationMethod,
  });
  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    slug: json["slug"],
    // clientSlug: json["client_slug"],
    driverSlug: json["driver_slug"],
    // clientChargeRate: json["client_charge_rate"],
    // driverPayRate: json["driver_pay_rate"],
    // offDays: json["off_days"],
    deptSlug: json["dept_slug"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    // status: json["status"],
    assignmentNumber: json["assignment_number"],
    // location: json["location"],
    assignStartDate: json["assign_start_date"],
    assignEndDate: json["assign_end_date"],
    // workingHour: json["working_hour"],
    // noticePeriod: json["notice_period"],
    // ir: json["IR"],
    // supervision: json["supervision"],
    // additionalInfo: json["additional_info"],
    calculationMethod: json["calculation_method"],
    // createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
    // createdAt: json["created_at"] != null ? _parseDate(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? _parseDate(json["updated_at"]) : null,
    clients: Clients.fromJson(json["clients"]),
    // drivers: Clients.fromJson(json["drivers"]),
    drivers: json["drivers"] != null ? Clients.fromJson(json["drivers"]) : null,
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    // "client_slug": clientSlug,
    "driver_slug": driverSlug,
    // "client_charge_rate": clientChargeRate,
    // "driver_pay_rate": driverPayRate,
    // "off_days": offDays,
    "dept_slug": deptSlug,
    "start_time": startTime,
    "end_time": endTime,
    // "status": status,
    "assignment_number": assignmentNumber,
    // "location": location,
    "assign_start_date": assignStartDate,
    "assign_end_date": assignEndDate,
    // "working_hour": workingHour,
    // "notice_period": noticePeriod,
    // "IR": ir,
    // "supervision": supervision,
    // "additional_info": additionalInfo,
    "calculation_method": calculationMethod,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
    "clients": clients?.toJson(),
    "drivers": drivers?.toJson(),
  };
  static DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Handle parsing error
      print("Error parsing date: $dateString");
      return DateTime.now(); // Return current date as fallback
    }
  }
}
class Clients {
  dynamic id;
  // dynamic roleId;
  // String? name;
  String? companyName;
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
  String ?status;
  dynamic? file;
  // String? driverId;
  String? firstName;
  String? lastName;
  String? gender;
  // String? driverType;
  // DateTime? dob;
  // String? niNumber;
  dynamic roleType;
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
  dynamic breakTime;
  Clients({
    this.id,
    // this.roleId,
    // this.name,
    this.companyName,
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
    this.status,
    this.file,
    // this.driverId,
    this.firstName,
    this.lastName,
    this.gender,
    // this.driverType,
    // this.dob,
    // this.niNumber,
    this.roleType,
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
    companyName: json["company_name"],
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
    status: json["status"],
    file: json["file"],
    // driverId: json["driver_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    gender: json["gender"],
    // driverType: json["driver_type"],
    // dob: json["dob"] != null ? _parseDate(json["dob"]) : null,
    // dob: json["dob"] == null ? null : DateTime.parse(json["dob"]),
    // niNumber: json["ni_number"],
    roleType: json["roleType"],
    // licenceType: json["licenceType"],
    // licenceNumber: json["licenceNumber"],
    // licenceExpiry: json["licenceExpiry"] != null ? _parseDate(json["licenceExpiry"]) : null,
    // licenceExpiry: json["licenceExpiry"] == null ? null : DateTime.parse(json["licenceExpiry"]),
    // cpcNumber: json["cpcNumber"],
    // cpcExpiry: json["cpcExpiry"] != null ? _parseDate(json["cpcExpiry"]) : null,
    // cpcExpiry: json["cpcExpiry"] == null ? null : DateTime.parse(json["cpcExpiry"]),
    // tachoCard: json["tachoCard"],
    // tachoNumber: json["tachoNumber"],
    // drivingConvictions: json["drivingConvictions"],
    // latitude: json["latitude"],
    // longitude: json["longitude"],
    // createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
    // createdAt: json["created_at"] != null ? _parseDate(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? _parseDate(json["updated_at"]) : null,
    breakTime: json["break_time"],
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    // "role_id": roleId,
    // "name": name,
    "company_name": companyName,
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
    "status": status,
    "file": file,
    // "driver_id": driverId,
    "first_name": firstName,
    "last_name": lastName,
    "gender": gender,
    // "driver_type": driverType,
    // "dob": "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
    // "ni_number": niNumber,
    "roleType": roleType,
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
  static DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Handle parsing error
      print("Error parsing date: $dateString");
      return DateTime.now(); // Return current date as fallback
    }
  }
}
class The0 {
  dynamic id;
  String ? deptName;
  String? slug;
  // String ?clientSlug;
  // String ?location;
  // String ?details;
  // DateTime ?createdAt;
  // DateTime? updatedAt;
  The0({
    this.id,
    this.deptName,
    this.slug,
    // this.clientSlug,
    // this.location,
    // this.details,
    // this.createdAt,
    // this.updatedAt,
  });
  factory The0.fromJson(Map<String, dynamic> json) => The0(
    id: json["id"],
    deptName: json["dept_name"],
    slug: json["slug"],
    // clientSlug: json["client_slug"],
    // location: json["location"],
    // details: json["details"],
    // createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "dept_name": deptName,
    "slug": slug,
    // "client_slug": clientSlug,
    // "location": location,
    // "details": details,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
  };
}