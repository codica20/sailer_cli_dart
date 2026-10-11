import 'package:puppeteer/puppeteer.dart';

class GetDashboardSourceReturn(
  final VControllerData vControllerData,
  final String? content,
  final Browser browser,
);

typedef VControllerData = Map<String, dynamic>;

Future<GetDashboardSourceReturn> getDashboardSource({
  required String sailerUser,
  required String sailerPassword,
  bool? headless,
  String? sailerPortalUrl,
}) async {
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
    print("Got exception in getDashboardSource: $e");
//    print("Closing browser ...");
//    await browser.close();
    rethrow;
  }
}
