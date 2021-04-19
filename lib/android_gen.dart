import 'dart:io';
import 'dart:math';

import 'method_parse.dart';
import 'platforms_source_gen.dart';
import 'property_parse.dart';

class JavaCreate {
  static const Map<String, String> typeMap = {
    "bool": "Boolean",
    "int": "Long",
    "double": "Double",
    "String": "String",
    "Uint8List": "byte[]",
    "Int32List": "int[]",
    "Int64List": "long[]",
    "Float64List": "double[]",
    // "List": "ArrayList",
    // "Map": "HashMap",
  };

  static void create(
      String packageName, String savePath, List<GenClassBean> genClassBeans) {
    Directory androidTargetDir = new Directory(savePath);
    bool exists = androidTargetDir.existsSync();
    if (!exists) {
      androidTargetDir.createSync(recursive: true);
    }
    genClassBeans.forEach((value) {
      File javaFile = new File(savePath + "/" + value.classInfo.name + ".java");
      List<String> imports = [
        "import java.util.ArrayList;\n",
        "import java.util.HashMap;\n"
      ];
      imports.addAll(value.imports);
      String allContent = "package " + packageName + ";\n";
      String propertyStr = "";
      value.properties.forEach((property) {
        String typeStr = "";
        String name = "";
        String defaultValue = "";
        if (value.classInfo.type == 1) {
          //java interface can't have any default value.
          property.defaultValue1 = "";
        }
        if (property.typeInt == 1) {
          typeStr = property.type.replaceAll("List<", "ArrayList<");
          typeMap.forEach((key, value) {
            typeStr = typeStr.replaceAll(key, value);
          });
          name = property.name;
          if (property.defaultValue1 == null ||
              property.defaultValue1.isEmpty ||
              property.defaultValue1.replaceAll(" ", "") == "[]") {
            property.defaultValue1 = "new ArrayList<>()";
          } else {
            String valueStr = "new ArrayList<>();\n\t{\n";
            List<String> a = property.defaultValue1
                .replaceAll("[", "")
                .replaceAll("]", "")
                .split(",");
            var morExt = "";
            if (typeStr.contains("Long")) {
              morExt = "L";
            }
            a.forEach((element) {
              element = element.replaceAll("\t", "").trim();
              if (element.isNotEmpty) {
                RegExp exp = new RegExp(r"\S+\([ ]*\)");
                if (exp.hasMatch(element)) {
                  String str1 = exp.firstMatch(element).group(0);
                  String str2 =
                      "import $packageName.${str1.substring(0, str1.indexOf("("))};\n";
                  if (!imports.contains(str2)) {
                    imports.add(str2);
                  }
                  element = "new " + element;
                }
                valueStr += "\t\t$name.add($element$morExt);\n";
              }
            });
            valueStr += "\t}";
            defaultValue = valueStr;
          }
        } else if (property.typeInt == 2) {
          //set type
          typeStr = property.type.replaceAll("Map<", "HashMap<");
          typeMap.forEach((key, value) {
            typeStr = typeStr.replaceAll(key, value);
          });

          //set name
          name = property.name;

          //set default value
          if (property.defaultValue1 == null ||
              property.defaultValue1.isEmpty ||
              property.defaultValue1.replaceAll(" ", "") == "{}") {
            property.defaultValue1 = "new HashMap<>()";
          } else {
            String valueStr = "new HashMap<>();\n\t{\n";
            var morExt = "";
            if (typeStr.contains("Long")) {
              morExt = "L";
            }
            List<String> a = property.defaultValue1
                .replaceAll("{", "")
                .replaceAll("}", "")
                .trim()
                .split(",");
            a.forEach((element) {
              element = element.replaceAll(" ", "");
              if (element.isNotEmpty) {
                List<String> map = element.split(":");
                RegExp exp = new RegExp(r"\S+\([ ]*\)");
                if (exp.hasMatch(map[0]) || exp.hasMatch(map[1])) {
                  _addObjectImport(exp, map, 0, packageName, imports);
                  _addObjectImport(exp, map, 1, packageName, imports);
                }
                valueStr += "\t\t$name.put(${map[0]}, ${map[1]}$morExt);\n";
              }
            });
            valueStr += "\t}";
            defaultValue = valueStr;
          }
        } else {
          typeStr = property.type;
          typeStr = typeStr
              .replaceAll("Uint8List", "byte[]")
              .replaceAll("static const", "static final");
          typeMap.forEach((key, value) {
            typeStr = typeStr.replaceAll(key, value);
          });
          name = property.name;
          defaultValue = property.defaultValue1;
          if (defaultValue != null && defaultValue.isNotEmpty) {
            if (typeStr == "Long") {
              defaultValue += "L";
            } else if (typeStr == "byte[]") {
              defaultValue = defaultValue
                  .replaceAll("Uint8List", "new byte[")
                  .replaceAll("(", "")
                  .replaceAll(")", "");
              defaultValue += "]";
            } else {
              typeMap.forEach((key, value) {
                defaultValue = defaultValue
                    .replaceAll(key, "new " + value)
                    .replaceAll("]", "")
                    .replaceAll("(", "")
                    .replaceAll(")", "");
                if (defaultValue.contains("new ")) {
                  defaultValue += "]";
                }
              });
            }
          }
        }
        String tmpDefaultValue = "";
        if (defaultValue == null || defaultValue.isEmpty) {
          tmpDefaultValue = "";
        } else {
          tmpDefaultValue = "= $defaultValue";
        }
        propertyStr += "\tpublic $typeStr $name $tmpDefaultValue;\n";
      });
      String importStr = imports
          .toString()
          .replaceAll("[", "")
          .replaceAll("]", "")
          .replaceAll(",", "");

      String absStr = "class";
      if (value.classInfo.type == 1) {
        absStr = "interface";
      }
      allContent +=
          "${importStr}public ${absStr} ${value.classInfo.name} {\n$propertyStr ${_method(value.methods)} }";
      javaFile.writeAsStringSync(allContent);
      if (!javaFile.existsSync()) {
        //if not create use dart io, use shell
        _savePath(allContent, javaFile.path);
      }
    });
  }

  static void _savePath(String content, String path) async {
    ProcessResult a = await Process.run(
        'bash', ['-c', "echo '$content' >> $path"],
        runInShell: true);
    print("file: $path \n create result: ${a.exitCode}");
  }

  static void _addObjectImport(RegExp exp, List<String> map, int index,
      String packageName, List<String> imports) {
    String str1 = "";
    try {
      str1 = exp.firstMatch(map[index]).group(0);
      map[index] = "new " + map[index];
    } catch (e) {}
    String str2 =
        "import $packageName.${str1.substring(0, str1.indexOf("("))};\n";
    if (!imports.contains(str2)) {
      imports.add(str2);
    }
  }

  static String _method(List<MethodInfo> methods) {
    String result = "";
    methods.forEach((element) {
      String argType = "";
      element.args.forEach((element1) {
        argType += _getTypeStr(element1) + " " + element1.name + ", ";
      });
      if (argType.endsWith(", ")) {
        argType = argType.substring(0, argType.length - 2);
      }
      result += "\t" +
          _getTypeStr(element.returnType) +
          " " +
          element.name +
          "(" +
          argType +
          ");\n";
    });
    return result;
  }

  static String _getTypeStr(Property property) {
    String typeStr;
    if (property.typeInt == 1) {
      typeStr = property.type.replaceAll("List<", "ArrayList<");
      typeMap.forEach((key, value) {
        typeStr = typeStr.replaceAll(key, value);
      });
    } else if (property.typeInt == 2) {
      typeStr = property.type.replaceAll("Map<", "HashMap<");
      typeMap.forEach((key, value) {
        typeStr = typeStr.replaceAll(key, value);
      });
    } else {
      typeStr = property.type;
      typeStr = typeStr
          .replaceAll("Uint8List", "byte[]")
          .replaceAll("static const", "static final");
      typeMap.forEach((key, value) {
        typeStr = typeStr.replaceAll(key, value);
      });
    }
    return typeStr;
  }
}
