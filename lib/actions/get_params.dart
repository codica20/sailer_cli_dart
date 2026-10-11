import 'dart:convert';

import 'package:dotenv/dotenv.dart' show DotEnv;
import 'package:args/command_runner.dart' show Command;
import 'package:sailer_cli_dart/actions/env_keys.dart';
import 'package:sailer_cli_dart/sailer/get_dashboard_source.dart';
import 'package:sailer_cli_dart/sailer/sailer_model.dart';

import '../sailer/analyze_data.dart' show sailerValues;

class GetParamsCommand extends Command {
  @override
  final name = "get-params";
  @override
  final description = "Zeige Werte von SAILER Master";

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
    print("checke ...");
    try {
      var env = DotEnv(includePlatformEnvironment: true)
        ..load();
      bool headless =
          !(argResults?.flag("show-browser") ?? false);
      String? sailerUser = env[sailerUserKey];
      if (sailerUser == null) {
        throw Exception("Bitte $sailerUserKey angeben!");
      }
      String? sailerPassword = env[sailerPasswordKey];
      if (sailerPassword == null) {
        throw Exception(
          "Bitte $sailerPasswordKey angeben!",
        );
      }
      String? sailerPortalUrl = env[sailerPortalUriKey];

      GetDashboardSourceReturn result =
          await getDashboardSource(
            sailerUser: sailerUser,
            sailerPassword: sailerPassword,
            sailerPortalUrl: sailerPortalUrl,
            headless: headless,
          );

      final String? filterPattern = argResults?.option(
        "filter",
      );
      final List<SailerValue> sailerValuesList =
          sailerValues(
            result.vControllerData,
            filterPattern,
          );

      print(
        JsonEncoder.withIndent("  ")
            .convert(sailerValuesList),
      );
      //print("SailerKeys: $sailerKeysList");
      // print("vCont ${result.vControllerData}");
      //      print("Content: ${result.content}");
      await result.browser.close();
    } catch (e, stackTrace) {
      print("FEHLER beim Auflisten der Wertenamen: $e");
      print("Stacktrace: $stackTrace");
    }
  }
}
