import 'package:analyzer/dart/element/type.dart';
import 'package:code_builder/code_builder.dart';

class AutoMapPart {
  final DartType source;
  final DartType target;
  //todo use this
  Reference get sourceRefer => refer(source.toString());
  Reference get targetRefer => refer(target.toString());

  String get mappingMapMethodName =>
      'map${source.getDisplayString(withNullability: false)}To${target.getDisplayString(withNullability: false)}';

  AutoMapPart({
    required this.source,
    required this.target,
  });

  @override
  String toString() {
    return 'AutoMap - $source -> $target';
  }
}
