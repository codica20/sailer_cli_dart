import 'package:args/command_runner.dart';
import 'package:sailer_cli_dart/actions/get_params.dart';
import 'package:sailer_cli_dart/actions/list_keys.dart';
import 'package:sailer_cli_dart/actions/pub_mqtt.dart';
import 'package:sailer_cli_dart/actions/update_mqtt.dart';
import 'package:sailer_cli_dart/actions/version_command.dart';

CommandRunner sailerCmdRnr =
    CommandRunner(
        "sailer",
        "Eine Neuimplementierung von sailer_cli mit Dart. Es holt Werte vom SAILER Remoteportal und stellt sie per MQTT zur Verfügung.",
      )
      ..addCommand(VersionCommand())
      ..addCommand(ListKeysCommand())
      ..addCommand(GetParamsCommand())
      ..addCommand(UpdateMqttCommand())
      ..addCommand(PublishMqttCommand());
