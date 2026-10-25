import 'dart:io';

import 'package:characters/characters.dart';
import 'package:logging/logging.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:sailer_cli_dart/util/jsoning.dart';

import '../sailer/sailer_model.dart'
    show SailerBitValue, SailerValue, SailerVariableValue;
import 'mqtt_model.dart' show MqttOptions;

const origin = "sailer_cli_dart";

Future<MqttServerClient> createMqttClient(
  MqttOptions options,
) async {
  final log = Logger("createMqttClient()");
  final String mqttHost = options.mqttServer;
  final int? mqttPort = options.mqttPort == null
      ? null
      : int.parse(options.mqttPort!);
  final clientIdentifier = Platform.localHostname;

  final client = MqttServerClient(
    mqttHost,
    clientIdentifier,
  );
  if (mqttPort != null) {
    client.port = mqttPort;
  }

  client.onConnected = () {
    log.info("CONNECTED");
  };
  client.onDisconnected = () {
    log.info("DISCONNECTED");
  };

  client.logging(on: options.mqttLogging);

  client.keepAlivePeriod = 60;

  log.fine("Connecting to mqtt...");
  try {
    await client.connect();
  } catch (e, stackTrace) {
    log.severe("e: $e");

    log.severe("stackTrace: $stackTrace");
    rethrow;
  }
  log.info("Connected: ${client.connectionStatus?.state}");
  return client;
}

/// publishes sailerValue to MQTT. It also publishes a
/// discovery message.
/// If a mqttClient is provided, it will be used
/// (and not disconnected).
Future<void> publishMqttState({
  required SailerValue sailerValue,
  required MqttOptions options,
  MqttServerClient? mqttClient,
}) async {
  final log = Logger("publishMqttState");
  log.fine("sailerValue: $sailerValue");
  log.fine("options: $options");
  log.fine("mqttClient: $mqttClient");

  MqttClient client = (mqttClient == null)
      ? await createMqttClient(options)
      : mqttClient;

  //------------ publish mqtt discovery ----------------
  final mqttDiscoveryTopic = getMqttDiscoveryTopic(
    sailerValue,
    options,
  );
  final mqttDiscoveryMessage = getMqttDiscoveryMessage(
    sailerValue,
    options,
  );

  log.fine(
    jsoning({
      "disc_topic": mqttDiscoveryTopic,
      "disc_message": mqttDiscoveryMessage,
    }),
  );

  await publishMqttMessage(
    mqttClient: client,
    mqttTopic: mqttDiscoveryTopic,
    mqttMessage: mqttDiscoveryMessage,
  );

  // ---------- publish Mqtt State --------------
  final String mqttTopic = getMqttStateTopic(
    sailerValue,
    options,
  );
  final String mqttMessage = getMqttMessage(
    sailerValue,
    options,
  );
  await publishMqttMessage(
    mqttClient: client,
    mqttTopic: mqttTopic,
    mqttMessage: mqttMessage,
  );
  if (mqttClient == null) {
    client.disconnect();
  }
}

/// low level function to publish a message to MQTT Host
/// using given MQTT-client.
/// Caller has to disconnect MQTT client.
Future<void> publishMqttMessage({
  required MqttClient mqttClient,
  required String mqttTopic,
  required String mqttMessage,
}) async {
  final log = Logger("publishMqttMessage()");

  final msgBuilder = MqttPayloadBuilder();
  msgBuilder.addUTF8String(mqttMessage);
  log.fine(
    jsoning({
      "mqttTopic": mqttTopic,
      "mqttMessage": mqttMessage,
      "payload_len": msgBuilder.payload?.length,
    }),
  );
  mqttClient.publishMessage(
    mqttTopic,
    .atLeastOnce,
    msgBuilder.payload!,
  );
}

/// low level function to publish a single message to MQTT Host
/// MQTT client connects and disconnects
Future<void> publishSingleMqttMessage({
  required String mqttHost,
  int? mqttPort,
  required String mqttTopic,
  required String mqttMessage,
}) async {
  final log = Logger("publishSingleMqttMessage()");
  final client = await createMqttClient(
    MqttOptions(
      mqttServer: mqttHost,
      mqttPort: mqttPort?.toString(),
    ),
  );

  final msgBuilder = MqttPayloadBuilder();
  msgBuilder.addUTF8String(mqttMessage);
  log.fine(
    jsoning({
      "mqttTopic": mqttTopic,
      "mqttMessage": mqttMessage,
      "payload_len": msgBuilder.payload?.length,
    }),
  );
  client.publishMessage(
    mqttTopic,
    .atMostOnce,
    msgBuilder.payload!,
  );

  client.disconnect();
}

