
class ConsultantNames {
  ConsultantNames({
      String? name,}){
    _name = name;
}

  ConsultantNames.fromJson(dynamic json) {
    _name = json['name'];
  }
  String? _name;
ConsultantNames copyWith({  String? name,
}) => ConsultantNames(  name: name ?? _name,
);
  String? get name => _name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = _name;
    return map;
  }

}