import 'package:sailer_cli_dart/actions/command_parser.dart';

const String version = '0.0.1';

void main(List<String> arguments) {
  try {
    sailerCmdRnr.run(arguments);
  } catch (e) {
    print("FEHLER: $e");
    print("$arguments");
    sailerCmdRnr.printUsage();
  }
}
