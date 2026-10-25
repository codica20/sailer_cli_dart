import 'dart:convert';

import 'package:args/command_runner.dart' show Command;
import 'package:logging/logging.dart' show Logger;
import 'package:sailer_cli_dart/sailer/get_dashboard_source.dart';

import '../common/config.dart' show sailerCliConfig;
import '../sailer/analyze_data.dart' show sailerKeys;

class ListKeysCommand extends Command {
  @override
  final name = "list-keys";
  @override
  final description = "Zeige Wertenamen von SAILER Master";

  final log = Logger("ListKeysCommand");

  new() {
    argParser.addFlag(
      "show-browser",
      defaultsTo: false,
      help: "Zeige Browser beim Herunterladen",
    );

    argParser.addOption(
      "filter",
      valueHelp: "REGEX-Muster",
      help: "filtert Wertenamen",
    );
  }

  // [run] may also return a Future.
  @override
  void run() async {
    log.info("checke ...");
    try {
      bool headless =
          !(argResults?.flag("show-browser") ?? false);
      final sailerOptions = sailerCliConfig.sailerOptions(
        headless,
      );

      GetDashboardSourceReturn result =
          await getDashboardSource(sailerOptions);

      final String? filterPattern = argResults?.option(
        "filter",
      );
      final List<String> sailerKeysList = sailerKeys(
        result.vControllerData,
        filterPattern,
      );

      print(
        JsonEncoder.withIndent("  ")
            .convert(sailerKeysList),
      );
      //print("SailerKeys: $sailerKeysList");
      // print("vCont ${result.vControllerData}");
      //      print("Content: ${result.content}");
      await result.browser.close();
    } catch (e, stackTrace) {
      log.severe("FEHLER beim Auflisten der Wertenamen: $e");
      log.severe("Stacktrace: $stackTrace");
    }
  }
}
