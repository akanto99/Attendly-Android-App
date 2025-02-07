// To parse this JSON data, do
//
//     final periodGetRates = periodGetRatesFromJson(jsonString);

import 'dart:convert';

PeriodGetRates periodGetRatesFromJson(String str) => PeriodGetRates.fromJson(json.decode(str));

String periodGetRatesToJson(PeriodGetRates data) => json.encode(data.toJson());

class PeriodGetRates {
  int id;
  String slug;
  String clientSlug;
  String driverSlug;
  dynamic availabilityStatus;

  PeriodGetRates({
    required this.id,
    required this.slug,
    required this.clientSlug,
    required this.driverSlug,
     this.availabilityStatus,
  });

  factory PeriodGetRates.fromJson(Map<String, dynamic> json) => PeriodGetRates(
    id: json["id"],
    slug: json["slug"],
    clientSlug: json["client_slug"],
    driverSlug: json["driver_slug"],
    availabilityStatus: json["availability_status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "client_slug": clientSlug,
    "driver_slug": driverSlug,
    "availability_status": availabilityStatus,
  };
}