String getMqttDiscoveryTopic(
  SailerValue sailerValue,
  MqttOptions options,
) {
  switch (sailerValue) {
    case SailerBitValue():
      print("bitvalue ");
    case SailerVariableValue(
          key: String _,
          value: num _,
          unit: String unit,
        )
        when unit != "°C":
      throw Exception(
        "Units other than °C are not accepted: $sailerValue",
      );
    default:
      print("Variable value");
  }
  return ("${getMqttDiscoveryPrefix(options)}${switch (sailerValue) {
    SailerVariableValue() => "/sensor/",
    _ => "/binary_sensor/",
  }}${getMqttEntityName(sailerValue, options)}/config");
}

String getMqttMessage(
  SailerValue sailerValue,
  MqttOptions options,
) {
  switch (sailerValue) {
    case SailerBitValue(key: _, value: final value):
      return bool2OnOff(value);
    case SailerVariableValue(
      key: _,
      value: final value,
      unit: _,
    ):
      return value.toStringAsFixed(1);
  }
}

/// returns the homeassistant mqtt discovery prefix
///
/// @see https://www.home-assistant.io/integrations/mqtt/#mqtt-discovery
String getMqttDiscoveryPrefix(MqttOptions options) {
  return options.discoveryPrefix ?? "homeassistant";
}

String getMqttDiscoveryMessage(
  SailerValue sailerValue,
  MqttOptions options,
) {
  switch (sailerValue) {
    case SailerBitValue(:final key, value: _):
      final msgData = {
        "name": key,
        "unique_id": getMqttEntityName(
          sailerValue,
          options,
        ),
        //   "device_class": "heat",
        "state_topic": getMqttStateTopic(
          sailerValue,
          options,
        ),
        "device": {
          "identifiers": [getSailerDeviceName(options)],
          "name": getSailerDeviceName(options),
          "manufacturer": "Sailer Ehingen",
        },
        "origin": {"name": origin},
      };
      return jsoning(msgData);
    case SailerVariableValue(
      key: final key,
      value: _,
      :final unit,
    ):
      if (unit == "°C") {
        final msgData = {
          //TODO: reuse code from SailerBitValue
          "name": key,
          "unique_id": getMqttEntityName(
            sailerValue,
            options,
          ),
          "device_class": "temperature",
          "state_class": "measurement",
          "state_topic": getMqttStateTopic(
            sailerValue,
            options,
          ),
          "unit_of_measurement": unit,
          "device": {
            "identifiers": [getSailerDeviceName(options)],
            "name": getSailerDeviceName(options),
            "manufacturer": "Sailer Ehingen",
          },
          "origin": {"name": origin},
        };

        return jsoning(msgData);
      } else {
        throw Exception(
          "SailerValue is not implemented: $sailerValue",
        );
      }
  }
}

String getMqttStateTopic(
  SailerValue sailerValue,
  MqttOptions options,
) {
  return ("${options.stateTopicPathPrefix ?? "sailer"}/${getMqttEntityName(sailerValue, options)}");
}

/// returns prefix plus encoded sailerValue.title. It is used in Mqtt Discovery Topic and Mqtt State Topic
String getMqttEntityName(
  SailerValue sailerValue,
  MqttOptions options,
) {
  return "${options.entityPrefix ?? "sailer_"}${encodeChars(sailerValue.key)}";
}

/// returns options.sailerDeviceName or "SAILER"
String getSailerDeviceName(MqttOptions options) {
  return options.sailerDeviceName ?? "SAILER";
}

/// returns an identifier name from a text string
///
String encodeChars(String decoded) {
  const keyMap = <String, String>{
    " ": "_",
    "ß": "ss",
    "ä": "ae",
    "ö": "oe",
    "ü": "ue",
    "Ä": "ae",
    "Ö": "oe",
    "Ü": "ue",
    ".": "_",
    ":": "_",
  };
  final result = <String>[];
  bool underscore = false;
  for (final a in Characters(decoded)) {
    final value = keyMap[a];
    // only one underscore in a row
    final String encodedToken = value ?? a.toLowerCase();
    if (encodedToken == "_") {
      if (!underscore) {
        result.add("_");
        underscore = true;
      }
      // do not push an underscore, if already pushed
    } else {
      result.add(encodedToken);
      underscore = false;
    }
  }
  return result.join("");
}

String bool2OnOff(bool value) {
  return value ? "ON" : "OFF";
}
