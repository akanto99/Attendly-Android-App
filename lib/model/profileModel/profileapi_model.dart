
import 'dart:convert';

ProfileApiModel profileApiModelFromJson(String str) => ProfileApiModel.fromJson(json.decode(str));
String profileApiModelToJson(ProfileApiModel data) => json.encode(data.toJson());

class ProfileApiModel {
  Data data;
  int status;

  ProfileApiModel({
    required this.data,
    required this.status,
  });

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) =>
      ProfileApiModel(
        data: Data.fromJson(json["data"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "status": status,
  };
}

class Data {
  dynamic id;
  String? name;
   String? userName;

  String? email;
   String? phone;
   String? image;

  String? driverId;
  String? firstName;
  String? lastName;
  dynamic gender;
   dynamic? dob;
  dynamic? niNumber;
  String? roleType;
  List<String>? licenceType;
  dynamic? licenceNumber;
  dynamic? licenceExpiry;
  dynamic? cpcNumber;
  dynamic? cpcExpiry;
   dynamic? tachoNumber;

  String? consultant;
  dynamic passportNumber;
  dynamic peopleId;

  dynamic addressLine1;
  dynamic addressLine2;
  dynamic dbsExpiry; // Added field
  dynamic tachoExpiry; // Added field
  dynamic city;

  dynamic postCode;
  dynamic licenceEndorsement;
  dynamic rightToWorkUk;
  dynamic dbsCheck;
  dynamic optOutOfPension;
  dynamic medicalCondition;
  dynamic drivingLicenceDoc;
  dynamic passportDoc;
  dynamic cpcDoc;
  dynamic tachoDoc;
  dynamic proofOfAddressDoc;

  BankDetail? bankDetail;

  // Newly added fields
  dynamic? maritalStatus;
  dynamic? isUkCitizen;
  dynamic? isAuthorizedToWorkInUk;
  dynamic? hasUnspentCriminalConvictions;
  dynamic? unspentCriminalConvictionsDetails;
  dynamic? ukDrivingExperience;
  dynamic? validUkDrivingLicense;
  dynamic? penaltyPoints;
  dynamic? drivingLicenseNumber;
  dynamic? drivingLicenseCategory;
  dynamic? drivingLicenseCheckCode;
  dynamic? drivingLicenseIssueDate;
  dynamic? physicalIncapabilities;
  dynamic? ongoingMedicalConditions;
  dynamic? takingMedication;
  dynamic? drugOrAlcoholIssues;
  dynamic? wearsGlasses;
  dynamic? dismissedForMedicalReasons;
  dynamic? dismissedFromDrivingRoles;
  dynamic? medicalConditionDetails;
  dynamic? medicationDetails;
  dynamic? dismissalReason;
  dynamic? drivingDismissalDetails;
  dynamic? lastEyeTest;
  dynamic? noCpcCard;
  dynamic? noTachoCard;

  Data({
    this.id,
    this.name,
     this.userName,

    this.email,
     this.phone,
     this.image,

    this.driverId,
    this.firstName,
    this.lastName,
    this.gender,
     this.dob,
    this.niNumber,
    this.roleType,
    this.licenceType,
    this.licenceNumber,
    this.licenceExpiry,
    this.cpcNumber,
    this.cpcExpiry,
     this.tachoNumber,

    this.passportNumber,
    this.peopleId,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.postCode,
    this.licenceEndorsement,
    this.rightToWorkUk,
    this.dbsCheck,
    this.dbsExpiry,
    this.tachoExpiry,
    this.optOutOfPension,
    this.medicalCondition,
    this.drivingLicenceDoc,
    this.passportDoc,
    this.cpcDoc,
    this.tachoDoc,
    this.proofOfAddressDoc,
    this.bankDetail,
    this.consultant,

    this.maritalStatus,
    this.isUkCitizen,
    this.isAuthorizedToWorkInUk,
    this.hasUnspentCriminalConvictions,
    this.unspentCriminalConvictionsDetails,
    this.ukDrivingExperience,
    this.validUkDrivingLicense,
    this.penaltyPoints,
    this.drivingLicenseNumber,
    this.drivingLicenseCategory,
    this.drivingLicenseCheckCode,
    this.drivingLicenseIssueDate,
    this.physicalIncapabilities,
    this.ongoingMedicalConditions,
    this.takingMedication,
    this.drugOrAlcoholIssues,
    this.wearsGlasses,
    this.dismissedForMedicalReasons,
    this.dismissedFromDrivingRoles,
    this.medicalConditionDetails,
    this.medicationDetails,
    this.dismissalReason,
    this.drivingDismissalDetails,
    this.lastEyeTest,
    this.noCpcCard,
    this.noTachoCard,

   });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
     userName: json["user_name"],

    email: json["email"],
     phone: json["phone"],
     image: json["image"],
     driverId: json["driver_id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    gender: json["gender"],
     dob: json["dob"],
    niNumber: json["ni_number"],
    roleType: json["roleType"],
    licenceType: json["licenceType"] != null
        ? List<String>.from(json["licenceType"].map((x) => x))
        : null,
    licenceNumber: json["licenceNumber"],
    licenceExpiry: json["licenceExpiry"],
    cpcNumber: json["cpcNumber"],
    cpcExpiry: json["cpcExpiry"],
     tachoNumber: json["tachoNumber"],
    dbsExpiry: json["dbsExpiry"], // Added field
    tachoExpiry: json["tachoExpiry"], // Added field

    passportNumber: json["passportNumber"],
    peopleId: json["peopleId"],
    addressLine1: json["addressLine1"],
    addressLine2: json["addressLine2"],
    city: json["city"],
    postCode: json["postCode"],
    licenceEndorsement: json["licence_endorsement"],
    rightToWorkUk: json["right_to_work_uk"],
    dbsCheck: json["dbs_check"],
    optOutOfPension: json["opt_out_of_pension"],
    medicalCondition: json["medical_condition"],
    drivingLicenceDoc: json["driving_licence_doc"],
    passportDoc: json["passport_doc"],
    cpcDoc: json["cpc_doc"],
    tachoDoc: json["tacho_doc"],
    consultant: json["consultant"],
    proofOfAddressDoc: json["proof_of_address_doc"],
    bankDetail: json["bank_detail"] != null
        ? BankDetail.fromJson(json["bank_detail"])
        : null,


    maritalStatus: json["marital_status"],
    isUkCitizen: json["is_uk_citizen"],
    isAuthorizedToWorkInUk: json["is_authorized_to_work_in_uk"],
    hasUnspentCriminalConvictions:
    json["has_unspent_criminal_convictions"],
    unspentCriminalConvictionsDetails:
    json["unspent_criminal_convictions_details"],
    ukDrivingExperience: json["uk_driving_experience"],
    validUkDrivingLicense: json["valid_uk_driving_license"],
    penaltyPoints: json["penalty_points"],
    drivingLicenseNumber: json["driving_license_number"],
    drivingLicenseCategory: json["driving_license_category"],
    drivingLicenseCheckCode: json["driving_license_check_code"],
    drivingLicenseIssueDate: json["driving_license_issue_date"] ,
    physicalIncapabilities: json["physical_incapabilities"],
    ongoingMedicalConditions: json["ongoing_medical_conditions"],
    takingMedication: json["taking_medication"],
    drugOrAlcoholIssues: json["drug_or_alcohol_issues"],
    wearsGlasses: json["wears_glasses"],
    dismissedForMedicalReasons: json["dismissed_for_medical_reasons"],
    dismissedFromDrivingRoles: json["dismissed_from_driving_roles"],
    medicalConditionDetails: json["medical_condition_details"],
    medicationDetails: json["medication_details"],
    dismissalReason: json["dismissal_reason"],
    drivingDismissalDetails: json["driving_dismissal_details"],
    lastEyeTest: json["last_eye_test"] ,
    noCpcCard: json["noCpcCard"] ,
    noTachoCard: json["noTachoCard"] ,


  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    // "company_name": companyName,
    "user_name": userName,
    // "reg_number": regNumber,
    // "slug": slug,
    "email": email,
    // "email_verified_at": emailVerifiedAt,
    "phone": phone,
    // "role": role,
    "image": image,

    "driver_id": driverId,
    "first_name": firstName,
    "last_name": lastName,
    "gender": gender,
    // "driver_type": driverType,
    "dob": dob,
    "ni_number": niNumber,
    "roleType": roleType,
    "licenceType": licenceType?.map((x) => x).toList() ?? [],
    "licenceNumber": licenceNumber,
    "licenceExpiry": licenceExpiry,
    "cpcNumber": cpcNumber,
    "cpcExpiry": cpcExpiry,
    // "tachoCard": tachoCard,
    "tachoNumber": tachoNumber,
    // "drivingConvictions": drivingConvictions,
    // "latitude": latitude,
    // "longitude": longitude,
    // "created_at": createdAt?.toIso8601String(),
    // "updated_at": updatedAt?.toIso8601String(),
    // "break_time": breakTime,
    "passportNumber": passportNumber,
    "peopleId": peopleId,
    "address_line1": addressLine1,
    "address_line2": addressLine2,
    "city": city,
    "post_code": postCode,
    "licence_endorsement": licenceEndorsement,
    "right_to_work_uk": rightToWorkUk,
    "dbs_check": dbsCheck,
    "dbsExpiry": dbsExpiry, // Added field
    "tachoExpiry": tachoExpiry, // Added field
    "opt_out_of_pension": optOutOfPension,
    "medical_condition": medicalCondition,
    "driving_licence_doc": drivingLicenceDoc,
    "passport_doc": passportDoc,
    "cpc_doc": cpcDoc,
    "tacho_doc": tachoDoc,
    "proof_of_address_doc": proofOfAddressDoc,
    "bank_detail": bankDetail?.toJson(),
    "consultant": consultant,


    "marital_status": maritalStatus,
    "is_uk_citizen":isUkCitizen,
    "is_authorized_to_work_in_uk": isAuthorizedToWorkInUk,
    "has_unspent_criminal_convictions": hasUnspentCriminalConvictions,
    "unspent_criminal_convictions_details":unspentCriminalConvictionsDetails,
    "uk_driving_experience":ukDrivingExperience,
    "valid_uk_driving_license":validUkDrivingLicense,
    "penalty_points":penaltyPoints,
    "driving_license_number":drivingLicenseNumber,
    "driving_license_category":drivingLicenseCategory,
    "driving_license_check_code":drivingLicenseCheckCode,
    "driving_license_issue_date":drivingLicenseIssueDate,

    "physical_incapabilities":physicalIncapabilities,
    "ongoing_medical_conditions":ongoingMedicalConditions,
    "taking_medication":takingMedication,
    "drug_or_alcohol_issues":drugOrAlcoholIssues,
    "wears_glasses":wearsGlasses,
    "dismissed_for_medical_reasons":dismissedForMedicalReasons,
    "dismissed_from_driving_roles":dismissedFromDrivingRoles,
    "medical_condition_details":medicalConditionDetails,
    "medication_details":medicationDetails,
    "dismissal_reason":dismissalReason,
    "driving_dismissal_details":drivingDismissalDetails,
    "last_eye_test":lastEyeTest,
    "noCpcCard":noCpcCard,
    "noTachoCard":noTachoCard,

  };
}

class BankDetail {
  String? accountType;
  String? bankName;
  String? accountName;
  int? accountNumber;
  String? bankCode;
  String? buildingSocietyRollNumber;
  dynamic recipientAddress1;
  dynamic recipientAddress2;
  dynamic recipientAddress3;
  String? iban;
  String? bicSwiftCode;
  String? paymentIsoCode;
  String? creditIsoCode;

  BankDetail({
    this.accountType,
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.bankCode,
    this.buildingSocietyRollNumber,
    this.recipientAddress1,
    this.recipientAddress2,
    this.recipientAddress3,
    this.paymentIsoCode,
    this.creditIsoCode,
    this.iban,
    this.bicSwiftCode,
  });

 factory BankDetail.fromJson(Map<String, dynamic> json) => BankDetail(
    accountType: json["account_type"],
    bankName: json["bank_name"],
    accountName: json["account_name"],
    accountNumber: json["account_number"] != null
        ? int.tryParse(json["account_number"].toString())
        : null, // Convert to int if possible
    bankCode: json["bank_code"],
    buildingSocietyRollNumber: json["building_society_roll_number"],
    recipientAddress1: json["recipient_address1"],
    recipientAddress2: json["recipient_address2"],
    recipientAddress3: json["recipient_address3"],
    paymentIsoCode: json["payment_iso_country_code"],
    creditIsoCode: json["credit_iso_currency_code"],
    iban: json["iban"],
    bicSwiftCode: json["bic_swift"],
  );


  Map<String, dynamic> toJson() => {
    "account_type": accountType,
    "bank_name": bankName,
    "account_name": accountName,
    "account_number": accountNumber,
    "bank_code": bankCode,
    "building_society_roll_number": buildingSocietyRollNumber,
    "recipient_address1": recipientAddress1,
    "recipient_address2": recipientAddress2,
    "recipient_address3": recipientAddress3,
    "payment_iso_country_code": paymentIsoCode,
    "credit_iso_currency_code": creditIsoCode,
    "iban": iban,
    "bic_swift": bicSwiftCode,
  };
}
