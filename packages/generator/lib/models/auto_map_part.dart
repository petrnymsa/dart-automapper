import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';
import 'package:equatable/equatable.dart';

class AutoMapPart extends Equatable {
  final DartType source;
  final DartType target;

  Reference get sourceRefer =>
      refer(source.getDisplayString(withNullability: true));

  Reference get targetRefer =>
      refer(target.getDisplayString(withNullability: true));

  String get mappingMapMethodName =>
      '_map${source.getDisplayString(withNullability: false)}To${target.getDisplayString(withNullability: false)}';

  AutoMapPart({
    required this.source,
    required this.target,
  });

  @override
  String toString() {
    return 'AutoMap - $source -> $target';
  }

  @override
  List<Object> get props => [source, target];
}
