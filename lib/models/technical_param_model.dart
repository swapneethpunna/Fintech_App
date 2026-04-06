class TechnicalParams {
  List<After> before;
  List<After> after;

  TechnicalParams({
    required this.before,
    required this.after,
  });

  factory TechnicalParams.fromJson(Map<String, dynamic> json) {
    return TechnicalParams(
      before: (json["Before"] as List<dynamic>?)
              ?.map((e) => After.fromJson(e))
              .toList() ??
          [],
      after: (json["After"] as List<dynamic>?)
              ?.map((e) => After.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class After {
  String name;
  String aLabel1;
  String aValue1;
  String aLabel2;
  String aValue2;
  String aLabel3;
  String aValue3;

  After({
    required this.name,
    required this.aLabel1,
    required this.aValue1,
    required this.aLabel2,
    required this.aValue2,
    required this.aLabel3,
    required this.aValue3,
  });

  factory After.fromJson(Map<String, dynamic> json) {
    return After(
      name: json['Name'] ?? '',
      aLabel1: json['a_label1'] ?? '',
      aValue1: json['a_value1'] ?? '',
      aLabel2: json['a_label2'] ?? '',
      aValue2: json['a_value2'] ?? '',
      aLabel3: json['a_label3'] ?? '',
      aValue3: json['a_value3'] ?? '',
    );
  }
}
