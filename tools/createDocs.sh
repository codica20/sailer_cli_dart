#! /bin/bash
if [ ! -e pubspec.yaml ]; then
  echo Please run script in project directory
  exit 2;
fi;
mkdir -p docs
dart run bin/sailer_cli_dart.dart --help > docs/helpmessage.ext