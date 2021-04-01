library platforms_source_gen;

import 'dart:io';
import 'dart:convert';

import 'android_gen.dart';
import 'class_parse.dart';
import 'method_parse.dart';
import 'property_parse.dart';

class GenClassBean {
  String path = "";
  ClassInfo classInfo;
  List<String> imports = [];
  List<MethodInfo> methods = [];
  List<Property> properties = [];
}

void main() {
 List<GenClassBean> genClassBeans =platforms_source_gen_init(
      "./lib/example", //you dart file path
      "com.siyehua.example", //your android's  java class package name
      "./Android_gen" //your android file save path
  );
  platforms_source_gent_start("com.siyehua.example", "./Android_gen", genClassBeans);
}

List<GenClassBean> platforms_source_gen_init(String dir, String javaPackage,
    String androidSavePath) {
  // String path = "./lib/example";
  // String javaPackage = "com.siyehua.example";
  // String androidSavePath = "./Android_gen";
  List<GenClassBean> list = [];
  Directory directory = Directory(dir);
  directory.listSync().forEach((file) {
    if (file is File) {
      list.addAll(_parseFile(file, javaPackage, androidSavePath));
    }
  });
  return list;
}

platforms_source_gent_start(String javaPackage, String androidSavePath,
    List<GenClassBean> genClassBeans) {
  JavaCreate.create(javaPackage, androidSavePath, genClassBeans);
}

List<GenClassBean> _parseFile(File file, String javaPackage,
    String androidSavePath) {
  List<String> importList = [];
  List<GenClassBean> genClassBeans = [];
  GenClassBean genClassBean = GenClassBean();
  genClassBean.path = file.path;
  file
  // .transform(utf8.decoder)
      .readAsLinesSync()
  // .transform(new LineSplitter())
      .forEach((str) {
    // print('read line: $str');
    str = _checkLineStr(str);
    if (str.isEmpty) {} else if (_foundImport(str, importList)) {} else {
      int classResult = parseClass(str);
      ClassInfo classInfo = getClassInfo();
      if (classResult == 1) {
        print("class start:${classInfo.name}");
      } else if (classResult == 0 && classInfo.type != -1) {
        //check property or method
        _formatLine(str, genClassBean);
      } else if (classResult == 2) {
        print("class end:${classInfo.name}");
        genClassBean.classInfo = classInfo;
        genClassBeans.add(genClassBean);

        //clear tmp class info
        genClassBean = GenClassBean();
        genClassBean.path = file.path;
        clearClassInfo();
      }
    }
  });
  // print(classMap);
  return genClassBeans;
}

String _checkLineStr(String str) {
  str = str.replaceAll("\t", "").replaceAll("\n", "").trim();
  if (str.startsWith("//") || str.isEmpty) {
    return "";
  }
  return str;
}

bool _foundImport(String str, List<String> importList) {
  if (str.startsWith("import")) {
    importList.add(str);
    return true;
  }
  return false;
}

String tmpLineStr = "";

void _formatLine(String str, GenClassBean genClassBean) {
  MethodInfo methodInfo = parseMethod(str);
  if (methodInfo != null) {
    genClassBean.methods.add(methodInfo);
    return;
  }
  //pattern line end
  RegExp exp = new RegExp(r";[ ]*//|;");
  if (!exp.hasMatch(str)) {
    //the line is't end, so continue...

    tmpLineStr += str;
  } else {
    // print("property str: " + tmpLineStr + str);
    int endIndex = str.lastIndexOf(";");
    str = str.substring(0, endIndex);
    str = tmpLineStr + str;
    str = str.replaceAll("new", "");
    str = str.trimLeft().trimRight().trim();
    genClassBean.properties.add(parseProperty(str));
    tmpLineStr = ""; //clear tmp str
  }
}
