@TestOn('browser')
library w_transport.test.integration.http.http_static.browser_test;

import 'package:test/test.dart';
import 'package:w_transport/w_transport_browser.dart';

import '../../../naming.dart';
import '../integration_config.dart';
import 'suite.dart';

void main() {
  var config = new HttpIntegrationConfig.browser();
  group(integrationHttpBrowser, () {
    setUp(() {
      configureWTransportForBrowser();
    });

    runHttpStaticSuite(config);
  });
}