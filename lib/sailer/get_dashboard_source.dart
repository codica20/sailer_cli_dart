import 'package:logging/logging.dart' show Logger;
import 'package:puppeteer/puppeteer.dart';

class GetDashboardSourceReturn(
  final VControllerData vControllerData,
  final String? content,
  final Browser browser,
);

typedef VControllerData = Map<String, dynamic>;

class SailerOptions({
  required final String sailerUser,
  required final String sailerPassword,
  final bool? headless,
  final String? sailerPortalUrl,
});
final log = Logger("get_dashboard_source");

Future<GetDashboardSourceReturn> getDashboardSource(
  SailerOptions options,
) async {
  // Why does object matching not work?
  final sailerUser = options.sailerUser;
  final sailerPassword = options.sailerPassword;
  final bool? headless = options.headless;
  final sailerPortalUrl = options.sailerPortalUrl;

  Browser browser = await puppeteer.launch(
    headless: headless ?? false,
  );
  try {
    final startUrl =
        sailerPortalUrl ??
        "https://sailer.remoteportal.de/";
    final page = await browser.newPage();
    await page.goto(startUrl);
    const cookieConfirmSelector = "::-p-text(Bestätigen)";
    await page.waitForSelector(cookieConfirmSelector);
    await page.locator(cookieConfirmSelector).click();
    await page
        .locator("input#formElement_login_username")
        .fill(sailerUser);
    await page
        .locator("input#formElement_login_password")
        .fill(sailerPassword);
    const submitSelector =
        "button.ibb-button ::-p-text(Anmelden)";
    await page.waitForSelector(submitSelector);
    //console.log("Waiting before clicking on submit...");
    await Future.delayed(Duration(milliseconds: 500));
    await page.locator(submitSelector).click();
    await page.waitForSelector(
      "::-p-text(Datenaufzeichnung)",
    );

    final String? content = await page.content;
    //print("Content: $content");
    final VControllerData vControllerData = await page
        .evaluate("vControllerData");
    return GetDashboardSourceReturn(
      vControllerData,
      content,
      browser,
    );
  } catch (e) {
    log.severe("Got exception in getDashboardSource: $e");
    log.info("Closing browser ...");
    await browser.close();
    rethrow;
  }
}
