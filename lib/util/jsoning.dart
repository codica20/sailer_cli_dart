import 'dart:convert' show JsonEncoder;

String jsoning(dynamic value) =>
    JsonEncoder.withIndent("  ").convert(value);
