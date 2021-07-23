import 'dart:io';

import 'method_parse.dart';
import 'platforms_source_gen.dart';
import 'property_parse.dart';

class ObjectiveCCreate {
  static const Map<String, String> baseTypeMap = {
    "dart.core.bool": "BOOL",
    "dart.core.int": "int",
    "dart.core.double": "double",
    "dart.core.String": "String",
  };
  static const Map<String, String> classTypeMap = {
    "dart.typed_data.Uint8List": "NSArray",
    "dart.typed_data.Int32List": "NSArray",
    "dart.typed_data.Int64List": "NSArray",
    "dart.typed_data.Float64List": "NSArray",
    "dart.core.List": "NSArray",
    "dart.core.Map": "NSDictionary",
  };

  static void create(String savePath, List<GenClassBean> genClassBeans) {
    Directory iosTargetDir = Directory(savePath);
    bool exists = iosTargetDir.existsSync();
    if (!exists) {
      iosTargetDir.createSync(recursive: true);
    }
    genClassBeans.forEach((value) {
      File ocHeaderFile = File(savePath + "/" + value.classInfo.name + ".h");

      //package
      String allContent = "";

      //import
      List<String> imports = [
        "#import <Foundation/Foundation.h>\n",
      ];
      imports.addAll(value.imports);
      String importStr = imports
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "")
          .replaceAll(",", "");

      allContent += "${importStr}";
      allContent += "\nNS_ASSUME_NONNULL_BEGIN\n";

      //property
      String propertyStr = property(value, value.properties);

      //method
      String methodStr = method(value.methods);

      String absStr = "@interface";
      allContent +=
          "${absStr} ${value.classInfo.name} : NSObject {\n$propertyStr ${methodStr} \n}";
      ocHeaderFile.writeAsStringSync(allContent);
      if (!ocHeaderFile.existsSync()) {
        //if not create use dart io, use shell
        _savePath(allContent, ocHeaderFile.path);
      }
    });
  }

  /// create property
  static String property(GenClassBean genBean, List<Property> properties) {
    String propertyStr = "";
    properties.forEach((property) {
      String typeStr = getTypeStr(property, wantAddPre: true);
      String name = property.name;
      String defaultValue = property.defaultValue1;
      if (defaultValue == "null") {
        //todo no way if the String == "null"; don't do it
        defaultValue = "";
      }
      if (defaultValue.isNotEmpty) {
        if (property.type == "dart.core.int" &&
            !defaultValue.endsWith("L") &&
            !defaultValue.endsWith("l")) {
          //if type is int, the java type is Long, so your should add 'L' to the default
          defaultValue += "L";
        } else if (property.type == "dart.core.String") {
          //string should wrap with ""
          defaultValue = "\"$defaultValue\"";
        } else if (property.type == "dart.typed_data.Uint8List" ||
            property.type == "dart.typed_data.Int32List" ||
            property.type == "dart.typed_data.Int64List" ||
            property.type == "dart.typed_data.Float64List") {
          defaultValue = " new " +
              (baseTypeMap[property.type] ?? "") +
              "{ " +
              defaultValue.replaceAll('[', '').replaceAll(']', '') +
              " }";
        } else if (property.type == "dart.core.List") {
          defaultValue = "new ArrayList<>()";
        } else if (property.type == "dart.core.Map") {
          defaultValue = "new HashMap<>()";
        }
        defaultValue = " = " + defaultValue;
      }
      propertyStr += "\t$typeStr $name $defaultValue;\n";
    });
    return propertyStr;
  }

  /// save all content use shell
  static void _savePath(String content, String path) async {
    ProcessResult a = await Process.run('bash',
        ['-c', "echo '${content.replaceAll("'", "\'\"\'\"\'")}' >> $path"],
        runInShell: true);
    print("file: $path \n create result: ${a.exitCode}");
  }

  // /// add import
  // static void _addObjectImport(RegExp exp, List<String> map, int index,
  //     String packageName, List<String> imports) {
  //   String str1 = "";
  //   try {
  //     str1 = exp.firstMatch(map[index]).group(0);
  //     map[index] = "new " + map[index];
  //   } catch (e) {}
  //   String str2 =
  //       "import $packageName.${str1.substring(0, str1.indexOf("("))};\n";
  //   if (!imports.contains(str2)) {
  //     imports.add(str2);
  //   }
  // }

  /// create method
  static String method(List<MethodInfo> methods) {
    String result = "";
    methods.forEach((method) {
      String argType = "";
      method.args.forEach((arg) {
        argType += getTypeStr(arg) + " " + arg.name + ", ";
      });
      if (argType.endsWith(", ")) {
        //remove ", " ,because java method arg can't end with ", "
        argType = argType.substring(0, argType.length - 2);
      }
      String body = ";";
      //don't support no abstract method
      // if (method.isAbstract) {
      //   body = ";";
      // } else {
      //   body = "{}";
      // }
      result += "\t" +
          getTypeStr(method.returnType) +
          " " +
          method.name +
          "(" +
          argType +
          ")$body\n";
    });
    return result;
  }

  /// cover dart type to java type
  /// [wantAddPre] if true, it when add pre keywords, like: public static final .....
  static String getTypeStr(
    Property property, {
    bool wantAddPre = false,
    bool showNullTag = true,
  }) {
    String typeStr = "@property (nonatomic, ";
    var baseType = baseTypeMap[property.type];
    var classType = classTypeMap[property.type];
    if (baseType != null) {
      //base
      typeStr += "assign) " + baseType;
    } else if (classType != null) {
      typeStr += "strong";
      if (showNullTag && typeStr != "void") {
        typeStr += (property.canBeNull ? ", nullalbe) " : ") ") + classType;
      }
    } else {
      //other not base type
      typeStr = property.type.split(".").last;
    }
    // if (property.subType.isNotEmpty) {
    //   typeStr += "<";
    //   property.subType.forEach((element) {
    //     typeStr += getTypeStr(element, showNullTag: false) + ", ";
    //   });
    //   if (typeStr.endsWith(", ")) {
    //     //remove ", " ,because java method arg can't end with ", "
    //     typeStr = typeStr.substring(0, typeStr.length - 2);
    //   }
    //   typeStr += ">";
    // }
    // if (wantAddPre) {
    //   if (property.isConst) {
    //     typeStr = " final " + typeStr;
    //   }
    //   if (property.isStatic) {
    //     typeStr = " static " + typeStr;
    //   }
    //   if (property.isPrivate) {
    //     typeStr = " private " + typeStr;
    //   } else {
    //     typeStr = " public " + typeStr;
    //   }
    // }
    return typeStr;
  }
}
