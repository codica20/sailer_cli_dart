import 'package:dotenv/dotenv.dart';
import 'package:sailer_cli_dart/sailer/get_dashboard_source.dart';

import '../actions/env_keys.dart';
import '../mqtt/mqtt_model.dart';

const _dotenvQuiet = true;

class SailerCliConfig {
  SailerOptions sailerOptions(bool? headless) {
    var env = DotEnv(
      includePlatformEnvironment: true,
      quiet: _dotenvQuiet,
    )..load();
    String? sailerUser = env[sailerUserKey];
    if (sailerUser == null) {
      throw Exception("Bitte $sailerUserKey angeben!");
    }
    String? sailerPassword = env[sailerPasswordKey];
    if (sailerPassword == null) {
      throw Exception("Bitte $sailerPasswordKey angeben!");
    }
    String? sailerPortalUrl = env[sailerPortalUriKey];

    return SailerOptions(
      sailerUser: sailerUser,
      sailerPassword: sailerPassword,
      sailerPortalUrl: sailerPortalUrl,
      headless: headless,
    );
  }

  MqttOptions mqttOptions() {
    var env = DotEnv(
      includePlatformEnvironment: true,
      quiet: _dotenvQuiet,
    )..load();
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
    return options;
  }
}

final sailerCliConfig = SailerCliConfig();
