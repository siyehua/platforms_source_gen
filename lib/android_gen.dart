import 'dart:io';

import 'bean/method_parse.dart';
import 'gen_file_edit.dart';
import 'platforms_source_gen.dart';
import 'bean/property_parse.dart';
import 'type_utils.dart';

/// Java file create
class JavaCreate {
  static void create(
      String packageName, String defaultSavePath, List<GenClassBean> genClassBeans,
      {bool nullSafe = true}) {
    Directory androidTargetDir = Directory(defaultSavePath);
    bool exists = androidTargetDir.existsSync();
    if (!exists) {
      androidTargetDir.createSync(recursive: true);
    }
    genClassBeans.forEach((value) {
      var path = defaultSavePath;
      if(value.savePath.isNotEmpty) {
        path = value.savePath;
      }
      File javaFile = File(path + "/" + value.classInfo.name + ".java");

      //package
      String allContent = "package " + packageName + ";\n";

      //import
      List<String> imports = [
        "import java.util.ArrayList;\n",
        "import java.util.HashMap;\n",
        "import org.jetbrains.annotations.NotNull;\n",
        "import org.jetbrains.annotations.Nullable;\n",
      ];
      imports.addAll(value.imports.where((element) => !element.contains(".dart")));
      String importStr = imports
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "")
          .replaceAll(",", "");

      //property
      String propertyStr = property(value, value.properties);

      //method
      String methodStr = method(value.methods);

      String absStr = "class";
      if (value.classInfo.type == 1) {
        absStr = "interface";
      }
      allContent +=
          "${importStr}public ${absStr} ${value.classInfo.name} {\n$propertyStr ${methodStr} \n}";
      if (!nullSafe) {
        allContent = GenFileEdit.removeJavaNullSafe(allContent);
      }
      if (!javaFile.parent.existsSync()) {
        javaFile.parent.createSync(recursive: true);
      }
      javaFile.writeAsStringSync(allContent);
      if (!javaFile.existsSync()) {
        //if not create use dart io, use shell
        _savePath(allContent, javaFile.path);
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
      // if (genBean.classInfo.type == 1) {
      //   //java interface can't have any default value.
      //   defaultValue = "";
      // }
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
              (TypeUtils.javaMap[property.type] ?? "") +
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
    String typeStr;
    var baseType = TypeUtils.javaMap[property.type];
    if (baseType != null) {
      //base
      typeStr = baseType;
    } else {
      //other not base type
      typeStr = property.type.split(".").last;
    }
    if (showNullTag && typeStr != "void") {
      typeStr = (property.canBeNull ? " @Nullable " : " @NotNull ") + typeStr;
    }
    if (property.subType.isNotEmpty) {
      typeStr += "<";
      property.subType.forEach((element) {
        typeStr += getTypeStr(element, showNullTag: false) + ", ";
      });
      if (typeStr.endsWith(", ")) {
        //remove ", " ,because java method arg can't end with ", "
        typeStr = typeStr.substring(0, typeStr.length - 2);
      }
      typeStr += ">";
    }
    if (wantAddPre) {
      if (property.isConst) {
        typeStr = " final " + typeStr;
      }
      if (property.isStatic) {
        typeStr = " static " + typeStr;
      }
      if (property.isPrivate) {
        typeStr = " private " + typeStr;
      } else {
        typeStr = " public " + typeStr;
      }
    }
    return typeStr;
  }
}
