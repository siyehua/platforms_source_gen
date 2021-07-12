import 'dart:typed_data';

abstract class AbsClass {
  void aaa();

  String a11();

  List<String>? a5(String? a, int b);

  List<String> a6(String a, int? b, List<int?>? c);

  List<String> a7(String a, int? b, List<int> c, Map<String?, int>? d, Map<String?, int> d2);

  Map<String, int> a8(String a, int b, List<int>? c);

  Map<String, int> a9(String a, int b, List<int?> c, Map<String, int> e);

  void a2(String a);

  void a3(String a, int? b);

  String a4(String a, int b);

  void methoid1() {}

  Map<int, String> methoid2() {
    return {};
  }

  Map<int, String>? methoid3(int a) {
    return null;
  }

  Map<int, String> methoid4(int a, String b) {
    return {};
  }

  Map<int, String>? methoid5(int a, List<String> b) {}
}

class MyClass {
  // var a = ""; it's not support start with var
  //dynamic a = ""; it's not support start with dynamic

  bool? boo;
  bool boo1 = true;

  int? a;
  int a1 = 0;

  double? c;
  double? c1 = 0.1;

  String? d;
  String d1 = "default";

  Uint8List? e;
  Uint8List e1 = Uint8List(10);
  Uint8List? e2 = new Uint8List(100);

  Int32List? f;
  Int32List f1 = Int32List(5);
  Int32List f2 = new Int32List(75);

  Int64List? g;
  Int64List g1 = Int64List(8);
  Int64List g2 = new Int64List(9);

  Float64List? h;
  Float64List h1 = Float64List(45);
  Float64List h2 = new Float64List(13);

  // Object h; //it's not support.
  List<int>? i;
  List<int> i1 = [];
  List<int?> i2 = [1, 2, 3, 4];
  List<InnerClass?>? j;
  List<InnerClass> j1 = [];

  // List e = []; //don't do it, is the same List<dynamic>, it's not support
  // List<dynamic> f = []; ////don't do it, dynamic is not support

  Map<String, int?>? k;
  Map<String, int> k1 = {};
  Map<String, int> k2 = {"key": 1, "key2": 2};
  Map<InnerClass?, InnerClass>? l;
  Map<InnerClass, InnerClass>? l1;

  List<List<int>?>? i3 = [];
  List<List<List<List<List<int?>>>>> i4 = [];
  Map<String, String?> a456 = {};
  Map<List<String>, String> a2 = {};
  Map<List<String?>, Map<String, int>> a3 = {};
  Map<List<String>?, Map<String, List<int>>> a4 = {};
  Map<List<String>, Map<String?, Map<int?, List<Map<String, int>>>?>> a5 = {};
}

class InnerClass {
  String? a;
  int? b;
}

class Route {
  static const String main_page = "/main/page"; //main page
  static const String mine_main = "/mine/main"; //
  static const int int_value = 123;
}
