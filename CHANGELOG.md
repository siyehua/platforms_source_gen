## 0.0.1

* a tools can auto gen platforms source code

## 0.0.6

* remove flutter sdk

## 0.1.0

* support include dir

## 0.2.0

* support gen interface class

## 0.2.2

* read file sync

## 0.2.3

* fix map type bug

## 0.2.4

* add import info

## 0.2.7

* fix: can't create file use dart io

## 0.3.0

* feat: use reflect parse file and class

## 0.3.1

* fix: static property parse error

## 0.3.2

* feat: add subType in property

## 0.3.3

* feat:  support custom class

## 0.4.0

* feat:  support null safe

## 0.4.1

* fix: some type parse error

## 0.4.2

* fix: parse file is hard code

## 0.4.3

* fix: class no import info

## 0.5.0

* feat: null safe option

## 0.5.1

* feat: format source code

## 0.5.2

* fix: windows create tmp dart file path error

## 0.6.0

* feat: support ios ,to object-c

## 0.6.1

* feat: support dart to Objective-C code
* feat: support setting NSArray and NSDicionay's default value
* feat: support convert dart's abstract method
* fix: Objective-C base type convert problem

## 0.6.2

* fix: Objective-C custom class properties convert problem

## 0.6.3

* fix: Objective-C method convert problem

## 0.6.4

* fix: dart null safe bug

## 0.6.5

* Feat: Objective-C support convert 'Object' type to 'id'

## 0.6.6

* Fix: 'void' type convert to 'void *' in objc instead of 'void' problem

## 0.6.7

* Fix: missing custom class import bug

## 0.6.8

* Feat: Objective-C generated class support 'NSCopying' protocol

## 0.6.9

* Update: Objective-C now will convert Uint8List, Int32List, Int64List, Float64List into NSData
* However, the oc implementation of these data type is not finished yet.

## 0.7.0

* feat: remove no use code

## 0.7.1

* Update: Objective-C now will convert static properties into marco instead of properties

## 0.7.2

* Feat: add custom save path

## 0.7.3

* Fix: write file error when dir is not exits

## 0.7.4

* Fix: add custom channel name

## 0.7.5

* Feat: Support reading dart methods and properties' origin declaraction, now iOS generated code can add them as a comment.
* Update: Now iOS generated code will add class name prefix to static properties.

## 0.7.6

* Fix: iOS will parse "_Nullable" as import problem

## 0.7.7

* Fix: android create abstract class error

## 0.7.7

* Feat: java support enum type

## 0.7.8

* Feat: Support comment 

## 0.7.9

* Fix: dart's int now will convert into OC's longlong