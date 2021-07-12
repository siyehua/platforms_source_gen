import 'property_parse.dart';

class MethodInfo {
  String name = "";
  List<Property> args = [];
  Property returnType = Property();
  bool isAbstract = false;

  MethodInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    isAbstract = json['isAbstract'];
    if (json['args'] != null) {
      args = [];
      json['args'].forEach((v) {
        args.add(Property.fromJson(v));
      });
    }
    returnType = json['returnType'] != null
        ? Property.fromJson(json['returnType'])
        : Property();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = this.name;
    data['isAbstract'] = this.isAbstract;
    data['args'] = this.args.map((v) => v.toJson()).toList();
    data['returnType'] = this.returnType.toJson();
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
