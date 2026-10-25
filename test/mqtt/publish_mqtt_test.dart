import 'package:sailer_cli_dart/mqtt/publish_mqtt.dart';
import 'package:test/test.dart';

void main() {
  test('first test', () {
    bool myTrue = true;
    expect(myTrue, !false);
  });
  test("encode Raumtemperatur HK 1", () {
    const decoded = "Raumtemperatur HK 1";
    final encoded = encodeChars(decoded);
    expect(encoded, "raumtemperatur_hk_1");
  });
  test("encode Bärlauch", () {
    const decoded = "Bärlauch";
    final encoded = encodeChars(decoded);
    expect(encoded, "baerlauch");
  });
}
