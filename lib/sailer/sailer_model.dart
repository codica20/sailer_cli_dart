sealed class SailerValue(final String key) {
  Map<String, dynamic> toJson() => ({"key": key});
}

class SailerBitValue extends SailerValue {
  String get type => "bit";
  final bool value;

  new(super.key, this.value);

  @override
  Map<String, dynamic> toJson() {
    final result = super.toJson();
    result["type"] = type;
    result["value"] = value;
    return result;
  }
}

class SailerVariableValue extends SailerValue {
  String get type => "variable";
  final num value;
  final String? unit;

  new(super.key, this.value, this.unit);

  @override
  Map<String, dynamic> toJson() {
    final result = super.toJson();
    result["type"] = type;
    result["value"] = value;
    result["unit"] = unit;
    return result;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
