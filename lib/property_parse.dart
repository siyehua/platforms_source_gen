class Property {
  int typeInt = 0;//0: normal, 1:List, 2:Map
  String type = "";
  String name = "";
  String defaultValue1 = "";

  @override
  String toString() {
    return 'Property{type: $type, name: $name, defaultValue: $defaultValue1}';
  }
}

Property parseProperty(String str) {
  Property property = checkList(str);
  if (property != null) {
    return property;
  }
  property = checkMap(str);
  if (property != null) {
    return property;
  }
  property = checkNormal(str);
  return property;
}

Property checkNormal(String str) {
  if (str.contains("=")) {
    var result = str.split("=");
    Property property = checkNormal(result[0]);
    property.defaultValue1 = result[1].toString();
    // print(property);
    return property;
  } else {
    var data = [];
    List<String> result = [];
    int staticIndex = str.indexOf("static const");
    if (staticIndex != -1) {
      int subIndex1 = staticIndex + "static const".length;
      result.add(str.substring(0, subIndex1));
      result.add(str.substring(subIndex1));
    } else {
      result = str.split(" ");
    }
    result.asMap().forEach((index, element) {
      if (element.isNotEmpty) {
        data.add(element);
      }
    });
    if (result.length == 2) {
      result.add(null);
    }
    Property property = Property();
    property.typeInt = 0;
    property.type = result[0];
    property.name = result[1];
    property.defaultValue1 = result[2];
// print(property);
    return property;
  }
}

Property checkMap(String str) {
  if (str.startsWith("Map<")) {
    if (str.contains("=")) {
      var result = str.split("=");
      Property property = checkMap(result[0]);
      property.defaultValue1 = result[1];
      // print(property);
      return property;
    } else {
      Property property = Property();
      property.typeInt = 2;
      RegExp exp = new RegExp(r"Map<.*,.*>");
      RegExpMatch regExpMatch = exp.firstMatch(str);
      property.type = regExpMatch.group(0);
      property.name = str.substring(regExpMatch.end).trim();
      property.defaultValue1 = "";
      // print(property);
      return property;
    }
  }
  return null;
}

Property checkList(String str) {
  if (str.startsWith("List<")) {
    if (str.contains("=")) {
      var result = str.split("=");
      Property property = checkList(result[0]);
      property.defaultValue1 = result[1];
      // print(property);
      return property;
    } else {
      var data = [];
      var result = str.split(" ");
      result.asMap().forEach((index, element) {
        if (element.isNotEmpty) {
          data.add(element);
        }
      });
      if (result.length == 2) {
        result.add(null);
      }
      Property property = Property();
      property.typeInt = 1;
      property.type = result[0];
      property.name = result[1];
      property.defaultValue1 = result[2];
// print(property);
      return property;
    }
  }
  return null;
}
