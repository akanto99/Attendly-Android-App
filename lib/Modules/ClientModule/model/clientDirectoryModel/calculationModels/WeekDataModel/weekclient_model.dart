import 'dart:convert';

WeekDataClientModel weekDataClientModelFromJson(String str) => WeekDataClientModel.fromJson(json.decode(str));
String weekDataClientModelToJson(WeekDataClientModel data) => json.encode(data.toJson());

class WeekDataClientModel {
  List<Datum>? data;
  String ? method;

  WeekDataClientModel({
    required this.data,
     this.method,
  });

  factory WeekDataClientModel.fromJson(Map<String, dynamic> json) => WeekDataClientModel(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    method: json["method"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "method": method,
  };
}


class Datum {
  String? week;
  String? weekDatesRange;
  // List<String>? daysOfWeek;
  String? assignmentId;
  // String? driverSlug;
  String? driverName;
  dynamic driverId;
  // String? clientName;
  String? companyName;
  // String? clientSlug;
  String? calculationType;
  String? calculationDate;
  dynamic totalWorkingHours;
  // dynamic clientDayChargeRate;
  // dynamic driverDayPayRate;
  // dynamic clientNightChargeRate;
  // dynamic driverNightPayRate;
  // dynamic dayShiftTime;
  // dynamic nightShiftTime;
  // dynamic dayShiftCharge;
  // dynamic dayShiftPay;
  // dynamic nightShiftCharge;
  // dynamic nightShiftPay;
  // dynamic totalCharge;
  // dynamic totalPay;
  // dynamic income;
  String? status;
  // String? cancelReason;
  // String? finalSubmit;
  // dynamic breakTime;
  // dynamic expenses;
  List<int>? calculationIds;

  Datum({
    this.week,
    this.weekDatesRange,
    // this.daysOfWeek,
    this.assignmentId,
    // this.driverSlug,
    this.driverName,
    this.driverId,
    // this.clientName,
    this.companyName,
    // this.clientSlug,
    this.calculationType,
    this.calculationDate,
    this.totalWorkingHours,
    // this.clientDayChargeRate,
    // this.driverDayPayRate,
    // this.clientNightChargeRate,
    // this.driverNightPayRate,
    // this.dayShiftTime,
    // this.nightShiftTime,
    // this.dayShiftCharge,
    // this.dayShiftPay,
    // this.nightShiftCharge,
    // this.nightShiftPay,
    // this.totalCharge,
    // this.totalPay,
    // this.income,
    this.status,
    // this.cancelReason,
    // this.finalSubmit,
    // this.breakTime,
    // this.expenses,
    this.calculationIds,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    week: json["week"],
    weekDatesRange: json["week_dates_range"],
    // daysOfWeek: json["days_of_week"] == null ? [] : List<String>.from(json["days_of_week"].map((x) => x)),
    assignmentId: json["assignment_id"],
    // driverSlug: json["driver_slug"],
    driverName: json["driver_name"],
    driverId: json["driver_id"],
    // clientName: json["client_name"],
    companyName: json["company_name"],
    // clientSlug: json["client_slug"],
    calculationType: json["calculation_type"],
    calculationDate: json["calculation_date"],
    totalWorkingHours: json["total_working_hours"],
    // clientDayChargeRate: json["client_day_charge_rate"],
    // driverDayPayRate: json["driver_day_pay_rate"],
    // clientNightChargeRate: json["client_night_charge_rate"],
    // driverNightPayRate: json["driver_night_pay_rate"],
    // dayShiftTime: json["day_shift_time"],
    // nightShiftTime: json["night_shift_time"],
    // dayShiftCharge: json["day_shift_charge"],
    // dayShiftPay: json["day_shift_pay"],
    // nightShiftCharge: json["night_shift_charge"],
    // nightShiftPay: json["night_shift_pay"],
    // totalCharge: json["total_charge"],
    // totalPay: json["total_pay"],
    // income: json["income"],
    status: json["status"],
    // cancelReason: json["cancel_reason"],
    // finalSubmit: json["final_submit"],
    // breakTime: json["break_time"],
    // expenses: json["expenses"],
    calculationIds: json["calculation_ids"] == null ? [] : List<int>.from(json["calculation_ids"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "week": week,
    "week_dates_range": weekDatesRange,
    // "days_of_week": daysOfWeek == null ? [] : List<dynamic>.from(daysOfWeek!.map((x) => x)),
    "assignment_id": assignmentId,
    // "driver_slug": driverSlug,
    "driver_name": driverName,
    "driver_id": driverId,
    // "client_name": clientName,
    "company_name": companyName,
    // "client_slug": clientSlug,
    "calculation_type": calculationType,
    "calculation_date": calculationDate,
    "total_working_hours": totalWorkingHours,
    // "client_day_charge_rate": clientDayChargeRate,
    // "driver_day_pay_rate": driverDayPayRate,
    // "client_night_charge_rate": clientNightChargeRate,
    // "driver_night_pay_rate": driverNightPayRate,
    // "day_shift_time": dayShiftTime,
    // "night_shift_time": nightShiftTime,
    // "day_shift_charge": dayShiftCharge,
    // "day_shift_pay": dayShiftPay,
    // "night_shift_charge": nightShiftCharge,
    // "night_shift_pay": nightShiftPay,
    // "total_charge": totalCharge,
    // "total_pay": totalPay,
    // "income": income,
    "status": status,
    // "cancel_reason": cancelReason,
    // "final_submit": finalSubmit,
    // "break_time": breakTime,
    // "expenses": expenses,
    "calculation_ids": calculationIds == null ? [] : List<dynamic>.from(calculationIds!.map((x) => x)),
  };
}
enum Status {
  DECLINE,
  APPROVED,
  PENDING,
  UPDATED
}

final statusValues = EnumValues({
  "Approved": Status.APPROVED,
  "Pending": Status.PENDING,
  "Decline": Status.DECLINE,
  "Updated": Status.UPDATED
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
