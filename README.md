# platforms_source_gen

A Flutter package gen platform's source code, include Android or iOS, Web ....

# [中文文档](./README_CN.md)

# Overview
platforms_source_gen providers utilities from automated source code generation from Dart file.

When you build flutter as a Module in Android, iOS or other platform, you have to write some same function
code.

## eg: Route Path

When you dump to a android page, and then you dump to flutter page, and dump to android page...
<br>you can use some package, like [flutter_boost](https://github.com/alibaba/flutter_boost) dump:

### in android:<br>

```java
public class Route {
    public static final String android_page1 = "/android/page1";
    public static final String android_page2 = "/android/page2";
    //.......
    public static final String flutter_page1 = "/flutter/page1";
    public static final String flutter_page2 = "/flutter/page2";
    //.......
}

```

### in flutter:<br>

```dart
class Route {
  static const String android_page1 = "/android/page1";
  static const String android_page2 = "/android/page2";
  //.......
  static const String flutter_page1 = "/flutter/page1";
  static const String flutter_page2 = "/flutter/page2";
  //.......
}
```

### in iOS:

```objc
@interface MQQFlutterGen_Route : NSObject

@property (nonatomic, strong) String *main_page;
@property (nonatomic, strong) String *mine_main;
@property (nonatomic, assign) int int_value;

@end
```

and Swift code or js code ...
this tools can let you only write dart code, and auto generates other platform's code.

# Quick Start

## 01 Step

Add a dependency on `platforms_source_gen` in your pubspec.yaml file and use `dart pub get` down this package:


```
dev_dependencies:
  platforms_source_gen: version
```

the versions click [this](https://pub.dev/packages/platforms_source_gen/versions),
more installing info, you can see [this](https://pub.dev/packages/platforms_source_gen/install)

## 02 Step
write your dart class file in flutter project path and format it, for example: `./lib/example` :

### Note: Format is very import, it will fail if dart file have no format.

```dart
class InnerClass {
  String a;
  int b;
}

class Route {
  static const String main_page = "/main/page"; //main page
  static const String mine_main = "/mine/main"; //
  static const int int_value = 123;
}

```

more [example class](https://github.com/siyehua/platforms_source_gen/tree/master/lib/example), your can get it from github.

## 03 Step

write a **main fun**  in `./test/any.dart` and run:

### Note: the `any.dart` is in test dir
```dart
import 'package:platforms_source_gen/platforms_source_gen.dart';

void main() async {
  List<GenClassBean> genClassBeans = await platforms_source_gen_init(
      "./lib/example", //you dart file path
      "com.siyehua.example", //your android's  java class package name
      "./Android_gen" //your android file save path
      );
  platforms_source_gent_start(
      "com.siyehua.example", "./Android_gen", genClassBeans,
      nullSafe: true);
  platforms_source_start_gen_objc("MQQFlutterGen_", "./iOS_gen", genClassBeans,
      nullSafe: true);
}
```
now, you can find the android file in your custom path `./Android_gen`, or Objective-C file in `./iOS_gen`.



# Support
class|support|
----|----|
class|✅|
abstract class(interface) |✅|
extends|❌|
implements |❌|
compose|✅|

#### Note: `abstract class` must not have any implemented methods, property must not have any default value.<br><br><br>


method|support|
----|----|
all|✅|

#### Note: Support abstract method in `abstract class`, but don't support method not in class.<br><br><br>

Type|support|Android|iOS|
----|----|----|----|
bool|✅|Boolean|BOOL|
int|✅|Long|int|
double|✅|Double|double|
String|✅|String|NSString|
Uint8List|✅|byte[]|NSData|
Int32List|✅|int[]|NSData|
Int64List|✅|long[]|NSData|
Float64List|✅|double[]|NSData|
List< T > |✅|ArrayList<>|NSArray|
Map<T, U>|✅|HashMap<T, U>|NSDictionary|
var|❌||
dynamic|❌||
Object|✅|❌|id|
Custom Class|✅||

#### Note: Currently don't support `List a= [];`, because it's the same as `List<dynamic> a =[];`, , and `dynamic` feature doesn't support, `Map` is same.

# FQA & BUG
1. Why add package in dev_dependencies? <br> because this tool only use to create other platform language, so we don't need to add it in dependencies.
2. It's the same with [source_gen](https://pub.dev/packages/source_gen) or builder?<br> the `source_gen` will create dart code, but this tool create other platform codes.

For more questions, you can go to [issues](https://github.com/siyehua/platforms_source_gen/issues)

