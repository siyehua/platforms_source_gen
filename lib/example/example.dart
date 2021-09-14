enum MyEnum {
  first,
  second,
}

abstract class IAccount {
  // This is a comment for login method
  // different kinds of comment
  /*
    a kind of comment
    test
    test
  */
  /* another comment  */
  Future<String?> login(String? name, Object password);

  ///////// comment for getToken
  Future<String?> getToken();

  /// isolate comment

  // logout comment
  // and seconed line for logout comment
  void logout();

  /*
    complicated comment for get list
    with multiple lines
    and many things  
   */
  Future<List<String>?> getList(String? name, String password, String? name2, String password3, String? namefe, String passwordeff);

  /* another comment for get map */
  Future<Map<String?, int>> getMap();

  void setMap(Map<int, bool>? a);

  Future<Map<int, bool>> all(List<int>? a, Map<String?, int> b, int? c);

  void testEnum(MyEnum a);
}

class MyClass {
  // comment for propertiy abc
  InnerClass? abc;
  int? a;
  int b = 0;
  double? c;
  String? d = "default";
  MyEnum e = MyEnum.first;

  // Object h; //it's not support.
  List<int>? g;
  List<int> g1 = [];
  List<int> g2 = [1, 2, 3, 4];
  List<InnerClass>? j;
  List<InnerClass> j1 = [];
  List<InnerClass>? j2 = [InnerClass(), InnerClass()];

  // List e = []; //don't do it, is the same List<dynamic>, it's not support
  // List<dynamic> f = []; ////don't do it, dynamic is not support

  Map<String, int>? i;
  Map<String, int> i1 = {};
  Map<String?, int> i2 = {"key": 1, "key2": 2};
  Map<InnerClass, int>? i3;
  Map<InnerClass, InnerClass?>? i4;
  Map<InnerClass?, InnerClass>? i5 = {InnerClass(): InnerClass()};
}

class InnerClass {
  String? a;
  int? b;
}

class Route {
  static const String main_page = "/main/page";
  static const String mine_main = "/mine/main";
  static const int int_value = 123;
}
