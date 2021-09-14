import 'dart:io';

import 'package:platforms_source_gen/bean/class_parse.dart';

import 'bean/method_parse.dart';
import 'platforms_source_gen.dart';
import 'bean/property_parse.dart';
import 'extension/string_extension.dart';

enum ObjectivePropertType {
  base,
  systemClass,
  customClass,
  specialType,
}

class ObjectiveCCreate {
  static Map<String, String> baseTypeMap = {
    "dart.core.bool": "BOOL",
    "dart.core.int": "int",
    "dart.core.double": "double",
  };
  static const Map<String, String> classTypeMap = {
    "dart.core.String": "NSString",
    "dart.typed_data.Uint8List": "NSData",
    "dart.typed_data.Int32List": "NSData",
    "dart.typed_data.Int64List": "NSData",
    "dart.typed_data.Float64List": "NSData",
    "dart.core.List": "NSArray",
    "dart.core.Map": "NSDictionary",
    "number": "NSNumber",
    "void": "void",
    "dart.core.Object": "id",
  };
  static const Map<String, String> specialTypeMap = {
    "dart.async.Future": "",
  };

  static var prefix = "";

  static void create(
      String projectPrefix, String savePath, List<GenClassBean> genClassBeans) {
    if (projectPrefix.isEmpty) {
      projectPrefix = "PSG"; // platforms source generator
    }
    _createHeaderFile(projectPrefix, savePath, genClassBeans);
    _createImplementFile(projectPrefix, savePath, genClassBeans);
  }

  static ObjectivePropertType typeOf(Property property) {
    if (baseTypeMap.keys.contains(property.type)) {
      return ObjectivePropertType.base;
    } else if (classTypeMap.keys.contains(property.type)) {
      return ObjectivePropertType.systemClass;
    } else if (specialTypeMap.keys.contains(property.type)) {
      return ObjectivePropertType.specialType;
    } else {
      return ObjectivePropertType.customClass;
    }
  }

  /// create property
  static String property(List<Property> properties) {
    String propertyStr = "";
    properties.forEach((property) {
      String typeStr = _getPropertyStr(property);
      String name = property.name;
      propertyStr += "$typeStr$name;\n";
    });
    return propertyStr;
  }

  static String getTypeString(Property property,
      {bool convertToClass = false}) {
    String typeString = "";
    switch (typeOf(property)) {
      case ObjectivePropertType.base:
        var baseType = baseTypeMap[property.type];
        if (convertToClass) {
          typeString += "NSNumber *";
        } else {
          typeString += "$baseType ";
        }
        break;
      case ObjectivePropertType.systemClass:
        var classType = classTypeMap[property.type];
        if (classType!.isNotEmpty) {
          typeString += "$classType";
        }
        if (property.subType.isNotEmpty) {
          String subTypeString = _getSubTypeString(property);
          typeString += subTypeString;
        }
        typeString += " ";
        if (!_isBaseClassObjectType(property)) {
          typeString += "*";
        }
        break;
      case ObjectivePropertType.specialType:
        typeString = getTypeString(property.subType.first);
        break;
      default:
        typeString += "$prefix${property.type.split(".").last}";
        if (property.subType.isNotEmpty) {
          String subTypeString = _getSubTypeString(property, showNullTag: true);
          typeString += subTypeString;
        }
        typeString += " *";
    }
    return typeString;
  }

  /// create method
  static String method(List<MethodInfo> methods) {
    String result = "";
    methods.forEach((method) {
      String methodComment =
          "\n${method.comment}/// Dart method declaraction: ${method.originDeclaration}\n";
      method.args.forEach((element) {
        methodComment +=
            "/// @param ${element.name} Agument ${element.name}, type: ${element.type}.\n";
      });
      result += methodComment;
      result += "- (" + getTypeString(method.returnType) + ")" + method.name;
      String argType = "";
      if (!method.args.isEmpty) {
        result += ":";
        for (var i = 0; i < method.args.length; i++) {
          Property arg = method.args[i];
          if (i > 0) {
            argType += " ${arg.name}:";
          }
          argType += "(";
          if (arg.canBeNull && typeOf(arg) != ObjectivePropertType.base) {
            argType += "nullable ";
          }
          argType += getTypeString(arg) + ")" + arg.name;
        }
      }
      result += "$argType;\n";
    });
    return result;
  }

