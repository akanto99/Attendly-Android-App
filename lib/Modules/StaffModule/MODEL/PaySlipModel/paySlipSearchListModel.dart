import 'dart:convert';

PaySlipSearchListModel paySlipSearchListModelFromJson(String str) => PaySlipSearchListModel.fromJson(json.decode(str));

String paySlipSearchListModelToJson(PaySlipSearchListModel data) => json.encode(data.toJson());

class PaySlipSearchListModel {
  bool ?success;
  String ?message;
  List<Datum>? data;
  int? status;

  PaySlipSearchListModel({
    this.success,
    this.message,
    this.data,
    this.status,
  });

  factory PaySlipSearchListModel.fromJson(Map<String, dynamic> json) => PaySlipSearchListModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] != null
        ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
        : null,
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data != null
        ? List<dynamic>.from(data!.map((x) => x.toJson()))
        : null,
    "status": status,
  };
}

class Datum {
  dynamic id;
  String? includePayslipData;
  String? userId;
  String? peopleId;
  String? newBusinessAdministratorId;
  String? newBusinessAdministratorName;
  String? businessId;
  String? payDate;
  String? number;
  String? taxYear;
  String ?taxCode;
  String ?niCode;
  String ?studentLoan;
  String ?postGraduateLoan;
  String? earnings;
  String? expenses;
  String? cae;
  String ?umbrella;
  String ?cis;
  String? psc;
  DateTime ?createdAt;
  DateTime ?updatedAt;

  Datum({
    this.id,
    this.includePayslipData,
    this.userId,
    this.peopleId,
    this.newBusinessAdministratorId,
    this.newBusinessAdministratorName,
    this.businessId,
    this.payDate,
    this.number,
    this.taxYear,
    this.taxCode,
    this.niCode,
    this.studentLoan,
    this.postGraduateLoan,
    this.earnings,
    this.expenses,
    this.cae,
    this.umbrella,
    this.cis,
    this.psc,
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    includePayslipData: json["includePayslipData"],
    userId: json["user_id"],
    peopleId: json["peopleId"],
    newBusinessAdministratorId: json["newBusinessAdministratorId"],
    newBusinessAdministratorName: json["newBusinessAdministratorName"],
    businessId: json["businessId"],
    payDate: json["payDate"],
    number: json["number"],
    taxYear: json["taxYear"],
    taxCode: json["taxCode"],
    niCode: json["niCode"],
    studentLoan: json["studentLoan"],
    postGraduateLoan: json["postGraduateLoan"],
    earnings: json["earnings"],
    expenses: json["expenses"],
    cae: json["cae"],
    umbrella: json["umbrella"],
    cis: json["cis"],
    psc: json["psc"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "includePayslipData": includePayslipData,
    "user_id": userId,
    "peopleId": peopleId,
    "newBusinessAdministratorId": newBusinessAdministratorId,
    "newBusinessAdministratorName": newBusinessAdministratorName,
    "businessId": businessId,
    "payDate": payDate,
    "number": number,
    "taxYear": taxYear,
    "taxCode": taxCode,
    "niCode": niCode,
    "studentLoan": studentLoan,
    "postGraduateLoan": postGraduateLoan,
    "earnings": earnings,
    "expenses": expenses,
    "cae": cae,
    "umbrella": umbrella,
    "cis": cis,
    "psc": psc,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
