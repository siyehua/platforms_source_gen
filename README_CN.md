# platforms_source_gen

一个工具, 可以根据 dart 代码, 自动生成不同平台的代码, 例如 Android, iOS, Web....

# 前提
platforms_source_gen 会自动根据 dart 代码, 生成其他平台的代码, 以便能在混合开发的时候快速编程, 提高开发效率.

因为我们在混合开发的时候, 涉及到 Flutter 和 Native 之间的交互, 总是需要手动写两份, 甚至多份相同功能, 但是不同语言的代码.

## 举个例子: 路由路径

当我们在进行混合开发的时候, 经常需要从 Android 页面, 跳转到 Flutter 页面, 然后又从 Flutter 页面, 跳回 Android 页面,
这种反复混合跳转, 我们一般都会在两边写一个路由, 用来管理所有的跳转, 例如 [flutter_boost](https://github.com/alibaba/flutter_boost) ,
而路由管理就需要定义页面的路径:

### 在 Android 中, 我们可能这么写:<br/>

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


### 在 flutter 中:<br/>

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

同样的代码我们需要些两份, 如果支持 iOS 平台, 就需要再写一份 swift, 支持 Web, 就需要再写一份 js...
这个工具就是解放你的双手, 只需要写一分 dart 代码, 工具会根据 dart 代码, 自动生成其他平台的代码.

# 快速开始

## 第一步

把 `platforms_source_gen` 添加到 `pubspec.yaml` 文件中, 并在命令行运行命令 `dart pub get` 下载, 当前你也可以直接点 IDE 上面的 `puh get` 直接下载:

```
dev_dependencies:
  platforms_source_gen: 版本号
```

最新的版本号, 你可以点击 [这里](https://pub.dev/packages/platforms_source_gen/versions),
如果你还是个新手, 从来没下载安装过 package, 可以点击[这里](https://pub.dev/packages/platforms_source_gen/install),
这里有详细的说明文档.

## 第二步
编写你的 drat 代码, 放到这个目录下: `./lib/example` :

`这个路径你可以自定义, 工具会自动将这个路径下的所有 dart 文件都转换成`

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

//todo fix right link
更多例子你可以点击这里 [example class](https://pub.dev/packages/platforms_source_gen/versions).

## 第三步

写一个 **main** 函数在 `./test/any.dart` 路径下, 点击左边的按钮, 运行 run:


### 注意:  `any.dart` 被放在了 test 目录下, 名字可以是任意, 不能直接放在项目的 lib 下, 因为在 lib 上的 main 方法会当成是
flutter 的应用入口, 会直接运行起一个 app.

```dart
import 'package:platforms_source_gen/platforms_source_gen.dart';

void main(){
  platforms_source_gen_init("./lib/example",//你上面写的 dart 文件目录
    "com.siyehua.example",//Android 代码的 包名
    "./Android_gen" //自动是个代码的路径, 你可以直接改成你的 Android 项目路径
    );
}
```

运行结束后, 你就可以在你自定义的路径下找到自动生成的类了, 例子中的路径放在 `./Android_gen`

# 支持
类|支持|
----|----|
普通类 |✅|
接口|✅|
继承|❌|
实现|❌|
组合|✅|

## 注意: `接口` 不允许有任何已经实现的方法,属性不允许有任何默认值, 在 Java 中, 会被直接转成接口, 接口不允许有默认值或默认实现.

方法|支持|
----|----|
所有|✅|

支持`接口`中的抽象方法, 不支持已实现的方法, 不支持顶级方法

类型|支持|Android|iOS|
----|----|----|----|
bool|✅|Boolean||
int|✅|Long||
double|✅|Double||
String|✅|String||
Uint8List|✅|byte[]||
Int32List|✅|int[]||
Int64List|✅|long[]||
Float64List|✅|double[]||
List< T >|✅|ArrayList<>||
Map<T,U>|✅|HashMap<T,U>||
var|❌||
dynamic|❌||
Object|❌||

注意: 不支持 `List a= [];`, 因为语句等同于 `List<dynamic> a =[];`, 而 dynamic 类型是不支持的, Map 同样如此


# 问题 & BUG
1. 支持 iOS 平台吗??<br> 支持的, 但是目前还没有实现, 下一步就是实现 iOS 或其他平台的语言, 也欢迎大家提交 commit.
2. 为什么依赖要加在 `dev_dependencies` 中? <br> 因为这是一个开发工具,这个工具的代码无需打包进源码中, 故只需要加在 dev_dependencies 即可.
3. 这个工具和 [source_gen](https://pub.dev/packages/source_gen) 有什么不同, 为什么不直接使用它?<br>`source_gen` 主要是依赖 run build 来生成自己想要的 dart 代码, 而这个工具是根据 dart 代码生成其他平台代码, 方法和作用不相同.

更多问题和 Bug, 欢迎前往 [github](https://pub.dev/packages/platforms_source_gen/versions)

