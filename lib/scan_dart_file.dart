import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:mirrors';

import 'bean/class_parse.dart';
import 'bean/method_parse.dart';
import 'platforms_source_gen.dart';
import 'bean/property_parse.dart';

List<String> fileContent = [];
String tmpPath = "";

/// reflect class and parse it
List<GenClassBean> reflectStart(List<Type> types, String path) {
  var genClassList = <GenClassBean>[];
  types.forEach((element) {
    var genClass = GenClassBean();
    genClassList.add(genClass);

    /// ready
    var classMirror = reflectClass(element);

    if (path.isNotEmpty && path != tmpPath) {
      //read dart file content
      var file = File(path);
      fileContent = file.readAsLinesSync();
      tmpPath = path;
    }
    MethodMirror? constructorMethodMirror;
    constructorMethodMirror = classMirror.declarations.values.firstWhere(
            (element) => element is MethodMirror && element.isConstructor)
        as MethodMirror?;
    InstanceMirror? instanceMirror;
    if (!classMirror.isAbstract && !classMirror.isEnum) {
      try {
        instanceMirror = classMirror
            .newInstance(constructorMethodMirror!.constructorName, []);
      } catch (e) {
        print(e);
        throw "can't found default constructor method, please remove other constructor method!";
      }
    }
    var declarations = classMirror.declarations;

    ///set path
    genClass.path = classMirror.location.toString();

    ///set class info
    var classInfo = ClassInfo();
    if (classMirror.isAbstract) {
      classInfo.type = ClassType.abstract;
    } else if (classMirror.isEnum) {
      classInfo.type = ClassType.enumType;
    } else {
      classInfo.type = ClassType.normal;
    }
    classInfo.name = element.toString();
    genClass.classInfo = classInfo;

    ///set property
    var allProperty = <Property>[];
    var propertyList = declarations.values
        .where((element) => element is VariableMirror)
        .map((e) => e as VariableMirror)
        .toList();
    var propertyLocations = propertyList
        .map((e) => e.location)
        .where((value) => value != null)
        .map((e) => e!)
        .toList();
    allProperty.addAll(_parsePropertyTypes(
        classMirror, instanceMirror, propertyList, propertyLocations));
    genClass.properties = allProperty;

    ///set method
    var allMethod = <MethodInfo>[];
    if (classInfo.type != ClassType.enumType) {
      var methodList = declarations.values
          .where((element) => element is MethodMirror && !element.isConstructor)
          .map((e) => e as MethodMirror)
          .toList();
      var lastMethodLocation = classMirror.location!.line;
      methodList.asMap().forEach((index, element) {
        String methodLineStr = fileContent[element.location!.line - 1];
        var method = MethodInfo();
        method.name = MirrorSystem.getName(element.simpleName);
        method.isAbstract = element.isAbstract;
        method.originDeclaration = methodLineStr;
        method.comment = _parseComment(
            fileContent, element.location!.line - 1, lastMethodLocation);
        lastMethodLocation = element.location!.line - 1;
        int argParamsStartIndex =
            methodLineStr.indexOf(method.name) + method.name.length + 1;
        element.parameters.forEach((param) {
          // param.isOptional
          var property = Property();
          method.args.add(property);
          var type = param.type;
          property.type = MirrorSystem.getName(type.qualifiedName);
          property.name = MirrorSystem.getName(param.simpleName);
          String startStr = methodLineStr.substring(argParamsStartIndex);
          int start = startStr.indexOf(property.type.split(".").last);
          int end = startStr.indexOf(" " + property.name, start) + 1;
          argParamsStartIndex += end + property.name.length;
          startStr = startStr
              .substring(start + property.type.split(".").last.length, end)
              .trim();
          if (startStr.endsWith("?")) {
            property.canBeNull = true;
            startStr = startStr.substring(0, startStr.length - 1);
          }
          if (startStr.isEmpty) {
            startStr = "<>";
          }
          startStr = startStr.replaceAll("<", "{").replaceAll(">", "}");
          String newLineContent = _formatTypeStr2JsonStr(startStr, 0, "");
          Map<dynamic, dynamic> typeJson = jsonDecode(newLineContent);
          _findMethodArgumentsType(
              property, param.type.typeArguments, typeJson);
        });

        var returnProperty = Property();
        String targetLineStr =
            methodLineStr.split(method.name).first.replaceAll(" ", "");
        if (targetLineStr.endsWith("?")) {
          returnProperty.canBeNull = true;
        }
        if (targetLineStr.isNotEmpty) {
          targetLineStr = "<$targetLineStr>";
          String jsonStr =
              targetLineStr.replaceAll("<", "{").replaceAll(">", "}");
          String newLineContent = _formatTypeStr2JsonStr(jsonStr, 0, "");
          Map<dynamic, dynamic> typeJson = jsonDecode(newLineContent);
          _findMethodArgumentsType(
              returnProperty, [element.returnType], typeJson);
          method.returnType = returnProperty.subType[0];
          method.returnType.canBeNull = returnProperty.canBeNull;
          allMethod.add(method);
        }
      });
    }
    genClass.methods = allMethod;
  });

  // print(genClassList);
  // print('reflectEnd! $types');
  return genClassList;
}

