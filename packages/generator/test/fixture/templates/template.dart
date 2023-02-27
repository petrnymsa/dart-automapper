const typeOfTemplate = 'Type _typeOf<X>() => X;';

const convertHeader = 'R convert<I, R>(I model) {';

const convertMethodException = r"throw Exception('No mapper found for ${model.runtimeType}');";

String buildConvert(Map<String, String> mappings) {
  StringBuffer b = StringBuffer();

  b.writeln(convertHeader);

  for (final k in mappings.keys) {
    final target = mappings[k];

    b.writeln('''
        if(model is $k && _typeOf<R>() == $target) {
          return (_map${k}To$target) as R);
        }
      ''');
  }

  b.writeln(r"throw Exception('No mapper found for ${model.runtimeType}');");

  return b.toString();
}
