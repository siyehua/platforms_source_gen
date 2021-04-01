import 'property_parse.dart';

class MethodInfo {
// void a2(String a);
// void a2();
// void a2( );
// Future<Map<String, int>> a3(int a, bool b, String t);

  // Uint8List e1 = Uint8List(10);
  String name;
  List<Property> args = [];
  Property returnType;
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