/// parse property types
List<Property> _parsePropertyTypes(
    ClassMirror classMirror,
    InstanceMirror? instanceMirror,
    List<VariableMirror> params,
    List<SourceLocation> locations) {
  var parameters = <Property>[];
  var lastPropertyLocation = locations.first.line;
  params.asMap().forEach((index, value) {
    var property = Property();
    parameters.add(property);
    var type = value.type;
    property.type = MirrorSystem.getName(type.qualifiedName);
    property.name = MirrorSystem.getName(value.simpleName);
    property.originDeclaration = fileContent[locations[index].line - 1];
    property.comment = _parseComment(
        fileContent, locations[index].line - 1, lastPropertyLocation);
    lastPropertyLocation = locations[index].line - 1;
    if (!classMirror.isEnum) {
      String targetLineStr = _checkPropertyCanBeNull(
        property,
        locations,
        index,
      );
      if (value.isStatic) {
        InstanceMirror instanceMirror = classMirror.getField(value.simpleName);
        property.defaultValue1 = "${instanceMirror.reflectee}";
      } else if (instanceMirror != null) {
        property.defaultValue1 =
            "${instanceMirror.getField(value.simpleName).reflectee}";
      }
      property.isStatic = value.isStatic;
      property.isConst = value.isConst;
      property.isPrivate = value.isPrivate;
      String jsonStr = targetLineStr.replaceAll("<", "{").replaceAll(">", "}");
      String newLineContent = _formatTypeStr2JsonStr(jsonStr, 0, "");
      Map<dynamic, dynamic> typeJson = jsonDecode(newLineContent);
      _findMethodArgumentsType(property, value.type.typeArguments, typeJson);
    }
  });
  return parameters;
}

/// parse property can be null
String _checkPropertyCanBeNull(
    Property property, List<SourceLocation> locations, int index) {
  String simpleType = property.type.split(".").last;

  // RegExp exp = RegExp("$simpleType.*${property.name}");
  String targetLineContent = fileContent[locations[index].line - 1].trim();
  int start = targetLineContent.indexOf(simpleType);
  int end = targetLineContent.lastIndexOf(" " + property.name) + 1;
  // print(
  //     "line: ${locations[index].line} \t\ttargetLineContent: $targetLineContent \t\t\ttype: $simpleType \tname:${property.name} \thasMatch:$hasMatch");
  if (start != -1 && end != -1) {
    int nullIndex = end - 2;
    bool canBeNull = targetLineContent.substring(nullIndex).startsWith("?");
    property.canBeNull = canBeNull;
    String result = targetLineContent
        .substring(start + simpleType.length, end)
        .replaceAll(" ", "");
    if (result.endsWith("?") && canBeNull) {
      result = result.substring(0, result.length - 1);
    }
    if (result.isEmpty) {
      result = "<>";
    }
    return result;
  }
  throw "can't parse class Property: $targetLineContent $property";
}

