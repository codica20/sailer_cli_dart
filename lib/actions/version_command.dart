import 'package:args/command_runner.dart' show Command;
import 'package:sailer_cli_dart/app_info.dart';

class VersionCommand extends Command {
  @override
  final name = "version";
  @override
  final description = "Zeige Version.";

  // [run] may also return a Future.
  @override
  void run() {
    print("$appTitle V$appVersion");
  }
}
