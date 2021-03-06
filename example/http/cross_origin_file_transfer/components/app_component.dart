// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:html';

import 'package:over_react/over_react.dart';

import '../services/proxy.dart' as proxy;
import 'download_page.dart';
import 'upload_page.dart';

/// Main application component.
///
/// Sets up the file drop zone, file upload, and file download components.
@Factory()
UiFactory<AppProps> App;

@Props()
class AppProps extends UiProps {}

@State()
class AppState extends UiState {
  AppPage page;
  bool isProxyEnabled;
}

@Component()
class AppComponent extends UiStatefulComponent<AppProps, AppState> {
  @override
  Map getInitialState() => newState()
    ..page = AppPage.upload
    ..isProxyEnabled = proxy.proxyEnabled;

  void _goToUploadPage(SyntheticMouseEvent event) {
    event.preventDefault();

    if (state.page != AppPage.upload) {
      setState(newState()..page = AppPage.upload);
    }
  }

  void _goToDownloadPage(SyntheticMouseEvent event) {
    event.preventDefault();

    if (state.page != AppPage.download) {
      setState(newState()..page = AppPage.download);
    }
  }

  void _toggleProxy(SyntheticFormEvent event) {
    CheckboxInputElement target = event.target;

    setState(newState()..isProxyEnabled = target.checked, () {
      proxy.toggleProxy(enabled: target.checked);
    });
  }

  @override
  dynamic render() {
    return (Dom.div()..addProps(copyUnconsumedDomProps()))(
      Dom.p()(
        (Dom.label()..htmlFor = 'proxy')(
          (Dom.input()
            ..id = 'proxy'
            ..type = 'checkbox'
            ..checked = state.isProxyEnabled
            ..onChange = _toggleProxy)(),
          ' Use Proxy Server',
        ),
      ),
      (Dom.div()..className = 'app-nav')(
        (Dom.a()
          ..href = '#'
          ..className = state.page == AppPage.upload ? 'active' : null
          ..onClick = _goToUploadPage)(
          'Upload',
        ),
        (Dom.a()
          ..href = '#'
          ..className = state.page == AppPage.download ? 'active' : null
          ..onClick = _goToDownloadPage)(
          'Download',
        ),
      ),
      (UploadPage()..isActive = state.page == AppPage.upload)(),
      (DownloadPage()..isActive = state.page == AppPage.download)(),
    );
  }
}

/// The possible values for [AppState.page].
enum AppPage {
  upload,
  download,
}
