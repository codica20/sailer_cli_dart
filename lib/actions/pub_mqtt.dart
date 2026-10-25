import 'package:dotenv/dotenv.dart' show DotEnv;
import 'package:args/command_runner.dart' show Command;
import 'package:sailer_cli_dart/actions/env_keys.dart';
import 'package:sailer_cli_dart/mqtt/mqtt_model.dart';
import 'package:sailer_cli_dart/mqtt/publish_mqtt.dart';
import 'package:sailer_cli_dart/sailer/sailer_model.dart';

class PublishMqttCommand extends Command {
  @override
  final name = "pub-mqtt";
  @override
  final description = "Veröffentliche TEST-Wert auf MQTT";

  @override
  Future<void> run() async {
    print("checke ...");
    try {
      var env = DotEnv(includePlatformEnvironment: true)
        ..load();

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

      print("MQTT-Options: $options");
      final sVal = //SailerBitValue("test", false);
      SailerVariableValue(
        "Raumtemperatur HK 1",
        22.5,
        "°C",
      );
      print("Sailer-Test-Value: $sVal");

      await publishMqttState(
        sailerValue: sVal,
        options: options,
      );
    } catch (e, stackTrace) {
      print("FEHLER beim Auflisten der Wertenamen: $e");
      print("Stacktrace: $stackTrace");
    }
  }
}
