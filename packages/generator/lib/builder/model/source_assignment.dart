import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

class ConstructorAssignment {
  final ParameterElement param;
  final int? position;

  bool get isNamed => param.isNamed;

  ConstructorAssignment({
    required this.param,
    this.position,
  });
}

class SourceAssignment {
  final FieldElement sourceField;
  final ConstructorAssignment? targetConstructorParam;
  final FieldElement target;

  SourceAssignment({
    required this.sourceField,
    required this.target,
    this.targetConstructorParam,
  });

  bool shouldAssignList() {
    // The source can be mapped to the target, if the source is mapable object and the target is listLike.
    return _isCoreListLike(targetConstructorParam?.param.type ?? target.type) && _isMapable(sourceField.type);
  }

  bool _isCoreListLike(DartType type) {
    return type.isDartCoreList || type.isDartCoreSet || type.isDartCoreIterable;
  }

  bool _isMapable(DartType type) {
    if (_isCoreListLike(type)) {
      return true;
    }

    if (type is! InterfaceType) {
      return false;
    }
    return type.allSupertypes.any(_isCoreListLike);
  }
}