  static void _createHeaderFile(
      String projectPrefix, String savePath, List<GenClassBean> genClassBeans) {
    Directory iosTargetDir = Directory(savePath);
    prefix = projectPrefix;
    bool exists = iosTargetDir.existsSync();
    if (!exists) {
      iosTargetDir.createSync(recursive: true);
    }
    genClassBeans.forEach((value) {
      if (value.classInfo.type == ClassType.enumType) {
        // add all enum type into base type map
        baseTypeMap[".${value.classInfo.name}"] =
            "$projectPrefix${value.classInfo.name}";
      }
    });
    genClassBeans.forEach((value) {
      File ocHeaderFile =
          File(savePath + "/" + projectPrefix + value.classInfo.name + ".h");
      //package
      String allContent = "";

      //import
      List<String> imports = [
        "#import <Foundation/Foundation.h>\n",
      ];
      String importStr = imports
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "")
          .replaceAll(",", "");

      allContent += "${importStr}";
      allContent += "${_staticPropertyImplementation(value)}";
      if (!_isStaticPropertiesOnly(value)) {
        allContent += _getCustomClassImport(value);
        allContent += "\nNS_ASSUME_NONNULL_BEGIN\n";

        //property
        String propertyStr = "";
        //method
        String methodStr = "";
        String defineString = "\n";
        String defineSuffixString = "";
        String defineEndString = "@end";
        switch (value.classInfo.type) {
          case ClassType.abstract:
            defineString += "@protocol";
            defineSuffixString = " <NSObject>\n@required";
            methodStr = method(value.methods);
            break;
          case ClassType.enumType:
            defineString += "typedef NS_ENUM(NSUInteger, ";
            defineSuffixString = ") {";
            defineEndString = "};";
            propertyStr = _parseEnumMember(value);
            break;
          default:
            defineString += "@interface";
            defineSuffixString = " : NSObject <NSCopying>";
            propertyStr = property(value.properties);
            break;
        }
        allContent += "${defineString} ${projectPrefix}${value.classInfo.name}";
        allContent +=
            "$defineSuffixString\n\n$propertyStr\n${methodStr}\n$defineEndString\nNS_ASSUME_NONNULL_END";
      }
      if (!ocHeaderFile.parent.existsSync()) {
        ocHeaderFile.parent.createSync(recursive: true);
      }
      ocHeaderFile.writeAsStringSync(allContent);
      if (!ocHeaderFile.existsSync()) {
        //if not create use dart io, use shell
        _savePath(allContent, ocHeaderFile.path);
      }
    });
  }

  static String _parseEnumMember(GenClassBean classBean) {
    String enumMemberString = "";
    classBean.properties.forEach((property) {
      if (property.type.split(".").last == classBean.classInfo.name) {
        enumMemberString +=
            "$prefix${classBean.classInfo.name}${property.name.capitalize()},\n";
      }
    });
    return enumMemberString;
  }

  static void _createImplementFile(
      String projectPrefix, String savePath, List<GenClassBean> genClassBeans) {
    genClassBeans.forEach((value) {
      if (value.classInfo.type == ClassType.normal &&
          !_isStaticPropertiesOnly(value)) {
        File ocImplementFile =
            File(savePath + "/" + projectPrefix + value.classInfo.name + ".m");
        //package
        String className = "${projectPrefix}${value.classInfo.name}";
        String allContent = "#import \"$className.h\"\n";
        allContent += "\nNS_ASSUME_NONNULL_BEGIN\n";
        allContent += "@implementation $className";

        //property
        allContent += _propertyImplementation(value.properties);

        //method
        allContent += _methodImplementationForClass(value);

        allContent += "\n@end\nNS_ASSUME_NONNULL_END";
        if (!ocImplementFile.parent.existsSync()) {
          ocImplementFile.parent.createSync(recursive: true);
        }
        ocImplementFile.writeAsStringSync(allContent);
        if (!ocImplementFile.existsSync()) {
          //if not create use dart io, use shell
          _savePath(allContent, ocImplementFile.path);
        }
      }
    });
  }

  static String _staticPropertyImplementation(GenClassBean classBean) {
    String staticPropertyStr = "";
    classBean.properties.forEach((property) {
      if (property.isStatic) {
        staticPropertyStr +=
            "#define ${prefix}${classBean.classInfo.name}_${property.name}\t${_defaultValueOf(property)}\n";
      }
    });
    if (staticPropertyStr.isNotEmpty) {
      staticPropertyStr += "\n";
    }
    return staticPropertyStr;
  }

  static String _propertyImplementation(List<Property> properties) {
    String propertyStr =
        "\n- (instancetype)init\n{\n\tself = [super init];\n\tif (self) {\n";
    properties.forEach((property) {
      if (!property.isStatic) {
        String name = property.name;
        String defaultValue = property.defaultValue1;
        if (defaultValue == "null") {
          defaultValue = "";
        }
        if (defaultValue.isNotEmpty) {
          propertyStr += "\t\tself.$name = ";
          defaultValue = _defaultValueOf(property);
          propertyStr += "$defaultValue;\n";
        }
      }
    });
    propertyStr += "\n\t}\n\treturn self;\n}\n";
    return propertyStr;
  }

  static String _methodImplementationForClass(GenClassBean classBean) {
    String result = "\n- (nonnull id)copyWithZone:(nullable NSZone *)zone\n{\n";
    result +=
        "\t${prefix}${classBean.classInfo.name} *value = [[self.class allocWithZone:zone] init];\n";
    classBean.properties.forEach((property) {
      result += "\tvalue.${property.name} = _${property.name};\n";
    });
    result += "\treturn value;\n}\n";
    return result;
  }

  static String _defaultValueOf(Property property) {
    String defaultValue = property.defaultValue1;
    if (property.type == "dart.core.String") {
      defaultValue = "@\"$defaultValue\"";
    } else if (property.type == "dart.typed_data.Uint8List" ||
        property.type == "dart.typed_data.Int32List" ||
        property.type == "dart.typed_data.Int64List" ||
        property.type == "dart.typed_data.Float64List") {
      // not implemented
      defaultValue = "nil";
    } else if (property.type == "dart.core.List") {
      defaultValue = defaultValue.replaceAll('[', '').replaceAll(']', '');
      if (defaultValue.isEmpty) {
        defaultValue = "[NSArray array]";
      } else {
        List<String> arguments = defaultValue.split(", ");
        arguments = _convertObjcDefaultValueFor(
            arguments, typeOf(property.subType.first));
        defaultValue =
            "[NSArray arrayWithObjects:${arguments.join(", ")}, nil]";
      }
    } else if (property.type == "dart.core.Map") {
      defaultValue = defaultValue.replaceAll("{", "").replaceAll("}", "");
      if (defaultValue.isEmpty) {
        defaultValue = "[NSDictionary dictionary]";
      } else {
        List<String> arguments = defaultValue.split(", ");
        Map<String, String> map = Map.fromIterable(arguments,
            key: ((e) => _converObjecDefaultValueFor(
                e.substring(0, e.indexOf(":")),
                typeOf(property.subType.first))),
            value: ((e) => _converObjecDefaultValueFor(
                e.substring(e.indexOf(":") + 2),
                typeOf(property.subType.last))));
        defaultValue = "@$map";
      }
    }
    return defaultValue;
  }

  static String _converObjecDefaultValueFor(
      String propertyString, ObjectivePropertType type) {
    return _convertObjcDefaultValueFor([propertyString], type).first;
  }

  static List<String> _convertObjcDefaultValueFor(
      List<String> propertiesString, ObjectivePropertType type) {
    List<String> arguments = [];
    switch (type) {
      case ObjectivePropertType.base:
        arguments = List.from(propertiesString.map((e) => "@" + e));
        break;
      case ObjectivePropertType.systemClass:
        // all convert to NSString
        arguments = List.from(propertiesString.map((e) => "@\"$e\""));
        break;
      case ObjectivePropertType.customClass:
        arguments = List.from(propertiesString.map((e) =>
            "${e.replaceAll("Instance of '", "[$prefix").replaceAll("'", " new]")}"));
        break;
      default:
    }
    return arguments;
  }

  static String _getCustomClassImport(GenClassBean classBean) {
    String importString = "";
    if (classBean.classInfo.type == ClassType.enumType) {
      return importString;
    }
    Set<String> customClassTypes = Set();
    classBean.properties.forEach((value) {
      String typeString = getTypeString(value);
      typeString = typeString.replaceAll(" *", "");
      typeString = typeString.replaceAll("<", ", ");
      typeString = typeString.replaceAll(">", "");
      customClassTypes.addAll(typeString.split(", "));
    });
    classBean.methods.forEach((method) {
      method.args.forEach((arg) {
        String typeString = getTypeString(arg);
        typeString = typeString.replaceAll(" *", "");
        typeString = typeString.replaceAll(" _Nullable", "");
        typeString = typeString.replaceAll("<", ", ");
        typeString = typeString.replaceAll(">", "");
        customClassTypes.addAll(typeString.split(", "));
      });
    });
    customClassTypes.forEach((element) {
      if (element.startsWith(prefix)) {
        importString += "#import \"${element.trim()}.h\"\n";
      }
    });
    return importString;
  }

  /// cover dart type to objc type
  static String _getPropertyStr(
    Property property, {
    bool showNullTag = true,
  }) {
    String propertyComment =
        "\n${property.comment}/// Dart property declaration: ${property.originDeclaration.trim()}.\n";
    String propertyString = "@property (nonatomic, ";
    switch (typeOf(property)) {
      case ObjectivePropertType.base:
        var baseType = baseTypeMap[property.type];
        propertyString += "assign) " + baseType! + " ";
        break;
      case ObjectivePropertType.systemClass:
        var classType = classTypeMap[property.type];
        propertyString += "strong";
        if (showNullTag && propertyString != "void") {
          propertyString +=
              (property.canBeNull ? ", nullable) " : ") ") + classType!;
        }
        if (property.subType.isNotEmpty) {
          propertyString += _getSubTypeString(property);
        }
        propertyString += " ";
        if (!_isBaseClassObjectType(property)) {
          propertyString += "*";
        }
        break;
      case ObjectivePropertType.customClass:
        propertyString += "strong";
        propertyString += (property.canBeNull ? ", nullable) " : ") ") +
            "$prefix${property.type.split(".").last} *";
        break;
      default:
    }
    return propertyComment + propertyString;
  }

  static String _getSubTypeString(Property property,
      {bool showNullTag = false}) {
    String subTypeString = "";
    subTypeString += "<";
    property.subType.forEach((element) {
      subTypeString += getTypeString(element, convertToClass: true);
      if (showNullTag &&
          element.canBeNull &&
          typeOf(element) != ObjectivePropertType.base) {
        subTypeString += " _Nullable";
      }
      subTypeString += ", ";
    });
    if (subTypeString.endsWith(", ")) {
      subTypeString = subTypeString.substring(0, subTypeString.length - 2);
    }
    subTypeString += ">";
    return subTypeString;
  }

  static bool _isBaseClassObjectType(Property property) {
    return property.type == "dart.core.Object" || property.type == "void";
  }

  static bool _isStaticPropertiesOnly(GenClassBean classBean) {
    bool onlyStaticProperties = false;
    if (classBean.properties.isNotEmpty) {
      onlyStaticProperties = true;
      classBean.properties.forEach((element) {
        if (!element.isStatic) {
          onlyStaticProperties = false;
          return;
        }
      });
    }
    return onlyStaticProperties;
  }

  /// save all content use shell
  static void _savePath(String content, String path) async {
    ProcessResult a = await Process.run('bash',
        ['-c', "echo '${content.replaceAll("'", "\'\"\'\"\'")}' >> $path"],
        runInShell: true);
    print("file: $path \n create result: ${a.exitCode}");
  }
}
