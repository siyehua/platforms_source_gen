library platforms_source_gen;

import 'dart:convert';
import 'dart:io';

import 'android_gen.dart';
import 'bean/class_parse.dart';
import 'bean/method_parse.dart';
import 'bean/property_parse.dart';

void main() async {
  List<GenClassBean> genClassBeans = await platforms_source_gen_init(
      "./lib/example", //you dart file path
      "com.siyehua.example", //your android's  java class package name
      "./Android_gen" //your android file save path
      );
  platforms_source_gent_start(
      "com.siyehua.example", "./Android_gen", genClassBeans,
      nullSafe: true);
}

class GenClassBean {
  String path = "";
  ClassInfo classInfo = ClassInfo();
  List<String> imports = [];
  List<MethodInfo> methods = [];
  List<Property> properties = [];

  GenClassBean.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    classInfo = ClassInfo.fromJson(json['classInfo']);
    if (json['imports'] != null) {
      imports = [];
      json['imports'].forEach((v) {
        imports.add(v);
      });
    }
    if (json['methods'] != null) {
      methods = [];
      json['methods'].forEach((v) {
        methods.add(new MethodInfo.fromJson(v));
      });
    }
    if (json['properties'] != null) {
      properties = [];
      json['properties'].forEach((v) {
        properties.add(new Property.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    data['classInfo'] = this.classInfo.toJson();
    data['imports'] = this.imports.toList();
    data['methods'] = this.methods.map((v) => v.toJson()).toList();
    data['properties'] = this.properties.map((v) => v.toJson()).toList();
    return data;
  }

  @override
  String toString() {
    return '\nGenClassBean{path: $path, classInfo: $classInfo, imports: $imports, methods: $methods, properties: $properties}\n';
  }

  GenClassBean();
}

Future<List<GenClassBean>> platforms_source_gen_init(
    String dir, String javaPackage, String androidSavePath) async {
  // String path = "./lib/example";
  // String javaPackage = "com.siyehua.example";
  // String androidSavePath = "./Android_gen";
  List<GenClassBean> list = [];
  Directory directory = Directory(dir);
  var listFile = directory
      .listSync()
      .takeWhile((value) => value is File)
      .map((e) => e as File)
      .toList();

  for (int i = 0; i < listFile.length; i++) {
    if (listFile[i] is File) {
      List<GenClassBean> aaa =
          await _parseFile(listFile[i], javaPackage, androidSavePath);
      list.addAll(aaa);
    }
  }
  return list;
}

platforms_source_gent_start(String javaPackage, String androidSavePath,
    List<GenClassBean> genClassBeans,
    {bool nullSafe = true}) {
  //android create
  JavaCreate.create(javaPackage, androidSavePath, genClassBeans,
      nullSafe: nullSafe);
  //ios create
  //todo
}

Future<List<GenClassBean>> _parseFile(
    File file, String javaPackage, String androidSavePath) async {
  List<String> importList = [];
  List<GenClassBean> genClassBeans = [];
  GenClassBean genClassBean = GenClassBean();
  genClassBean.path = file.path;
  file.readAsLinesSync().forEach((str) {
    str = _checkLineStr(str);
    if (str.isEmpty) {
    } else if (_foundImport(str, importList)) {
    } else {
      int classResult = parseClass(str);
      ClassInfo classInfo = getClassInfo();
      if (classResult == 1) {
        print("class start:${classInfo.name}");
      } else if (classResult == 2) {
        print("class end:${classInfo.name}");
        if (classInfo.name.isEmpty || classInfo.type == -1) {
          //skip
          return;
        }
        genClassBean.classInfo = classInfo;
        genClassBean.imports = importList;
        genClassBeans.add(genClassBean);

        //clear tmp class info
        genClassBean = GenClassBean();
        genClassBean.path = file.path;
        clearClassInfo();
      }
    }
  });
  List b = await _scan_dart_file_use_shell(file, genClassBeans);
  List<GenClassBean> newList =
      List.from(b).map((e) => GenClassBean.fromJson(e)).toList();
  genClassBeans.asMap().forEach((key, value) {
    newList[key].imports = value.imports;
  });
  return newList;
}

/// scan dart file use shell
/// todo support windows cmd
Future<List> _scan_dart_file_use_shell(
    File file, List<GenClassBean> genClassBeans) async {
  File scanFile = File(file.parent.path + "/tmp.dart");
  String allContent = """
  import 'dart:convert';
  import 'package:platforms_source_gen/platforms_source_gen.dart';
  import 'package:platforms_source_gen/scan_dart_file.dart';
  import '${file.path.split('/').last}';
  
  void main() { var typeList =<Type>[];\n""";
  genClassBeans.forEach((element) {
    allContent += """\n
    Type type${element.classInfo.name} = ${element.classInfo.name};
    typeList.add(type${element.classInfo.name});""";
  });
  allContent += """\n  
  List<GenClassBean> genClassBeans = reflectStart(typeList, '${file.absolute.path}');
  String a = jsonEncode(genClassBeans);
  print(a);
  }""";
  scanFile.writeAsStringSync(allContent);
  await Process.run('dart', ['format', '-l', '80000', file.path],
      runInShell: true);
  ProcessResult result =
      await Process.run('dart', ['run', scanFile.path], runInShell: true);
  print(file.absolute.path);
  scanFile.deleteSync();
  // reflectStart(types)
  print(result.exitCode);
  print(result.stderr);
  List<dynamic> b = jsonDecode(result.stdout);
  return b;
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
