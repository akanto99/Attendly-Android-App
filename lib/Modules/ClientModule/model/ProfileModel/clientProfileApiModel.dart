import 'dart:convert';

ClientProfileApiModel clientProfileApiModelFromJson(String str) =>
    ClientProfileApiModel.fromJson(json.decode(str));

String clientProfileApiModelToJson(ClientProfileApiModel data) =>
    json.encode(data.toJson());

class ClientProfileApiModel {
  Data? data;
  List<dynamic>? file;
  int? status;

  ClientProfileApiModel({
    this.data,
    this.file,
    this.status,
  });

  factory ClientProfileApiModel.fromJson(Map<String, dynamic> json) =>
      ClientProfileApiModel(
        data: json["data"] != null ? Data.fromJson(json["data"]) : null,
        file: json["file"] != null
            ? List<dynamic>.from(json["file"].map((x) => x))
            : null,
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data != null ? data!.toJson() : null,
        "file": file != null ? List<dynamic>.from(file!.map((x) => x)) : null,
        "status": status,
      };
}

class Data {
  int? id;
  String? name;
  String? companyName;
  String? regNumber;
  String? email;
  String? phone;
  String? image;

  dynamic dayStartTime;
  dynamic dayEndTime;

  dynamic breakTime;

  dynamic addressLine1;
  dynamic addressLine2;
  dynamic city;
  dynamic postCode;
  String? consultant; // Added consultant field

  List<XeroContact>? xeroContacts;

  Data({
    this.id,
    this.name,
    this.companyName,
    this.regNumber,
    this.email,
    this.phone,
    this.image,
    this.dayStartTime,
    this.dayEndTime,
    this.breakTime,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postCode,
    this.consultant,
    this.xeroContacts,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        companyName: json["company_name"],
        regNumber: json["reg_number"],
        email: json["email"],
        phone: json["phone"],
        image: json["image"],
        dayStartTime: json["day_start_time"],
        dayEndTime: json["day_end_time"],
        breakTime: json["break_time"],
        addressLine1: json["addressLine1"],
        addressLine2: json["addressLine2"],
        city: json["city"],
        postCode: json["postCode"],
        consultant: json["consultant"], // Deserialize consultant
        xeroContacts: json["xero_contacts"] != null
            ? List<XeroContact>.from(
                json["xero_contacts"].map((x) => XeroContact.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "company_name": companyName,
        "reg_number": regNumber,
        "email": email,
        "phone": phone,
        "image": image,
        "day_start_time": dayStartTime,
        "day_end_time": dayEndTime,
        "break_time": breakTime,
        "addressLine1": addressLine1,
        "addressLine2": addressLine2,
        "city": city,
        "post_code": postCode,
        "consultant": consultant, // Serialize consultant
        "xero_contacts": xeroContacts != null
            ? List<dynamic>.from(xeroContacts!.map((x) => x.toJson()))
            : null,
      };
}

class XeroContact {
  int? id;
  int? userId;
  String? contactId;
  String? name;
  String? emailAddress;

  XeroContact({
    this.id,
    this.userId,
    this.contactId,
    this.name,
    this.emailAddress,
  });

  factory XeroContact.fromJson(Map<String, dynamic> json) => XeroContact(
        id: json["id"],
        userId: json["user_id"],
        contactId: json["contact_id"],
        name: json["name"],
        emailAddress: json["email_address"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "contact_id": contactId,
        "name": name,
        "email_address": emailAddress,
      };
}
