import 'dart:convert';

BulkActionModel bulkActionModelFromJson(String str) => BulkActionModel.fromJson(json.decode(str));
String bulkActionModelToJson(BulkActionModel data) => json.encode(data.toJson());

class BulkActionModel {
  List<Calculation>? calculations;
  List<Staff>? staffs;
  dynamic year;
  dynamic month;

  BulkActionModel({
    this.calculations,
    this.staffs,
    this.year,
    this.month,
  });

  factory BulkActionModel.fromJson(Map<String, dynamic> json) => BulkActionModel(
    calculations: json["calculations"] != null
        ? List<Calculation>.from(json["calculations"].map((x) => Calculation.fromJson(x)))
        : [],
    staffs: json["staffs"] != null
        ? List<Staff>.from(json["staffs"].map((x) => Staff.fromJson(x)))
        : [],
    year: json["year"],
    month: json["month"],
  );

  Map<String, dynamic> toJson() => {
    "calculations": calculations?.map((x) => x.toJson()).toList() ?? [],
    "staffs": staffs?.map((x) => x.toJson()).toList() ?? [],
    "year": year,
    "month": month,
  };
}

class Calculation {
  dynamic id;
  dynamic assignmentSlug;
  // dynamic driverId;
  // String? driverSlug;
  // String? driverName;
  // dynamic clientId;
  // String? clientName;
  // String? clientSlug;
  String? daysName;
  String? date;
  String? hours;
  String? clientDayChargeRate;
  // String? driverDayPayRate;
  String? clientNightChargeRate;
  // String? driverNightPayRate;
  String? dayShiftTime;
  String ?nightShiftTime;
  // String? dayShiftCharge;
  // String? dayShiftPay;
  // String? nightShiftCharge;
  // String? nightShiftPay;
  String? totalCharge;
  // String ?totalPay;
  // String? income;
  String? status;
  dynamic cancelReason;
  String? breakTime;
  String? expenses;
  // String? assignId;

  Calculation({
     this.id,
     this.assignmentSlug,
     // this.driverId,
     // this.driverSlug,
     // this.driverName,
     // this.clientId,
     // this.clientName,
     // this.clientSlug,
     this.daysName,
     this.date,
     this.hours,
     this.clientDayChargeRate,
     // this.driverDayPayRate,
     this.clientNightChargeRate,
     // this.driverNightPayRate,
     this.dayShiftTime,
     this.nightShiftTime,
     // this.dayShiftCharge,
     // this.dayShiftPay,
     // this.nightShiftCharge,
     // this.nightShiftPay,
     this.totalCharge,
     // this.totalPay,
     // this.income,
     this.status,
     this.cancelReason,
     this.breakTime,
     this.expenses,
     // this.assignId,
  });

  factory Calculation.fromJson(Map<String, dynamic> json) => Calculation(
    id: json["id"],
    assignmentSlug: json["assignment_slug"],
    // driverId: json["driver_id"],
    // driverSlug: json["driver_slug"],
    // driverName: json["driver_name"],
    // clientId: json["client_id"],
    // clientName: json["client_name"],
    // clientSlug: json["client_slug"],
    daysName: json["days_name"],
    date: json["date"],
    hours: json["hours"],
    clientDayChargeRate: json["client_day_charge_rate"],
    // driverDayPayRate: json["driver_day_pay_rate"],
    clientNightChargeRate: json["client_night_charge_rate"],
    // driverNightPayRate: json["driver_night_pay_rate"],
    dayShiftTime: json["day_shift_time"],
    nightShiftTime: json["night_shift_time"],
    // dayShiftCharge: json["day_shift_charge"],
    // dayShiftPay: json["day_shift_pay"],
    // nightShiftCharge: json["night_shift_charge"],
    // nightShiftPay: json["night_shift_pay"],
    totalCharge: json["total_charge"],
    // totalPay: json["total_pay"],
    // income: json["income"],
    status: json["status"],
    cancelReason: json["cancelReason"],
    breakTime: json["break_time"],
    expenses: json["expenses"],
    // assignId: json["assign_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "assignment_slug": assignmentSlug,
    // "driver_id": driverId,
    // "driver_slug": driverSlug,
    // "driver_name": driverName,
    // "client_id": clientId,
    // "client_name": clientName,
    // "client_slug": clientSlug,
    "days_name": daysName,
    "date": date,
    "hours": hours,
    "client_day_charge_rate": clientDayChargeRate,
    // "driver_day_pay_rate": driverDayPayRate,
    "client_night_charge_rate": clientNightChargeRate,
    // "driver_night_pay_rate": driverNightPayRate,
    "day_shift_time": dayShiftTime,
    "night_shift_time": nightShiftTime,
    // "day_shift_charge": dayShiftCharge,
    // "day_shift_pay": dayShiftPay,
    // "night_shift_charge": nightShiftCharge,
    // "night_shift_pay": nightShiftPay,
    "total_charge": totalCharge,
    // "total_pay": totalPay,
    // "income": income,
    "status": status,
    "cancelReason": cancelReason,
    "break_time": breakTime,
    "expenses": expenses,
    // "assign_id": assignId,
  };
}

class Staff {
  int driverId;
  String driverName;
  String driverSlug;

  Staff({
    required this.driverId,
    required this.driverName,
    required this.driverSlug,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    driverId: json["driver_id"],
    driverName: json["driver_name"],
    driverSlug: json["driver_slug"],
  );

  Map<String, dynamic> toJson() => {
    "driver_id": driverId,
    "driver_name": driverName,
    "driver_slug": driverSlug,
  };
}
