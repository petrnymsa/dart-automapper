import 'package:analyzer/dart/element/element.dart';
import 'package:automapper_generator/builder/convert_method_builder.dart';
import 'package:automapper_generator/models/auto_mapper_config.dart';
import 'package:code_builder/code_builder.dart';

import '../models/auto_map_part.dart';

class AutoMapperBuilder {
  //todo should be used later
  // static final String _mappingTypeInput = 'I';
  // static final String _mappingTypeOutput = 'R';
  // static final String _modelInputName = 'model';

  final AutoMapperConfig config;
  final ClassElement mapperClassElement;

  AutoMapperBuilder({
    required this.config,
    required this.mapperClassElement,
  });

  Library build() {
    return Library((b) => b.body.addAll(
          [
            Class(
              (b) => b
                ..name = '\$${mapperClassElement.displayName}'
                ..methods.addAll(_buildMethods()),
            ),
          ],
        ));
  }

  /// Generates all methods within mapper
  List<Method> _buildMethods() {
    final methods = <Method>[];

    // add helper method for type checks
    methods.add(_buildTypeOfHelperMethod());

    // Public convert method
    methods.add(ConvertMethodBuilder.build(mapperClassElement, config.parts));

    // Individual mapper methods of each mappings
    for (var mapping in config.parts) {
      methods.add(Method(
        (b) => b
          ..name = mapping.mappingMapMethodName
          ..requiredParameters.addAll([
            Parameter((p) => p
              ..name = 'model'
              ..type =
                  refer(mapping.source.getDisplayString(withNullability: true)))
          ])
          ..returns =
              refer(mapping.target.getDisplayString(withNullability: true))
          ..body = buildMethodMappingBody(mapping),
      ));
    }

    return methods;
  }

  Method _buildTypeOfHelperMethod() {
    return Method(
      (b) => b
        ..name = '_typeOf'
        ..types.add(refer('X'))
        ..returns = refer('Type')
        ..lambda = true
        ..body = Code('X'),
    );
  }

  Code? buildMethodMappingBody(AutoMapPart mapping) {
    final block = BlockBuilder();

    final targetClass = mapping.target.element as ClassElement;

    final targetConstructor = _findBestConstructor(targetClass);

    block.statements.add(Code('// $targetConstructor'));

    block.addExpression(refer('Exception')
        .newInstance([refer('\'Converting $mapping\'')]).thrown);

    return block.build();
  }

  ConstructorElement _findBestConstructor(ClassElement element) {
    final constructors = element.constructors;

    constructors.sort(((a, b) => b.parameters.length - a.parameters.length));

    return constructors.first;
  }
}
