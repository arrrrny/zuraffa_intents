# TDD Profile — Flutter plugin (converted from Dart for spec-002)

This profile is read by the `tdd` spec-kit extension.

Spec-002 converted this package from a pure-Dart package into a Flutter
plugin (`flutter: plugin:` with android/ios/macos/linux/windows/web). The
runner therefore flips from `dart test` to `flutter test`; every other
property of the loop is unchanged.

## Stack

- **Language**: Dart (latest stable) on the Flutter SDK (`flutter: ">=3.44.0"`).
- **Test runner**: `flutter test`. Invoked as `flutter test`.
- **Static analysis**: `flutter analyze`. Configured via `analysis_options.yaml`.
- **Mutation tool**: opt-in via the `mutation_test` dev_dependency (^1.8.0).
- **Coverage**: `flutter test --coverage` (lcov written to `coverage/lcov.info`).

## Commands

- Single test: `flutter test {file} --plain-name "{name}"`
- Whole file: `flutter test {file}`
- Full suite: `flutter test`
- Coverage: `flutter test --coverage`

## Keys (machine-readable)

```yaml
runner: flutter
single: 'flutter test {file} --plain-name "{name}"'
file: 'flutter test {file}'
suite: 'flutter test'
coverage: 'flutter test --coverage'
```
