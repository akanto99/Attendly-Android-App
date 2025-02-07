import 'dart:convert';

List<PaySlipListModel> paySlipListModelFromJson(String str) => List<PaySlipListModel>.from(json.decode(str).map((x) => PaySlipListModel.fromJson(x)));

String paySlipListModelToJson(List<PaySlipListModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PaySlipListModel {
  dynamic? payrollId;
  dynamic?peopleId;
  String? payDate;
  dynamic ?taxWeek;
  // String ?invoiceNo;
  // dynamic? fpsId;
  String? agency;
  // String ?invoiceAmount;
  String? total;
  // String ?totalTaxablePayYtd;
  // String ?accruedHolidayPayBalance;

  PaySlipListModel({
    this.payrollId,
    this.peopleId,
    this.payDate,
    this.taxWeek,
    // this.invoiceNo,
    // this.fpsId,
    this.agency,
    // this.invoiceAmount,
    this.total,
    // this.totalTaxablePayYtd,
    // this.accruedHolidayPayBalance,
  });

  factory PaySlipListModel.fromJson(Map<String, dynamic> json) => PaySlipListModel(
    payrollId: json["payrollId"],
    peopleId: json["peopleId"],
    payDate: json["payDate"],
    taxWeek: json["taxWeek"],
    // invoiceNo: json["invoiceNo"],
    // fpsId: json["fpsId"],
    agency: json["agency"],
    // invoiceAmount: json["invoiceAmount"],
    total: json["total"],
    // totalTaxablePayYtd: json["totalTaxablePayYtd"],
    // accruedHolidayPayBalance: json["accruedHolidayPayBalance"],
  );

  Map<String, dynamic> toJson() => {
    "payrollId": payrollId,
    "peopleId": peopleId,
    "payDate": payDate,
    "taxWeek": taxWeek,
    // "invoiceNo": invoiceNo,
    // "fpsId": fpsId,
    "agency": agency,
    // "invoiceAmount": invoiceAmount,
    "total": total,
    // "totalTaxablePayYtd": totalTaxablePayYtd,
    // "accruedHolidayPayBalance": accruedHolidayPayBalance,
  };
}
