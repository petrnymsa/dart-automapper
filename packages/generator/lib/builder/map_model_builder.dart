import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:automapper_generator/builder/model/extensions.dart';
import 'package:automapper_generator/models/auto_mapper_config.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

import '../models/auto_map_part.dart';
import 'model/source_assignment.dart';

/*
* Map positional fields
* Map named fields
* Map setters
* Support mapping List
*   - Support mapping Map(?)
* Null safety

* Nested mappping (recursive convert<I,R> call)

    - Implicit = even when not defined as top mapping it should try recursively map it ?
        - FOR NOW THIS WILL BE COMPLICATED
    
    - Explicit = use canConvert and convert<I,R> call
  */
class MapModelBodyMethodBuilder {
  final AutoMapperConfig mapperConfig;
  final AutoMapPart mapping;

  MapModelBodyMethodBuilder({
    required this.mapperConfig,
    required this.mapping,
  });

  Code build() {
    final block = BlockBuilder();

    final targetClass = mapping.target.element as ClassElement;
    final sourceClass = mapping.source.element as ClassElement;

    final targetConstructor = _findBestConstructor(targetClass);

//    block.statements.add(Code('// $targetConstructor'));

    final sourceFields = _getSourceFields(sourceClass);

    final mappedTargetConstructorParams = <SourceAssignment>[];
    final notMappedTargetParameters = <SourceAssignment>[];

    // Name of the source field names which can be mapped into constructor field
    final mappedSourceFieldNames = <String>[];

    // Map constructor parameters
    for (var i = 0; i < targetConstructor.parameters.length; i++) {
      final param = targetConstructor.parameters[i];
      final paramPosition = param.isPositional ? i : null;
      final constructorAssignment = ConstructorAssignment(param: param, position: paramPosition);

      if (sourceFields.containsKey(param.name)) {
        final sourceField = sourceFields[param.name]!;

        final targetField =
            targetClass.fields.firstWhere((targetField) => targetField.displayName == sourceField.displayName);

        if (mapping.memberShouldBeIgnored(targetField.displayName)) {
          if (param.isPositional && param.type.nullabilitySuffix != NullabilitySuffix.question) {
            throw InvalidGenerationSourceError(
                "Can't ignore member '${sourceField.displayName}' as it is positional not-nullable parameter");
          }

          if (param.isRequiredNamed && param.type.nullabilitySuffix != NullabilitySuffix.question) {
            throw InvalidGenerationSourceError(
                "Can't ignore member '${sourceField.displayName}' as it is required not-nullable parameter");
          }
        }

        final sourceAssignment = SourceAssignment(
          sourceField: sourceFields[param.name]!,
          targetField: targetField,
          targetConstructorParam: constructorAssignment,
          memberMapping: mapping.tryGetMapping(targetField.displayName),
        );

        mappedTargetConstructorParams.add(sourceAssignment);
        mappedSourceFieldNames.add(param.name);
      } else {
        final targetField =
            targetClass.fields.firstWhere((targetField) => targetField.displayName == param.displayName);
        notMappedTargetParameters.add(
          SourceAssignment(
              sourceField: null,
              targetField: targetField,
              memberMapping: mapping.tryGetMapping(targetField.displayName),
              targetConstructorParam: constructorAssignment),
        );
      }
    }

    _assertNotMappedConstructorParameters(notMappedTargetParameters);
    // Prepare and merge mapped and notMapped parameters into Positional and Named arrays
    final mappedPositionalParameters =
        mappedTargetConstructorParams.where((x) => x.targetConstructorParam?.position != null);
    final notMappedPositionalParameters =
        notMappedTargetParameters.where((x) => x.targetConstructorParam?.position != null);

    final positionalParameters = <SourceAssignment>[...mappedPositionalParameters, ...notMappedPositionalParameters];
    positionalParameters.sortByCompare((x) => x.targetConstructorParam!.position!, (a, b) => a - b);

    final namedParameters = <SourceAssignment>[
      ...mappedTargetConstructorParams.where((x) => x.targetConstructorParam?.isNamed ?? false),
      ...notMappedTargetParameters.where((element) => element.targetConstructorParam?.isNamed ?? false)
    ];

    // Mapped fields into constructor - positional and named
    final constructorExpr = _mapConstructor(
      targetConstructor,
      positional: positionalParameters,
      named: namedParameters,
    );
    block.statements.add(constructorExpr);

    // Not mapped directly in constructor
    _mapSetterFields(mappedSourceFieldNames, sourceFields, targetClass, block);

    block.statements.add(refer('result').returned.statement);
    return block.build();
  }

