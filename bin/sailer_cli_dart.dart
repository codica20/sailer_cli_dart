import 'package:logging/logging.dart' show Logger, Level;
import 'package:sailer_cli_dart/actions/command_parser.dart';

const String version = '0.0.1';

void main(List<String> arguments) {
  Logger.root.level = Level.INFO; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: ${record.time}: ${record.message}',
    );
  });
  final log = Logger("main()");
  try {
    sailerCmdRnr.run(arguments);
  } catch (e) {
    log.severe("FEHLER: $e");
    log.severe("$arguments");
    sailerCmdRnr.printUsage();
  }
}
