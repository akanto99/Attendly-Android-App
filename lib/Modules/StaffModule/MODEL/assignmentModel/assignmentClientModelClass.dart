import 'dart:convert';

AssignMentClientModel assignMentClientModelFromJson(String str) => AssignMentClientModel.fromJson(json.decode(str));

String assignMentClientModelToJson(AssignMentClientModel data) => json.encode(data.toJson());

class AssignMentClientModel {
  Data ? data;
  int status;
  String ?name;
  dynamic id;
  dynamic peopleId;
  dynamic roleType;
  String? image;

  AssignMentClientModel({
     this.data,
    required this.status,
    this.name,
    this.id,
    this.image,
    this.peopleId,
    this.roleType,
  });

  factory AssignMentClientModel.fromJson(Map<String, dynamic> json) => AssignMentClientModel(
    data: Data.fromJson(json["data"]),
    status: json["status"],
    name: json["name"],
    id: json["id"],
    peopleId: json["peopleId"],
    roleType: json["roleType"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "status": status,
    "name": name,
    "id": id,
    "peopleId": peopleId,
    "roleType": roleType,
    "image": image,
  };
}

class Data {
  int ? currentPage;
  List<Datum> data;
  String ? firstPageUrl;
  int ? from;
  int lastPage;
  String ? lastPageUrl;
  List<Link> links;
  String ? nextPageUrl;
  String ? path;
  int ? perPage;
  dynamic? prevPageUrl;
  int ?to;
  int ? total;

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

  dynamic id;
  String? slug;
  String ? calculationMethod;
  String ?clientSlug;
  String? driverSlug;
  // String ?clientChargeRate;
  // String ?driverPayRate;
  // String ?offDays;
  String? deptSlug;
  String? startTime;
  String? endTime;
  // String? status;
  String? assignmentNumber;
  // String? location;
  String ?assignStartDate;
  String? assignEndDate;
  String? workingHour;
  // String? noticePeriod;
  // String ?ir;
  // String? supervision;
  // dynamic ?additionalInfo;
  // DateTime? createdAt;
  // DateTime? updatedAt;
  Clients? clients;


  Datum({
    this.id,
    this.slug,
    this.calculationMethod,
    this.clientSlug,
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
    this.workingHour,
    // this.noticePeriod,
    // this.ir,
    // this.supervision,
    // this.additionalInfo,
    // this.createdAt,
    // this.updatedAt,
    this.clients,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    slug: json["slug"],
    calculationMethod: json["calculation_method"],
    clientSlug: json["client_slug"],
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
    assignStartDate:json["assign_start_date"],
    assignEndDate:json["assign_end_date"],
    workingHour: json["working_hour"],
    // noticePeriod: json["notice_period"],
    // ir: json["IR"],
    // supervision: json["supervision"],
    // additionalInfo: json["additional_info"],
    // createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
    // updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
    clients: Clients.fromJson(json["clients"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "calculation_method": calculationMethod,
    "client_slug": clientSlug,
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
    "working_hour": workingHour,
    // "notice_period": noticePeriod,
    // "IR": ir,
    // "supervision": supervision,
    // "additional_info": additionalInfo,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
    "clients": clients?.toJson(),
  };
}

class Clients {
  int id;
  // dynamic? roleId;
  String? name;
  String ?companyName;
  // String? userName;
  // dynamic? regNumber;
  // String? slug;
  String? email;
  // dynamic ?emailVerifiedAt;
  String?phone;
  // String?role;
  String? image;
  // String? address;
  dynamic addressLine1;
  dynamic addressLine2;
  // String? fundingLimit;
  // dynamic? description;
  // String ?dayStartTime;
  // String ?dayEndTime;
  // dynamic? website;
  // dynamic? facebook;
  // dynamic ?linkedin;
  // dynamic ?twitter;
  // String ?status;
  // String ?file;
  // dynamic ?driverId;
  // dynamic ?firstName;
  // dynamic? lastName;
  // dynamic ?gender;
  // dynamic? driverType;
  // dynamic? dob;
  // dynamic? niNumber;
  // dynamic ?roleType;
  // dynamic ?licenceType;
  // dynamic ?licenceNumber;
  // dynamic ?licenceExpiry;
  // dynamic? cpcNumber;
  // dynamic? cpcExpiry;
  // dynamic? tachoCard;
  // dynamic? tachoNumber;
  // dynamic ?drivingConvictions;
  // String ?latitude;
  // String ?longitude;
  // DateTime ?createdAt;
  // DateTime? updatedAt;
  dynamic breakTime;

  Clients({
    required this.id,
    // this.roleId,
    this.name,
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
     this.addressLine1,
     this.addressLine2,
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
    // this.firstName,
    // this.lastName,
    // this.gender,
    // this.driverType,
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
    name: json["name"],
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
    addressLine1: json["addressLine1"],
    addressLine2: json["addressLine2"],
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
    // firstName: json["first_name"],
    // lastName: json["last_name"],
    // gender: json["gender"],
    // driverType: json["driver_type"],
    // dob: json["dob"],
    // niNumber: json["ni_number"],
    // roleType: json["roleType"],
    // licenceType: json["licenceType"],
    // licenceNumber: json["licenceNumber"],
    // licenceExpiry: json["licenceExpiry"],
    // cpcNumber: json["cpcNumber"],
    // cpcExpiry: json["cpcExpiry"],
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
    "name": name,
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
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,
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
    // "first_name": firstName,
    // "last_name": lastName,
    // "gender": gender,
    // "driver_type": driverType,
    // "dob": dob,
    // "ni_number": niNumber,
    // "roleType": roleType,
    // "licenceType": licenceType,
    // "licenceNumber": licenceNumber,
    // "licenceExpiry": licenceExpiry,
    // "cpcNumber": cpcNumber,
    // "cpcExpiry": cpcExpiry,
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

class Link {
  String? url;
  String label;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
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
