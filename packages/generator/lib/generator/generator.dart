import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:automapper/automapper.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:source_gen/source_gen.dart';

// may be helpful to check which elements have a given annotation.
abstract class GeneratorForAnnotation2<T> extends GeneratorForAnnotation<T> {
  GeneratorForAnnotation2();

  late LibraryReader library;

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    this.library = library;

    return super.generate(library, buildStep);
  }
}

/// Codegenerator to generate implemented mapping classes
class MapperGenerator extends GeneratorForAnnotation2<AutoMapper> {
  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
          '${element.displayName} is not a class and cannot be annotated with @Mapper',
          element: element,
          todo: 'Add Mapper annotation to a class');
    }

    final autoMapperClass = element;
    final annotation = autoMapperClass.metadata.single;
    final constant = annotation.computeConstantValue()!;
    final field = constant.getField('mappers')!;
    final list = field.toListValue()!;
    final firstElement = list.first;
    final autoMapType = firstElement.type as ParameterizedType;
    final userType = autoMapType.typeArguments[0];
    final userDtoType = autoMapType.typeArguments[1];

    final mappings = list.map((x) {
      final mapType = x.type as ParameterizedType;

      final from = mapType.typeArguments[0];
      final to = mapType.typeArguments[1];

      return AutoMapConfig(from: from, to: to);
    }).toList();

    print('...');

    print(mappings.join('\n'));

    print(userType);
    print(userDtoType);

    print(userType);

    final u = userType.element as ClassElement;

    final parts = mappings
        .map((e) => AutoMapPart(
            from: TypeInfo.fromDartType(e.from),
            to: TypeInfo.fromDartType(e.to)))
        .toList();

    /**
     *  1. Gather all AutoMap 
     *  2. For each AutoMap 
     *    -  a] Get  All fields of From
     *    -  b] Get all constructor of From
     *    -  a] Get all fields of To
     *    - b] Get all constructors of To
     *  3. CHECK if
     *    a] From can be automatically mapped to To
     *       - All fields are same
     *       - There is 1:1 usable constructor
     */

    final mapping = buildMapping(element, mappings);
    final emitter =
        DartEmitter(orderDirectives: true, useNullSafetySyntax: true);

    return '${mapping.accept(emitter)}';
  }
}

class AutoMapPart {
  final TypeInfo from;
  final TypeInfo to;

  AutoMapPart({
    required this.from,
    required this.to,
  });
}

class AutoMapConfig {
  final DartType from;
  final DartType to;
  //todo use this
  Reference get fromExpr => refer(from.toString());
  Reference get toExpr => refer(to.toString());

  String get mappingMapMethodName =>
      'map${from.getDisplayString(withNullability: false)}To${to.getDisplayString(withNullability: false)}';

  AutoMapConfig({
    required this.from,
    required this.to,
  });

  @override
  String toString() {
    return 'AutoMap - $from -> $to';
  }
}

class TypeInfo {
  final DartType type;
  final List<dynamic> fields;
  final List<ConstructorElement> constructors;

  TypeInfo({
    required this.type,
    required this.fields,
    required this.constructors,
  });

  factory TypeInfo.fromDartType(DartType type) {
    // todo what if not ClassElement (i.e user is mapping DTO to string, etc...)
    final clazz = type.element as ClassElement;

    // get all fields except from static and synthetic (getter, setter)
    // todo do we want abstract ones?
    final fields = clazz.fields
        .where((element) =>
            !element.isAbstract || !element.isSynthetic || !element.isStatic)
        .toList();

    final constructors = clazz.constructors;

    return TypeInfo(type: type, fields: fields, constructors: constructors);
  }
}

Library buildMapping(ClassElement abstractClass, List<AutoMapConfig> mappings) {
  return Library((b) => b.body.addAll(
        [
          Class(
            (b) => b
              ..name = '\$${abstractClass.displayName}'
              // ..fields.addAll([
              //   Field((f) => f
              //     ..name = '_mapping'
              //     ..late = true
              //     ..modifier = FieldModifier.final$
              //     ..type = refer('Map<Type, dynamic Function(dynamic)>')
              //     ..assignment = buildMapperConfig(abstractClass, mappings))
              // ])
              ..methods.addAll(buildMethods(abstractClass, mappings)),
          ),
        ],
      ));
}

// Code? buildMapperConfig(
//     ClassElement abstractClass, List<AutoMapConfig> mappings) {
//   final code = BlockBuilder();

//   if (mappings.isEmpty) return Code('{}');

//   code.statements.add(Code('{'));
//   for (var mapping in mappings) {
//     final lambda = '(x) => ${mapping.mappingMapMethodName}(x),';
// //    final key = mapping.from.getDisplayString(withNullability: false);
//     final key = mapping.from;

//     code.statements.add(Code('$key: $lambda'));
//   }

//   code.statements.add(Code('}'));

//   return code.build();
// }

List<Method> buildMethods(
    ClassElement mapperClass, List<AutoMapConfig> mappings) {
  final methods = <Method>[];

  methods.add(buildConvertMethod(mapperClass, mappings));

  for (var mapping in mappings) {
    methods.add(Method(
      (b) => b
        ..name = mapping.mappingMapMethodName
        ..requiredParameters.addAll([
          Parameter((p) => p
            ..name = 'fromModel'
            ..type =
                refer(mapping.from.getDisplayString(withNullability: true)))
        ])
        ..returns = refer(mapping.to.getDisplayString(withNullability: true))
        ..body = buildMethodMappingBody(mapperClass, mapping),
    ));
  }

  return methods;
}

Method buildConvertMethod(
    ClassElement mapperClass, List<AutoMapConfig> mappings) {
  return Method((b) => b
    ..name = 'convert'
    ..types.addAll([refer('I'), refer('R')])
    ..requiredParameters.add(Parameter((p) => p
      ..name = 'model'
      ..type = refer('I')))
    ..returns = refer('R')
    ..body = buildConvertMethodBody(mapperClass, mappings));
}

Code? buildConvertMethodBody(
    ClassElement mapperClass, List<AutoMapConfig> mappings) {
  final block = BlockBuilder();

  // final mapperAccessExpr = refer('_mapping')
  //     .index(refer('I').property('runtimeType'))
  //     .nullChecked
  //     .call([refer('model')]).returned;

  // block.addExpression(mapperAccessExpr);

  final dartEmitter = DartEmitter();

  for (var mapping in mappings) {
    final outputExpr = refer('R')
        .property('runtimeType')
        .equalTo(refer(mapping.to.toString()));
    final ifCondition = refer('model')
        .property('runtimeType')
        .equalTo(refer('${mapping.from}'))
        .and(outputExpr)
        .code
        .accept(dartEmitter);

    final callMappingMethodExpr = refer(mapping.mappingMapMethodName)
        .call([refer('model').asA(refer(mapping.from.toString()))])
        .asA(refer('R'))
        .returned
        .statement
        .accept(dartEmitter);

    final ifStatemnet = Code('''if( $ifCondition ) {$callMappingMethodExpr}''');

    block.statements.add(ifStatemnet);
  }

  block.addExpression(refer('Exception').newInstance(
      [refer('\'No mapper found for \${model.runtimeType}\'')]).thrown);

  return block.build();
}

Code? buildMethodMappingBody(ClassElement mapperClass, AutoMapConfig mapping) {
  final block = BlockBuilder();

  block.addExpression(refer('Exception').newInstance(
      [refer('\'Converting ${mapping.from} to ${mapping.to}\'')]).thrown);

  return block.build();
}
