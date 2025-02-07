import 'dart:convert';

EditWeekDataUpdateModel editWeekDataUpdateModelFromJson(String str) => EditWeekDataUpdateModel.fromJson(json.decode(str));

String editWeekDataUpdateModelToJson(EditWeekDataUpdateModel data) => json.encode(data.toJson());

class EditWeekDataUpdateModel {
  List<Datum>? data;
  String? clientSlug;
  String? driverSlug;
  String ?mCalculationId;
  String ?assignSlug;
  dynamic cancelReason;
  int ?status;

  EditWeekDataUpdateModel({
     this.data,
     this.clientSlug,
     this.driverSlug,
     this.mCalculationId,
     this.assignSlug,
     this.cancelReason,
     this.status,
  });

  factory EditWeekDataUpdateModel.fromJson(Map<String, dynamic> json) => EditWeekDataUpdateModel(
    data: json["data"] == null ? [] : List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    clientSlug: json["client_slug"],
    driverSlug: json["driver_slug"],
    mCalculationId: json["m_calculation_id"],
    assignSlug: json["assign_slug"],
    cancelReason: json["cancel_reason"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "client_slug": clientSlug,
    "driver_slug": driverSlug,
    "m_calculation_id": mCalculationId,
    "assign_slug": assignSlug,
    "cancel_reason": cancelReason,
    "status": status,
  };
}

class Datum {
  int? id;
  String ?calId;
  // String? assignmentSlug;
  // dynamic ?driverId;
  // String ?driverSlug;
  // String ?driverName;
  // dynamic? clientId;
  // String ?clientName;
  // String? companyName;
  // String? clientSlug;
  // String? daysName;
  String ? date;
  // String? hours;
  String ?clientDayChargeRate;
  // String ?driverDayPayRate;
  String ?clientNightChargeRate;
  // String ?driverNightPayRate;
  String? dayShiftTime;
  String? nightShiftTime;
  // String ?dayShiftCharge;
  // String ?dayShiftPay;
  // String ?nightShiftCharge;
  // String ?nightShiftPay;
  String ?totalCharge;
  // String ?totalPay;
  // String ?income;
  // String ?status;
  // String? cancelReason;
  // String? breakTime;
  String? expenses;
  // String? assignId;

  Datum({
     this.id,
     this.calId,
     // this.assignmentSlug,
     // this.driverId,
     // this.driverSlug,
     // this.driverName,
     // this.clientId,
     // this.clientName,
     // this.companyName,
     // this.clientSlug,
     // this.daysName,
     this.date,
     // this.hours,
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
     // this.status,
     // this.cancelReason,
     // this.breakTime,
     this.expenses,
     // this.assignId,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    calId: json["cal_id"],
    // assignmentSlug: json["assignment_slug"],
    // driverId: json["driver_id"],
    // driverSlug: json["driver_slug"],
    // driverName: json["driver_name"],
    // clientId: json["client_id"],
    // clientName: json["client_name"],
    // companyName: json["company_name"],
    // clientSlug: json["client_slug"],
    // daysName: json["days_name"],
    date: json["date"],
    // hours: json["hours"],
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
    // status: json["status"],
    // cancelReason: json["cancelReason"],
    // breakTime: json["break_time"],
    expenses: json["expenses"],
    // assignId: json["assign_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cal_id": calId,
    // "assignment_slug": assignmentSlug,
    // "driver_id": driverId,
    // "driver_slug": driverSlug,
    // "driver_name": driverName,
    // "client_id": clientId,
    // "client_name": clientName,
    // "company_name": companyName,
    // "client_slug": clientSlug,
    // "days_name": daysName,
    "date": date,
    // "hours": hours,
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
    // "status": status,
    // "cancelReason": cancelReason,
    // "break_time": breakTime,
    "expenses": expenses,
    // "assign_id": assignId,
  };
}
