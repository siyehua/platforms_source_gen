import 'dart:mirrors';

import 'package:platforms_source_gen/class_parse.dart';
import 'package:platforms_source_gen/method_parse.dart';

import 'platforms_source_gen.dart';
import 'property_parse.dart';

List<GenClassBean> reflectStart(List<Type> types) {
  // print('reflectStart! $types');
  var genClassList = <GenClassBean>[];
  types.forEach((element) {
    var genClass = GenClassBean();
    genClassList.add(genClass);

    /// ready
    var classMirror = reflectClass(element);
    MethodMirror constructorMethodMirror = classMirror.declarations.values
        .firstWhere(
            (element) => element is MethodMirror && element.isConstructor,
            orElse: () => null);
    InstanceMirror instanceMirror;
    if (!classMirror.isAbstract) {
      try {
        instanceMirror = classMirror
            .newInstance(constructorMethodMirror.constructorName, []);
      } catch (e) {
        print(e);
        throw "can't found default constructor method, please remove other constructor method!";
      }
    }
    var declarations = classMirror.declarations;

    ///set path
    genClass.path = classMirror.location.toString();

    ///set class info
    var classInfo = ClassInfo();
    classInfo.type = classMirror.isAbstract ? 1 : 0;
    classInfo.name = element.toString();
    genClass.classInfo = classInfo;

    ///set property
    var allProperty = <Property>[];
    var propertyList = declarations.values
        .where((element) => element is VariableMirror)
        .map((e) => e as VariableMirror)
        .toList();
    allProperty
        .addAll(findParameters(classMirror, instanceMirror, propertyList));
    genClass.properties = allProperty;

    ///set method
    var allMethod = <MethodInfo>[];
    declarations.values
        .where((element) => element is MethodMirror && !element.isConstructor)
        .map((e) => e as MethodMirror)
        .forEach((element) {
      var method = MethodInfo();
      allMethod.add(method);

      method.name = MirrorSystem.getName(element.simpleName);
      method.isAbstract = element.isAbstract;
      method.args = findParameters(classMirror, null, element.parameters);
      var returnProperty = Property();
      findTypeArguments(returnProperty, [element.returnType]);
      method.returnType = returnProperty.firstType;
    });
    genClass.methods = allMethod;
  });

  // print(genClassList);
  // print('reflectEnd! $types');
  return genClassList;
}

List<Property> findParameters(ClassMirror classMirror,
    InstanceMirror instanceMirror, List<VariableMirror> params) {
  var parameters = <Property>[];
  params.forEach((value) {
    var property = Property();
    parameters.add(property);
    var type = value.type;
    property.type = MirrorSystem.getName(type.qualifiedName);
    property.name = MirrorSystem.getName(value.simpleName);
    if (property.type == "dart.core.List") {
      property.typeInt = 1;
    } else if (property.type == "dart.core.Map") {
      property.typeInt = 2;
    } else {
      property.typeInt = 0;
    }
    if (value.isStatic) {
      InstanceMirror instanceMirror = classMirror.getField(value.simpleName);
      property.defaultValue1 = "${instanceMirror.reflectee}";
    } else if (instanceMirror != null) {
      property.defaultValue1 =
          "${instanceMirror.getField(value.simpleName).reflectee}";
    }
    property.isStatic = value.isStatic;
    property.isConst = value.isConst;
    property.isPrivate = value.isPrivate;
    findTypeArguments(property, value.type.typeArguments);
  });
  return parameters;
}

void findTypeArguments(Property target, List<TypeMirror> typeArguments) {
  typeArguments.take(2).toList().asMap().forEach((key, value) {
    var property = Property();
    var typeArguments = MirrorSystem.getName(value.qualifiedName);
    property.type = typeArguments;
    if (property.type == "dart.core.List") {
      property.typeInt = 1;
    } else if (property.type == "dart.core.Map") {
      property.typeInt = 2;
    } else {
      property.typeInt = 0;
    }
    if (key == 0) {
      target.firstType = property;
    } else {
      target.secondType = property;
    }
    findTypeArguments(property, value.typeArguments);
  });
}
