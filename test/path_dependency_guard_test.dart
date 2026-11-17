// Issue #28: the fleet mono-version alignment keeps re-adding sibling path
// overrides (`zuraffa: path: ../zuraffa`) that only exist on a developer
// checkout. In CI they fail `flutter pub get`, so one alignment commit reds
// the base for every PR after it (#15, #16, #17, #25, #26, #27). The guard in
// `.github/workflows/test.yml` runs `scripts/check_path_deps.py` BEFORE
// `flutter pub get`; these tests pin that script's contract against throwaway
// fixture trees.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('out-of-repo path dependency guard', () {
    test('accepts a repo whose path dependencies stay inside', () async {
      final root = await _fixture(<String, String>{
        'pubspec.yaml': _pubspec('fixture'),
        'example/pubspec.yaml': _pubspec(
          'fixture_example',
          extra: '''
  fixture:
    path: ../
''',
        ),
      });

      final result = await _run(root);

      expect(result.exitCode, 0, reason: result.output);
      expect(result.output, contains('1 in-repo, 0 outside'));
    });

    test('fails loudly for a path dependency that escapes the repo', () async {
      final root = await _fixture(<String, String>{
        'pubspec.yaml': _pubspec('fixture'),
        'example/pubspec.yaml': _pubspec(
          'fixture_example',
          extra: '''
  zuraffa:
    path: ../../zuraffa
''',
        ),
      });

      final result = await _run(root);

      expect(result.exitCode, isNot(0));
      expect(result.output, contains('example/pubspec.yaml'));
      expect(result.output, contains('zuraffa'));
      expect(result.output, contains('outside the repo'));
    });

    test('ignores a path: key that is not a dependency', () async {
      final root = await _fixture(<String, String>{
        'pubspec.yaml': _pubspec(
          'fixture',
          extra: '''
flutter:
  config:
    path: ../outside-the-repo
''',
        ),
      });

      final result = await _run(root);

      expect(result.exitCode, 0, reason: result.output);
    });
  });
}

/// A minimal pubspec with a `dependencies:` block the guard must read.
String _pubspec(String name, {String extra = ''}) =>
    '''
name: $name
description: fixture for the out-of-repo path dependency guard
version: 1.0.0
environment:
  sdk: ^3.13.0
dependencies:
  flutter:
    sdk: flutter
$extra''';

/// Writes the fixture pubspecs under a throwaway root and returns that root.
Future<Directory> _fixture(Map<String, String> files) async {
  final root = await Directory.systemTemp.createTemp('path-deps-guard-');
  for (final entry in files.entries) {
    final file = File('${root.path}/${entry.key}');
    await file.parent.create(recursive: true);
    await file.writeAsString(entry.value);
  }
  addTearDown(() => root.delete(recursive: true));
  return root;
}

/// Runs the guard the way the workflow step does, with its two streams merged.
Future<({int exitCode, String output})> _run(Directory root) async {
  final result = await Process.run('python3', <String>[
    'scripts/check_path_deps.py',
    root.path,
  ], workingDirectory: Directory.current.path);
  final output = '${result.stdout}${result.stderr}';
  return (exitCode: result.exitCode, output: output);
}
