import 'package:automapper_generator/generator/generator.dart';
import 'package:path/path.dart' as p;
import 'package:source_gen_test/source_gen_test.dart';

void main() async {
  initializeBuildLogTracking();
  final reader = await initializeLibraryReaderForDirectory(
    p.join('test', 'fixture'),
    'input.dart',
  );

  testAnnotatedElements(
    reader,
    MapperGenerator(),
    expectedAnnotatedTests: _expectedAnnotatedTests,
  );

  // test('debug', () async {

  //   final generator = SuccessGenerator.fromBuilder('example', automapperBuilder, compareWithFixture: false);

  //   await generator.test();

  //   final v = generator.fixtureContent();

  //   print(v);
  // });

  // test('fixtures', () async {
  //   initializeBuildLogTracking();
  //   final reader = await initializeLibraryReaderForDirectory(
  //     p.join('test', 'fixture'),
  //     'input.dart',
  //   );

  //   testAnnotatedElements(
  //     reader,
  //     MapperGenerator(),
  //     expectedAnnotatedTests: _expectedAnnotatedTests,
  //   );
  // });
}

const _expectedAnnotatedTests = {
  'OnlyPositional',
};
