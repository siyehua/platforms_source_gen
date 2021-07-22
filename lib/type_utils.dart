import 'bean/property_parse.dart';

///Property Utils
class TypeUtils {
  static const Map<String, String> javaMap = {
    "dart.core.bool": "Boolean",
    "dart.core.int": "Long",
    "dart.core.double": "Double",
    "dart.core.String": "String",
    "dart.typed_data.Uint8List": "byte[]",
    "dart.typed_data.Int32List": "int[]",
    "dart.typed_data.Int64List": "long[]",
    "dart.typed_data.Float64List": "double[]",
    "dart.core.List": "ArrayList",
    "dart.core.Map": "HashMap",
  };
  static const Map<String, String> swiftMap = {
    "dart.core.bool": "Boolean",
    "dart.core.int": "Long",
    "dart.core.double": "Double",
    "dart.core.String": "String",
    "dart.typed_data.Uint8List": "byte[]",
    "dart.typed_data.Int32List": "int[]",
    "dart.typed_data.Int64List": "long[]",
    "dart.typed_data.Float64List": "double[]",
    "dart.core.List": "ArrayList",
    "dart.core.Map": "HashMap",
  };

  static String getPropertyNameStr(Property property) {
    return property.type.split(".").last;
  }

  static bool isListType(Property property) {
    return property.type == "dart.core.List";
  }

  static bool isMapType(Property property) {
    return property.type == "dart.core.Map";
  }

  static bool isBaseType(Property property) {
    if (isListType(property)) {
      return false;
    }
    if (isMapType(property)) {
      return false;
    }
    return javaMap.containsKey(property.type);
  }
}
