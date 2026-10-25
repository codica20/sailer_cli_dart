import 'package:logging/logging.dart' show Logger, Level;
import 'package:sailer_cli_dart/actions/command_parser.dart';


void main(List<String> arguments) async {
  Logger.root.level = Level.FINE; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print(
      '${record.level.name}: ${record.time}: ${record.message}',
    );
  });
  final log = Logger("main()");
  try {
    await sailerCmdRnr.run(arguments);
  } catch (e, stackTrace) {
    log.severe("FEHLER: $e");
    log.severe("Stacktrace: $stackTrace");
    log.severe("$arguments");
    sailerCmdRnr.printUsage();
  }
}
