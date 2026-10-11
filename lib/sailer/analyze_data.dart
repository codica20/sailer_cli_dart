import 'package:sailer_cli_dart/sailer/sailer_model.dart';

import '../util/jsoning.dart';
import 'get_dashboard_source.dart' show VControllerData;

List<String> sailerKeys(
  VControllerData vControllerData,
  String? filterPattern,
) {
  final result = orgParams(
    vControllerData,
    filterPattern,
  ).map((param) => sailerKey(param)).toList();
  return result..sort();
}

List<SailerValue> sailerValues(
  VControllerData vControllerData,
  String? filterPattern,
) {
  final result = orgParams(
    vControllerData,
    filterPattern,
  ).map((param) => sailerValue(param)).toList();
  return result..sort(
    (valueA, valueB) => valueA.key.compareTo(valueB.key),
  );
}

typedef VCDParamValue = dynamic;

List<VCDParamValue> orgParams(
  VControllerData vControllerData,
  String? filterPattern,
) {
  final Map<String, VCDParamValue> paramMap =
      vControllerData["_parameter"];
  if (filterPattern == null) {
    final result = paramMap.values.toList();
    return result;
  } else {
    final RegExp re = RegExp(
      filterPattern,
      caseSensitive: false,
    );
    final result = paramMap.values
        .where((param) => re.hasMatch(sailerKey(param)))
        .toList();
    return result;
  }
}

String sailerKey(VCDParamValue paramValue) {
  final String? parameterGroupTitle =
      paramValue["parameter_group_title"];

  final String prefix = parameterGroupTitle != null
      ? "${parameterGroupTitle}_"
      : "";
  final String? titleShort1 = paramValue["title_short1"];
  final String suffix = titleShort1 != null
      ? "_$titleShort1"
      : "";
  return "$prefix${paramValue["title"]}$suffix";
}

/// extracts a SailerValue from a given param
SailerValue sailerValue(VCDParamValue param) {
  final key = sailerKey(param);
  switch (param["parameter_type"]) {
    case "bit":
      {
        final value = (param["value"] == "1");
        return SailerBitValue(key, value);
      }
    case "variable":
      final value = parsedNumberValue(param);
      final unit = param["unit"];
      return SailerVariableValue(key, value, unit);
    default:
      throw Exception(
        "Parameter_type ${param["parameter_type"]} wird nicht unterstützt.\n${jsoning(param)}",
      );
  }
}

/// calculates value from factor and original value.
///
num parsedNumberValue(VCDParamValue param) {
  final parsedFactor = double.parse(param["factor"]);
  final parsedOrgValue = int.parse(param["value"]);
  final result = parsedFactor * parsedOrgValue;
  return result;
}
