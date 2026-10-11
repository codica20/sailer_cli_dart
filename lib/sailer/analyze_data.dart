import 'get_dashboard_source.dart' show VControllerData;

List<String> sailerKeys(VControllerData vControllerData) {
  final result = orgParams(vControllerData)
      .map((param) => sailerKey(param))
      .toList();
  return result..sort();
}

typedef VCDParamValue = dynamic;

List<VCDParamValue> orgParams(
  VControllerData vControllerData,
) {
  final Map<String, VCDParamValue> paramMap =
      vControllerData["_parameter"];
  final result = paramMap.values.toList();
  return result;
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