  void _assertNotMappedConstructorParameters(List<SourceAssignment> notMappedParameters) {
    final notMapped = notMappedParameters.map((e) => e.targetConstructorParam!.param);

    for (var param in notMapped) {
      if (param.isPositional && param.type.nullabilitySuffix != NullabilitySuffix.question) {
        throw InvalidGenerationSourceError(
          "Can't generate mapping ${mapping.toString()} as there is non mapped not-nullable positional parameter ${param.displayName}",
        );
      }

      if (param.isRequiredNamed && param.type.nullabilitySuffix != NullabilitySuffix.question) {
        throw InvalidGenerationSourceError(
          "Can't generate mapping ${mapping.toString()} as there is non mapped not-nullable required parameter ${param.displayName}",
        );
      }
    }
  }

  void _mapSetterFields(
    List<String> alreadyMapped,
    Map<String, FieldElement> sourceFields,
    ClassElement targetClass,
    BlockBuilder block,
  ) {
    bool filterField(FieldElement field) => true;

    final potentialSetterFields = sourceFields.keys.where((field) => !alreadyMapped.contains(field)).toList();

    final fields = <FieldElement>[];

    for (final key in potentialSetterFields) {
      if (filterField(sourceFields[key]!)) {
        fields.add(sourceFields[key]!);
      }
    }

    for (final sourceField in fields) {
      final targetField = targetClass.fields.firstWhere((field) => field.displayName == sourceField.displayName);

      // Source.X has ignore:true -> skip
      if (mapping.memberShouldBeIgnored(sourceField.displayName)) continue;

      // assign result.X = model.X
      final expr = refer('result').property(sourceField.displayName).assign(
            _assignValue(
              SourceAssignment(
                sourceField: sourceField,
                targetField: targetField,
              ),
            ),
          );

      block.statements.add(expr.statement);
    }
  }

  Code _mapConstructor(ConstructorElement targetConstructor,
      {required List<SourceAssignment> positional, required List<SourceAssignment> named}) {
    return declareFinal('result')
        .assign(refer(targetConstructor.displayName).newInstance(
          positional.map((assignment) => _assignValue(assignment)),
          {
            for (final assignment in named) assignment.targetConstructorParam!.param.name: _assignValue(assignment),
          },
        ))
        .statement;
  }

  Map<String, FieldElement> _getSourceFields(ClassElement sourceClass) {
    fieldFilter(FieldElement field) => !field.isSynthetic;

    return {
      for (final field in sourceClass.fields.where(fieldFilter)) field.name: field,
    };
  }

  /// Tries to find best constructor for mapping -> currently returns constructor with the most parameter count
  ConstructorElement _findBestConstructor(ClassElement element) {
    final constructors = element.constructors;

    constructors.sort(((a, b) => b.parameters.length - a.parameters.length));

    return constructors.first;
  }

  Expression _assignValue(SourceAssignment assignment) {
//    if (mapping.mapperOptionsFnCallback != null) {}
    if (assignment.sourceField == null) return refer('null');

    if (mapping.hasMapping(assignment.sourceField!.displayName)) {
      final memberMapping = mapping.getMapping(assignment.sourceField!.displayName);

      if (memberMapping.ignore) {
        return refer('null');
      }

      final target = memberMapping.target;
      // Support Function mapping
      if (target != null) {
        // Eg. when static class is used => Static.mapFrom()
        final hasStaticProxy = target.enclosingElement.displayName.isNotEmpty;
        final callRefer =
            hasStaticProxy ? '${target.enclosingElement.displayName}.${target.displayName}' : target.displayName;

        return refer(callRefer).call([refer('model')]);
      }
    }

    if (assignment.shouldAssignList()) {
      return _assignListvalue(assignment);
    }

    // Mapping nested object
    if (assignment.sourceField!.type.isSimpleType == false) {}

    return refer('model').property(assignment.sourceField!.name);
  }

  Expression _assignListvalue(SourceAssignment assignment) {
    final sourceNullable = assignment.sourceField!.type.nullabilitySuffix == NullabilitySuffix.question;
    final targetNullable = assignment.targetField.type.nullabilitySuffix == NullabilitySuffix.question;

    print('S: $sourceNullable, T: $targetNullable');

    if (targetNullable && sourceNullable == false) {
      return refer('model').property(assignment.sourceField!.name);
    }

    if (targetNullable == false && sourceNullable) {
      return refer('model').property(assignment.sourceField!.name).ifNullThen(refer('[]'));
    }

    // sourceNullable && targetNullable
    return refer('model').property(assignment.sourceField!.name);
  }
}
