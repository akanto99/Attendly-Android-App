import 'dart:convert';

CalendarModelClass calendarModelClassFromJson(String str) => CalendarModelClass.fromJson(json.decode(str));

String calendarModelClassToJson(CalendarModelClass data) => json.encode(data.toJson());

class CalendarModelClass {
  bool ? success;
  String ? message;
  List<Datum> ?data;
  int? status;

  CalendarModelClass({
    this.success,
    this.message,
    this.data,
    this.status,
  });

  factory CalendarModelClass.fromJson(Map<String, dynamic> json) => CalendarModelClass(
    success: json["success"],
    message: json["message"],
    data: json["data"] != null ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))) : null,
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
    "status": status,
  };
}

class Datum {
  dynamic id;
  // dynamic staffId;
  String ?startTime;
  String ?endTime;
  String ?comments;
  // DateTime ?createdAt;
  // DateTime ?updatedAt;

  Datum({
    this.id,
    // this.staffId,
    this.startTime,
    this.endTime,
    this.comments,
    // this.createdAt,
    // this.updatedAt,

  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    // staffId: json["staff_id"],
    startTime:json["start_time"],
    endTime:json["end_time"],
    comments: json["comments"],
    // createdAt: DateTime.parse(json["created_at"]),
    // updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    // "staff_id": staffId,
    "start_time": startTime,
    "end_time": endTime,
    "comments": comments,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
  };
}
