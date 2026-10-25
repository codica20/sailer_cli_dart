import '../util/jsoning.dart';

class MqttOptions({
  required final String mqttServer,
  final String? mqttPort,

  /// @see getMqttDiscoveryPrefix
  final String? discoveryPrefix,

  /// See getMqttEntityName
  final String? entityPrefix,

  /// the mqtt state topic path prefix, i.e. everything before the name of the entity.
  ///  Default: "sailer"
  final String? stateTopicPathPrefix,

  /// Sailer Device Name (as displayed in Home Assistant).
  /// Default: "SAILER"
  final String? sailerDeviceName,

  final bool mqttLogging=false
}) {
  Map<String, String?> toJson() {
    return <String, String?>{
      "mqttServer": mqttServer,
      "mqttPort": mqttPort,
      "discoveryPrefix": discoveryPrefix,
      "entityPrefix": entityPrefix,
      "stateTopicPathPrefix": stateTopicPathPrefix,
      "sailerDeviceName": sailerDeviceName,
    };
  }

  @override
  String toString() {
    return jsoning(toJson());
  }
}
