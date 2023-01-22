import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';

import '../models/auto_map_part.dart';

class ConvertMethodBuilder {
  static Method build(ClassElement mapperClass, List<AutoMapPart> mappings) {
    return Method((b) => b
      ..name = 'convert'
      ..types.addAll([refer('I'), refer('R')])
      ..requiredParameters.add(Parameter((p) => p
        ..name = 'model'
        ..type = refer('I')))
      ..returns = refer('R')
      ..body = _buildConvertMethodBody(mapperClass, mappings));
  }

  static Code? _buildConvertMethodBody(
      ClassElement mapperClass, List<AutoMapPart> mappings) {
    final block = BlockBuilder();

    final dartEmitter = DartEmitter();

    for (var mapping in mappings) {
      final outputExpr =
          refer('_typeOf<R>()').equalTo(refer(mapping.target.toString()));

      final ifCondition = refer('model')
          .isA(refer('${mapping.source}'))
          .and(outputExpr)
          .code
          .accept(dartEmitter);

      final callMappingMethodExpr = refer(mapping.mappingMapMethodName)
          .call([
            refer('model'),
          ])
          .asA(refer('R'))
          .returned
          .statement
          .accept(dartEmitter);

      final ifStatemnet =
          Code('''if( $ifCondition ) {$callMappingMethodExpr}''');

      block.statements.add(ifStatemnet);
    }

    block.addExpression(refer('Exception').newInstance(
        [refer('\'No mapper found for \${model.runtimeType}\'')]).thrown);

    return block.build();
  }
}
