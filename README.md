# platforms_source_gen

A Flutter package gen platform's source code, include Android or iOS, Web ....

# [中文文档](./README_CN.md)

# Overview
platforms_source_gen providers utilities from automated source code generation from Dart file.

when you build flutter as a Module in Android, iOS or other platform, you have to write some same function
code.

## eg: Route Path

when you dump to a android page, and then you dump to flutter page, and dump to android page...
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

and swift code or js file.....

this tools can help you only write dart code, platform's code will auto generation.

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

### Note: format is very import, it will fail if dart file no format.

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

//todo
more [example class](https://pub.dev/packages/platforms_source_gen/versions), your can get it from github.

## 03 Step

write a **main fun**  in `./test/any.dart` and run:


### Note: the `any.dart` is in test dir
```dart
import 'package:platforms_source_gen/platforms_source_gen.dart';

void main(){
  platforms_source_gen_init("./lib/example/",//you dart file dir
    "com.siyehua.example",//your android's  java class package name
    "./Android_gen" //your android file save path
    );
}
```

now, you can find the android file in your custom path `./Android_gen`

# Support
class|support|
----|----|
class|✅|
abstract class(interface) |✅|
extends|❌|
implements |❌|
compose|✅|

## Note: `abstract class` must not have any methods that have been implemented, property must not have any default value.


method|support|
----|----|
all|✅|

## Note: support abstract method in `abstract class`, don't support method no in class.

Type|support|Android|iOS|
----|----|----|----|
bool|✅|Boolean||
int|✅|Long||
double|✅|Double||
String|✅|String||
Uint8List|✅|byte[]||
Int32List|✅|int[]||
Int64List|✅|long[]||
Float64List|✅|double[]||
List< T > |✅|ArrayList<>||
Map<T, U>|✅|HashMap<T, U>||
var|❌||
dynamic|❌||
Object|❌||

Note: don't support `List a= [];`, because  it's the same as `List<dynamic> a =[];`, , and  `dynamic` is't support, `Map` is also like this.

# FQA & BUG
1. iOS is support?<br> Yes, but this version only support Android, Welcome anybody push iOS support. Web or Desktop, and any other platform language.
2. Why add  package in dev_dependencies? <br> because this tools only create platform language but not dart, so we don't need add it in dependencies.
3. it's the same with [source_gen](https://pub.dev/packages/source_gen) or builder?<br> the `source_gen` will create dart code, but this tools only create platform languages.

more questions or but, you can go to [github](https://pub.dev/packages/platforms_source_gen/versions)

