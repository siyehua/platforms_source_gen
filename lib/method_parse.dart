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

MethodInfo parseMethod(String str) {
  RegExp exp = new RegExp(r"^\S+[ ]+\S+\(.*\)\;|^\S+Map<.*,.*>[ ]+\S+\(.*\)\;");
  if (exp.hasMatch(str)) {
    str = str.replaceAll(")", "").replaceAll(";", "");

    MethodInfo methodInfo = MethodInfo();

    List<String> tmpList = str.split("(");
    int lastSpace = tmpList[0].trim().lastIndexOf(" ");
    List<String> leftStr = [
      tmpList[0].trim().substring(0, lastSpace + 1).replaceAll(" ", ""),
      tmpList[0].trim().substring(lastSpace + 1)
    ];

    String right = tmpList[1].trim();
    String tmpRight = tmpList[1].trim();
    RegExp exp2 = new RegExp(r"Map<.*,.*>");
    Map<String, String> want = {};
    if (exp2.hasMatch(right)) {
      exp2.allMatches(right).toList().asMap().forEach((index, element) {
        want["siyehua_" + index.toString()] = element.group(0);
        tmpRight = tmpRight.replaceFirst(
            element.group(0), "siyehua_" + index.toString());
      });
    }

    List<String> rightStr = tmpRight.split(",");
    Map<int, String> tmpMap = rightStr.asMap();
    want.forEach((key, value) {
      int index = -1;
      tmpMap.forEach((key1, value2) {
        if (value2.contains(key)) {
          index = key1;
        }
      });
      if (index != -1) {
        rightStr.replaceRange(
            index, index + 1, [rightStr[index].replaceFirst(key, value)]);
      }
    });
    methodInfo.name = leftStr[1];
    Property returnType = parseProperty(leftStr[0] + " a;");
    methodInfo.returnType = returnType;
    rightStr.forEach((element) {
      element = element.trim();
      if (element.isNotEmpty) {
        Property arg = parseProperty(element);
        methodInfo.args.add(arg);
      }
    });
    return methodInfo;
  }
  return null;
}
