import 'package:puppeteer/puppeteer.dart';
import 'package:args/command_runner.dart' show Command;

class ListKeysCommand extends Command {
  @override
  final name = "list-keys";
  @override
  final description = "Zeige Wertenamen von SAILER Master";

  // [run] may also return a Future.
  @override
  void run() async {
    print("checke ...");
    try {
      Browser browser = await puppeteer.launch(
        headless: false,
      );

      // Open a new tab
      var myPage = await browser.newPage();

      // Go to a page and wait to be fully loaded
      await myPage.goto(
        'https://pub.dev/documentation/puppeteer/latest',
        wait: Until.networkIdle,
      );

      String title = await myPage.evaluate<String>(
        '() => document.title',
      );

      print("Title: $title");

      // Gracefully close the browser's process
      await browser.close();
    } catch (e) {
      print("FEHLER beim Auflisten der Wertenamen: $e");
    }
  }
}
