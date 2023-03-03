@Skip('Only for manual run')

import 'dart:io';

import 'package:automapper_generator/builder.dart';
import 'package:generator_test/generator_test.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() async {
  final fixtureDir = Directory(p.join('test', 'fixture'));

  final files = (await fixtureDir.list().toList()).whereType<File>();

  for (var file in files) {
    test('Test ${file.uri.pathSegments.last}', () async {
      final generator = SuccessGenerator.fromBuilder('only_positional', automapperBuilder,
          inputDir: 'test/fixture', // default
          fixtureDir: 'test/fixture/fixtures', // default
          compareWithFixture: true, // use `false` to validate dart code only
          // fixtureFileName: 'failed', // used when fixture file name does not match input file name
          onLog: (x) => print(x.message));

// run the test
      await generator.test();
    });
  }
}
