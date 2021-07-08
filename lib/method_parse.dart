import 'property_parse.dart';

class MethodInfo {
  String name;
  List<Property> args = [];
  Property returnType;
  bool isAbstract = false;

  MethodInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    isAbstract = json['isAbstract'];
    if (json['args'] != null) {
      args = [];
      json['args'].forEach((v) {
        args.add(new Property.fromJson(v));
      });
    }
    returnType = json['returnType'] != null
        ? new Property.fromJson(json['returnType'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['isAbstract'] = this.isAbstract;
    if (this.args != null) {
      data['args'] = this.args.map((v) => v.toJson()).toList();
    }
    if (this.returnType != null) {
      data['returnType'] = this.returnType.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return '''{
                "name": "$name", 
                "args": $args, 
                "isAbstract": $isAbstract, 
                "returnType": $returnType
              }''';
  }

  MethodInfo();
}
