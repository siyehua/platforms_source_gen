enum ClassType {
  none,
  normal,
  abstract,
  enumType,
}

class ClassInfo {
  ClassInfo();
  bool hasDefaultConstructor = false;
  ClassType type = ClassType.none;
  String name = "";

  @override
  String toString() {
    return 'ClassInfo{type: $type, name: $name}';
  }

  ClassInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = ClassType.values[json['type']];
    hasDefaultConstructor = json['hasDefaultConstructor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['type'] = this.type.index;
    data['hasDefaultConstructor'] = this.hasDefaultConstructor;
    return data;
  }
}

ClassInfo _tmpClassNameStr = ClassInfo();

ClassInfo getClassInfo() {
  return _tmpClassNameStr;
}

void clearClassInfo() {
  _tmpClassNameStr = ClassInfo();
}

/// return :
/// 0: no class line
/// 1: class start
/// 2: class end
///
int parseClass(String str) {
  String normalClass = r"[ ]*class[ ]*\S+[ ]*\{";
  String abstractClass = r"[ ]*abstract[ ]*class[ ]*\S+[ ]*\{";
  RegExp regExp = new RegExp(normalClass);
  RegExp regExp2 = new RegExp(abstractClass);
  if (regExp2.hasMatch(str)) {
    _tmpClassNameStr.name = str
        .replaceAll("class", "")
        .replaceAll("abstract", "")
        .replaceAll("{", "")
        .trim();
    _tmpClassNameStr.type = ClassType.abstract;
    // print("abstract class:$_tmpClassNameStr");
    return 1;
  } else if (regExp.hasMatch(str)) {
    _tmpClassNameStr.name =
        str.replaceAll("class", "").replaceAll("{", "").trim();
    _tmpClassNameStr.type = ClassType.normal;
    return 1;
  } else if (str.contains("enum")) {
    _tmpClassNameStr.name =
        str.replaceAll("enum", "").replaceAll("{", "").trim();
    _tmpClassNameStr.type = ClassType.enumType;
    return 1;
  } else if (str == "}") {
    return 2;
  }
  return 0;
}
