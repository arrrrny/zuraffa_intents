// GENERATED STUB — hand step (U1:hand, issue #1308 seam).
//
// behavior_id: U1
// source_criterion: FR-001, publishability
// ignore_for_file: non_constant_identifier_names
library;

import 'dart:io';

/// Subject for behavior U1: the publish metadata.
Map<String, String> subject_u1() => {
  'pubspec': File('pubspec.yaml').readAsStringSync(),
  'changelog': File('CHANGELOG.md').readAsStringSync(),
  'license': File('LICENSE').readAsStringSync(),
};
