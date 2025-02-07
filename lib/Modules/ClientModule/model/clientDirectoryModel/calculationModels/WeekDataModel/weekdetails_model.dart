import 'dart:convert';

WeekDataClientDetailsModel weekDataClientDetailsModelFromJson(String str) =>
    WeekDataClientDetailsModel.fromJson(json.decode(str));

String weekDataClientDetailsModelToJson(WeekDataClientDetailsModel data) =>
    json.encode(data.toJson());

class WeekDataClientDetailsModel {
  String message;
  List<Datum>? data; // Making data nullable

  WeekDataClientDetailsModel({
    required this.message,
    this.data, // Marking data as nullable
  });

  factory WeekDataClientDetailsModel.fromJson(Map<String, dynamic> json) {
    return WeekDataClientDetailsModel(
      message: json["message"],
      data: json["data"] != null
          ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
          : null, // Handle null case when data is null
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data != null
        ? List<dynamic>.from(data!.map((x) => x.toJson()))
        : null, // Ensure data is serialized as null if it's null
  };
}


class Datum {
  int? id;
  // String? slug;
  // String? calId;
  String? assignmentSlug;
  // String? driverSlug;
  // String? clientSlug;
  String? daysName;
  String? date;
  String? hours;
  String? clientDayChargeRate;
  // String? driverDayPayRate;
  String? clientNightChargeRate;
  // String? driverNightPayRate;
  String? dayShiftTime;
  String? nightShiftTime;
  // String? dayShiftCharge;
  // String? dayShiftPay;
  // String? nightShiftCharge;
  // String? nightShiftPay;
  String? totalCharge;
  // String? totalPay;
  // String? income;
  Status? status;
  // String? role;
  dynamic cancelReason;
  // String? finalSubmit;
  String? breakTime;
  String? expenses;
  // String? assignId;

  Datum({
    this.id,
    // this.slug,
    // this.calId,
    this.assignmentSlug,
    // this.driverSlug,
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
    // this.role,
    this.cancelReason,
    // this.finalSubmit,
    this.breakTime,
    this.expenses,
    // this.assignId,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    // slug: json["slug"],
    // calId: json["cal_id"],
    assignmentSlug: json["assignment_slug"],
    // driverSlug: json["driver_slug"],
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
    status: statusValues.map[json["status"]]!,
    // role: json["role"],
    cancelReason: json["cancelReason"],
    // finalSubmit: json["finalSubmit"],
    breakTime: json["break_time"],
    expenses: json["expenses"],
    // assignId: json["assign_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    // "slug": slug,
    // "cal_id": calId,
    "assignment_slug": assignmentSlug,
    // "driver_slug": driverSlug,
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
    "status": statusValues.reverse[status],
    // "role": role,
    "cancelReason": cancelReason,
    // "finalSubmit": finalSubmit,
    "break_time": breakTime,
    "expenses": expenses,
    // "assign_id": assignId,
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
