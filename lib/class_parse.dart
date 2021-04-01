class ClassInfo {
  int type = -1; //0. normal class, 1: abstract class
  String name;

  @override
  String toString() {
    return 'ClassInfo{type: $type, name: $name}';
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
    _tmpClassNameStr.type = 1;
    // print("abstract class:$_tmpClassNameStr");
    return 1;
  } else if (regExp.hasMatch(str)) {
    _tmpClassNameStr.name =
        str.replaceAll("class", "").replaceAll("{", "").trim();
    _tmpClassNameStr.type = 0;
    // print("normal class:$_tmpClassNameStr");
    return 1;
  } else if (str == "}") {
    return 2;
  }
  return 0;
}
