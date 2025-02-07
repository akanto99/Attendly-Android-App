import 'dart:convert';

StaffFileListView staffFileListViewFromJson(String str) => StaffFileListView.fromJson(json.decode(str));

String staffFileListViewToJson(StaffFileListView data) => json.encode(data.toJson());

class StaffFileListView {
  List<Datum> ? data;
  int status;

  StaffFileListView({
    required this.data,
    required this.status,
  });

  factory StaffFileListView.fromJson(Map<String, dynamic> json) => StaffFileListView(
    data: (json['data'] as List<dynamic>?)?.map((e) => Datum.fromJson(e as Map<String, dynamic>)).toList(),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.map((x) => x.toJson()).toList(),
    "status": status,
  };
}

class Datum {
  int ? id;
  String ? fileType;
  String ? fileName;
  String ? viewUrl;
  String ? downloadUrl;

  Datum({
    this.id,
    this.fileName,
    this.fileType,
    this.viewUrl,
    this.downloadUrl,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    fileName: json["file_name"],
    fileType: json["file_type"],
    viewUrl: json["viewUrl"],
    downloadUrl: json["downloadUrl"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "file_name": fileName,
    "file_type": fileType,
    "viewUrl": viewUrl,
    "downloadUrl": downloadUrl,
  };
}