
import 'package:platforms_source_gen/example/example.dart';

abstract class Fps {
  Future<String> getPageName(int a);

  Future<double> getFps();

  void add11(int b, MyClass cls);

}

abstract class Fps2 {
  Future<String> getPageName(Map<String,int> t);

  Future<double> getFps(String t);

  void add23();

}