/// parse method's args type and nullSafe
void _findMethodArgumentsType(Property target, List<TypeMirror> typeArguments,
    Map<dynamic, dynamic> typeJson) {
  List<MapEntry<dynamic, dynamic>> typeJsonList = [];
  typeJson.forEach((key, value) {
    typeJsonList.add(MapEntry(key, value));
  });
  if (typeJson.length < typeArguments.length) {
    typeJsonList.add(typeJsonList.first);
  }
  typeArguments.asMap().forEach((index, value) {
    var property = Property();
    var typeArguments = MirrorSystem.getName(value.qualifiedName);
    property.type = typeArguments;
    var valueJson = typeJsonList[index];
    property.canBeNull = valueJson.key.contains("?");
    target.subType.add(property);
    _findMethodArgumentsType(property, value.typeArguments, valueJson.value);
  });
}

String _parseComment(List<String> fileContent, int methodDeclaredLocation,
    int lastMethodDecalaredLocation) {
  List<String> comment =
      fileContent.sublist(lastMethodDecalaredLocation, methodDeclaredLocation);
  String result = "";
  {
    RegExp regExp = RegExp(r'\/\/[^\n]*');
    List<Match> matchList = [];
    comment.forEach((element) {
      matchList.addAll(regExp.allMatches(element).toList());
    });
    matchList.map((Match m) {
      return m.input.substring(m.start, m.end);
    }).forEach((element) {
      result += "$element\n";
    });
  }
  {
    RegExp regExp = RegExp(r'/\*[\w\W]*?\*/');
    List<Match> matchList = regExp
        .allMatches(comment.toString().replaceAll("[", "").replaceAll("]", ""))
        .toList();
    matchList.map((Match m) {
      return m.input.substring(m.start, m.end);
    }).forEach((element) {
      result += "$element\n";
    });
  }
  return result;
}

/// format type str to json str
String _formatTypeStr2JsonStr(String jsonStr, int startIndex, String subStr) {
  //<List<String>, Map<String?, Map<int?, List<Map<String, int>>>>>
  // String jsonStr = targetLineContent.replaceAll("<", "{").replaceAll(">", "}");

  if (startIndex >= jsonStr.length) {
    return jsonStr;
  }
  String startChar = jsonStr[startIndex];
  // print("index:$index $char");

  if (startChar == "{") {
    if (subStr.isNotEmpty) {
      int leftCount = 0;
      bool hasAddQuestion = false;
      for (int i = startIndex + 1; i < jsonStr.length - 1; i++) {
        String char = jsonStr[i];
        if (char == "}") {
          if (leftCount == 0) {
            try {
              bool isQuestion = jsonStr[i + 1] == "?";
              if (isQuestion) {
                jsonStr = jsonStr.replaceRange(i + 1, i + 2, "");
                subStr += "?";
                hasAddQuestion = true;
              }
            } catch (e) {
              //jsonStr[i + 1] max
              // print(e);
            }
            //end
            break;
          } else {
            leftCount--;
          }
        } else if (char == "{") {
          leftCount++;
        }
      }
      int start = startIndex - subStr.length;
      if (hasAddQuestion) {
        start++;
      }
      jsonStr = jsonStr.replaceRange(start, startIndex, '"$subStr":');
      startIndex += 3;
      if (hasAddQuestion) {
        startIndex++;
      }
      subStr = "";
    }
  } else if (startChar == ",") {
    if (subStr.isNotEmpty) {
      jsonStr = jsonStr.replaceRange(
        startIndex - subStr.length,
        startIndex,
        '"$subStr":{}',
      );
      startIndex += 5;
      subStr = "";
    }
  } else if (startChar == "}") {
    if (subStr.isNotEmpty) {
      jsonStr = jsonStr.replaceRange(
          startIndex - subStr.length, startIndex, '"$subStr":{}');
      startIndex += 5;
      subStr = "";
    }
  } else {
    subStr += startChar;
  }
  startIndex++;
  return _formatTypeStr2JsonStr(jsonStr, startIndex, subStr);
}
