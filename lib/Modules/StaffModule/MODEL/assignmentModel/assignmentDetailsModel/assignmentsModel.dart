import 'dart:convert';

AssignmentsDetails assignmentsDetailsFromJson(String str) => AssignmentsDetails.fromJson(json.decode(str));

String assignmentsDetailsToJson(AssignmentsDetails data) => json.encode(data.toJson());

class AssignmentsDetails {
  Data? data;
  List<Category>? category;
  int? status;

  AssignmentsDetails({
    this.data,
    this.category,
    this.status,
  });

  factory AssignmentsDetails.fromJson(Map<String, dynamic> json) => AssignmentsDetails(
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
    category: json["category"] != null
        ? List<Category>.from(json["category"].map((x) => Category.fromJson(x)))
        : null,
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "category": category != null ? List<dynamic>.from(category!.map((x) => x.toJson())) : null,
    "status": status,
  };
}

class Category {
  dynamic id;
  String? daysName;

  Category({
    this.id,
    this.daysName,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    daysName: json["days_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "days_name": daysName,
  };
}

class Data {
  dynamic id;
  // String? slug;
  // String? clientSlug;
  // String? driverSlug;
  // dynamic clientChargeRate;
  // dynamic driverPayRate;
  List<OffDay>? offDays;
  // String? deptSlug;
  // String? startTime;
  // String? endTime;
  String? status;
  dynamic dataAssignmentNumber;
  // dynamic location;
  DateTime? assignStartDate;
  DateTime? assignEndDate;
  // dynamic workingHour;
  // dynamic noticePeriod;
  // dynamic ir;
  // dynamic supervision;
  // dynamic additionalInfo;
  // List<String>? calculationMethod;
  // dynamic assignmentId;
  // dynamic assignmentNumber;
  // dynamic companyId;
  // dynamic peopleId;
  // dynamic externalReference;
  // dynamic customerId;
  // dynamic customerName;
  // dynamic endClient;
  // DateTime? createdAt;
  // DateTime? updatedAt;

  Clients ? clients;
  Data({
    this.id,
    // this.slug,
    // this.clientSlug,
    // this.driverSlug,
    // this.clientChargeRate,
    // this.driverPayRate,
    this.offDays,
    // this.deptSlug,
    // this.startTime,
    // this.endTime,
    this.status,
    this.dataAssignmentNumber,
    // this.location,
    this.assignStartDate,
    this.assignEndDate,
    // this.workingHour,
    // this.noticePeriod,
    // this.ir,
    // this.supervision,
    // this.additionalInfo,
    // this.calculationMethod,
    // this.assignmentId,
    // this.assignmentNumber,
    // this.companyId,
    // this.peopleId,
    // this.externalReference,
    // this.customerId,
    // this.customerName,
    // this.endClient,
    // this.createdAt,
    // this.updatedAt,
    this.clients,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json['id'],
    // slug: json["slug"],
    // clientSlug: json["client_slug"],
    // driverSlug: json["driver_slug"],
    // clientChargeRate: json["client_charge_rate"],
    // driverPayRate: json["driver_pay_rate"],
    offDays: json["off_days"] != null
        ? List<OffDay>.from(jsonDecode(json["off_days"]).map((x) => OffDay.fromJson(x)))
        : null,
    // deptSlug: json["dept_slug"],
    // startTime: json["start_time"],
    // endTime: json["end_time"],
    status: json["status"],
    dataAssignmentNumber: json["assignment_number"],
    // location: json["location"],
    assignStartDate: json["assign_start_date"] != null
        ? DateTime.parse(json["assign_start_date"])
        : null,
    assignEndDate: json["assign_end_date"] != null
        ? DateTime.parse(json["assign_end_date"])
        : null,
    // workingHour: json["working_hour"],
    // noticePeriod: json["notice_period"],
    // ir: json["IR"],
    // supervision: json["supervision"],
    // additionalInfo: json["additional_info"],
    // calculationMethod: json["calculation_method"] != null
    //     ? List<String>.from(jsonDecode(json["calculation_method"]))
    //     : null,
    // assignmentId: json["assignmentId"],
    // assignmentNumber: json["assignmentNumber"],
    // companyId: json["companyId"],
    // peopleId: json["peopleId"],
    // externalReference: json["externalReference"],
    // customerId: json["customerId"],
    // customerName: json["customerName"],
    // endClient: json["endClient"],
    // createdAt: json["created_at"] != null
    //     ? DateTime.parse(json["created_at"])
    //     : null,
    // updatedAt: json["updated_at"] != null
    //     ? DateTime.parse(json["updated_at"])
    //     : null,
    clients: json["clients"] != null ? Clients.fromJson(json["clients"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    // "slug": slug,
    // "client_slug": clientSlug,
    // "driver_slug": driverSlug,
    // "client_charge_rate": clientChargeRate,
    // "driver_pay_rate": driverPayRate,
    "off_days": offDays != null
        ? jsonEncode(offDays!.map((x) => x.toJson()).toList())
        : null,
    // "dept_slug": deptSlug,
    // "start_time": startTime,
    // "end_time": endTime,
    "status": status,
    "assignment_number": dataAssignmentNumber,
    // "location": location,
    "assign_start_date": assignStartDate?.toIso8601String(),
    "assign_end_date": assignEndDate?.toIso8601String(),
    // "working_hour": workingHour,
    // "notice_period": noticePeriod,
    // "IR": ir,
    // "supervision": supervision,
    // "additional_info": additionalInfo,
    // "calculation_method": calculationMethod != null
    //     ? jsonEncode(calculationMethod)
    //     : null,
    // "assignmentId": assignmentId,
    // "assignmentNumber": assignmentNumber,
    // "companyId": companyId,
    // "peopleId": peopleId,
    // "externalReference": externalReference,
    // "customerId": customerId,
    // "customerName": customerName,
    // "endClient": endClient,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
    "clients": clients?.toJson(),
  };
}

class Clients {
  dynamic addressLine1;
  dynamic phone;
  dynamic regNumber;
  dynamic city;
  dynamic postCode;
  Clients({
    this.addressLine1,
    this.phone,
    this.regNumber,
    this.city,
    this.postCode,
  });

  factory Clients.fromJson(Map<String, dynamic> json) => Clients(
    addressLine1: json["addressLine1"],
    phone: json["phone"],
    regNumber: json["reg_number"],
    city: json["city"],
    postCode: json["postCode"],
  );

  Map<String, dynamic> toJson() => {
    "addressLine1": addressLine1,
    "phone": phone,
    "reg_number": regNumber,
    "city": city,
    "postCode": postCode,
  };
}

class OffDay {
  String? date;
  dynamic daysName;
  String? dayOrNight;
  String? payHourSalary;
  String? daysHourSalary;

  OffDay({
    this.date,
    this.daysName,
    this.dayOrNight,
    this.payHourSalary,
    this.daysHourSalary,
  });

  factory OffDay.fromJson(Map<String, dynamic> json) => OffDay(
    date: json["date"],
    daysName: json["days_name"],
    dayOrNight: json["dayOrNight"],
    payHourSalary: json["pay_hour_salary"],
    daysHourSalary: json["days_hour_salary"],
  );

  Map<String, dynamic> toJson() => {
    "date": date,
    "days_name": daysName,
    "dayOrNight": dayOrNight,
    "pay_hour_salary": payHourSalary,
    "days_hour_salary": daysHourSalary,
  };
}
