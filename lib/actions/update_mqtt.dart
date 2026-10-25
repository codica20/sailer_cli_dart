import 'dart:convert';

import 'package:args/command_runner.dart' show Command;
import 'package:logging/logging.dart' show Logger;
import 'package:sailer_cli_dart/common/config.dart';
import 'package:sailer_cli_dart/mqtt/publish_mqtt.dart';
import 'package:sailer_cli_dart/sailer/get_dashboard_source.dart';
import 'package:sailer_cli_dart/sailer/sailer_model.dart';

import '../sailer/analyze_data.dart' show sailerValues;

class UpdateMqttCommand extends Command {
  @override
  final name = "update-mqtt";
  @override
  final description =
      "Veröffentliche SAILER-Werte auf MQTT";

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

  @override
  Future<void> run() async {
    //TODO: reuse code from get_params.dart and list_keys.dart
    final log = Logger("UpdateMqttCómmand");
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
      final List<SailerValue> sailerValuesList =
          sailerValues(
            result.vControllerData,
            filterPattern,
          );

      log.info(
        JsonEncoder.withIndent("  ")
            .convert(sailerValuesList),
      );

      final mqttOptions = sailerCliConfig.mqttOptions();
      for (final sVal in sailerValuesList) {
        log.info("Publishing $sVal...");
        await publishMqttState(sVal, mqttOptions);
      }
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
