import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:code_builder/code_builder.dart';

import '../models/auto_map_part.dart';
import 'model/source_assignment.dart';

/*
* Map positional fields
* Map named fields
* Map setters
* Support mapping List
* Support mapping Map(?)
* Null safety

* Nested mappping (recursive convert<I,R> call)
  */
class MapModelBodyMethodBuilder {
  Code build(AutoMapPart mapping) {
    final block = BlockBuilder();

    final targetClass = mapping.target.element as ClassElement;
    final sourceClass = mapping.source.element as ClassElement;

    final targetConstructor = _findBestConstructor(targetClass);

    block.statements.add(Code('// $targetConstructor'));

    final sourceFields = {
      for (final field in sourceClass.fields.where((element) => !element.isSynthetic)) field.name: field
    };

    final mappedParameters = <SourceAssignment>[];
    final notMapped = [];

    final mappedFieldNames = [];

    for (var i = 0; i < targetConstructor.parameters.length; i++) {
      final param = targetConstructor.parameters[i];

      if (sourceFields.containsKey(param.name)) {
        final mappingField = SourceAssignment(
          sourceField: sourceFields[param.name]!,
          target: targetClass.fields.firstWhere((element) => element.name == sourceFields[param.name]!.name),
          targetConstructorParam: ConstructorAssignment(
            param: param, position: param.isPositional ? i : null, //todo is it working?
          ),
        );

        mappedParameters.add(mappingField);
        mappedFieldNames.add(param.name);
      } else {
        notMapped.add(param);
      }
    }

    // Mapped fields into constructor - positional and named
    final resultExpr = declareFinal('result')
        .assign(refer(targetConstructor.displayName).newInstance(
          mappedParameters
              .where((element) => element.targetConstructorParam!.position != null)
              .map((assignment) => _assignValue(assignment)),
          {
            for (final assignment in mappedParameters.where((element) => element.targetConstructorParam!.isNamed))
              assignment.targetConstructorParam!.param.name: _assignValue(assignment)
          },
        ))
        .statement;

    block.statements.add(resultExpr);

    // Not mapped directly in constructor
    final potentialSetterFields = sourceFields.keys.where((element) => !mappedFieldNames.contains(element)).toList();

    if (potentialSetterFields.isNotEmpty) {
      for (final x in potentialSetterFields) {
        final sourceField = sourceFields[x]!;
        final targetField = targetClass.fields.firstWhere((element) => element.name == sourceField.name);

        // assign result.X = model.X
        final expr = refer('result').property(x).assign(
              _assignValue(SourceAssignment(
                sourceField: sourceFields[x]!,
                target: targetField,
              )),
            );

        block.statements.add(expr.statement);
      }
    }

    block.statements.add(refer('result').returned.statement);
    return block.build();
  }

  /// Tries to find best constructor for mapping -> currently returns constructor with the most parameter count
  static ConstructorElement _findBestConstructor(ClassElement element) {
    final constructors = element.constructors;

    constructors.sort(((a, b) => b.parameters.length - a.parameters.length));

    return constructors.first;
  }

  static Expression _assignValue(SourceAssignment assignment) {
    if (assignment.shouldAssignList()) {
      final sourceNullable = assignment.sourceField.type.nullabilitySuffix == NullabilitySuffix.question;
      final targetNullable = assignment.target.type.nullabilitySuffix == NullabilitySuffix.question;

      print('S: $sourceNullable, T: $targetNullable');

      if (sourceNullable && targetNullable) {
        return refer('model').property(assignment.sourceField.name);
      }

      if (targetNullable && sourceNullable == false) {
        return refer('model').property(assignment.sourceField.name);
      }

      if (targetNullable == false && sourceNullable) {
        return refer('model').property(assignment.sourceField.name).ifNullThen(refer('[]'));
      }
    }

    return refer('model').property(assignment.sourceField.name);
  }
}
