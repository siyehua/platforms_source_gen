import 'package:platforms_source_gen/platforms_source_gen.dart';

void main() async {
  List<GenClassBean> genClassBeans = await platforms_source_gen_init(
    "./lib/example", //you dart file path
  );
  platforms_source_gent_start(
      "com.siyehua.example", //javaPackage
      "./Android_gen", // androidSavePath
      genClassBeans,
      nullSafe: true);
  platforms_source_start_gen_objc(
      "MQQFlutterGen_", // iOS Pre
      "./iOS_gen", //iOS save path
      genClassBeans,
      nullSafe: true);
}
