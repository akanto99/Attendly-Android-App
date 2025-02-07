class StaffRole {
  StaffRole({
    List<Data>? data,
  }) {
    _data = data;
  }

  StaffRole.fromJson(dynamic json) {
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  List<Data>? _data;
  StaffRole copyWith({
    List<Data>? data,
  }) =>
      StaffRole(
        data: data ?? _data,
      );
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Data {
  Data({
    num? id,
    String? staffType,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _staffType = staffType;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _id = json['id'];
    _staffType = json['staff_type'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  num? _id;
  String? _staffType;
  String? _createdAt;
  String? _updatedAt;
  Data copyWith({
    num? id,
    String? staffType,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        id: id ?? _id,
        staffType: staffType ?? _staffType,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  num? get id => _id;
  String? get staffType => _staffType;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['staff_type'] = _staffType;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
