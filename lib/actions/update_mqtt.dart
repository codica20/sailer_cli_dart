import 'dart:convert';

import 'package:dotenv/dotenv.dart' show DotEnv;
import 'package:args/command_runner.dart' show Command;
import 'package:sailer_cli_dart/actions/env_keys.dart';
import 'package:sailer_cli_dart/mqtt/mqtt_model.dart';
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
  Future<void> run() async { //TODO: reuse code from get_params.dart and list_keys.dart
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

      String? mqttServer = env[mqttServerKey];
      if (null == mqttServer) {
        throw Exception("Bitte $mqttServerKey angeben!");
      }

      String? mqttHADiscoveryPrefix =
          env[mqttHADiscoveryPrefixKey];
      String? mqttPortString = env[mqttPortKey];

      String? mqttEntityPrefix = env[mqttHAEntityPrefixKey];
      String? mqttDeviceName = env[mqttHADeviceNameKey];
      String? stateTopicPathPrefix =
          env[mqttHAStateTopicPathPrefixKey];
      final options = MqttOptions(
        mqttServer: mqttServer,
        mqttPort: mqttPortString,
        discoveryPrefix: mqttHADiscoveryPrefix,
        entityPrefix: mqttEntityPrefix,
        sailerDeviceName: mqttDeviceName,
        stateTopicPathPrefix: stateTopicPathPrefix,
      );

      for (final sVal in sailerValuesList) {
        print("Publishing $sVal...");
        await publishMqttState(sVal, options);
      }
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
