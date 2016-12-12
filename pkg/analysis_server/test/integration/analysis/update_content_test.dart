// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analysis_server/plugin/protocol/protocol.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../integration_tests.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UpdateContentTest);
    defineReflectiveTests(UpdateContentTest_Driver);
  });
}

class AbstractUpdateContentTest extends AbstractAnalysisServerIntegrationTest {
  test_updateContent() {
    String pathname = sourcePath('test.dart');
    String goodText = r'''
main() {
  print("Hello, world!");
}''';
    String badText = goodText.replaceAll(';', '');
    writeFile(pathname, badText);
    standardAnalysisSetup();
    return analysisFinished
        .then((_) {
          // The contents on disk (badText) are missing a semicolon.
          expect(currentAnalysisErrors[pathname], isNotEmpty);
        })
        .then((_) => sendAnalysisUpdateContent(
            {pathname: new AddContentOverlay(goodText)}))
        .then((result) => analysisFinished)
        .then((_) {
          // There should be no errors now because the contents on disk have been
          // overridden with goodText.
          expect(currentAnalysisErrors[pathname], isEmpty);
          return sendAnalysisUpdateContent({
            pathname: new ChangeContentOverlay(
                [new SourceEdit(goodText.indexOf(';'), 1, '')])
          });
        })
        .then((result) => analysisFinished)
        .then((_) {
          // There should be errors now because we've removed the semicolon.
          expect(currentAnalysisErrors[pathname], isNotEmpty);
          return sendAnalysisUpdateContent({
            pathname: new ChangeContentOverlay(
                [new SourceEdit(goodText.indexOf(';'), 0, ';')])
          });
        })
        .then((result) => analysisFinished)
        .then((_) {
          // There should be no errors now because we've added the semicolon back.
          expect(currentAnalysisErrors[pathname], isEmpty);
          return sendAnalysisUpdateContent(
              {pathname: new RemoveContentOverlay()});
        })
        .then((result) => analysisFinished)
        .then((_) {
          // Now there should be errors again, because the contents on disk are no
          // longer overridden.
          expect(currentAnalysisErrors[pathname], isNotEmpty);
        });
  }
}

@reflectiveTest
class UpdateContentTest extends AbstractUpdateContentTest {}

@reflectiveTest
class UpdateContentTest_Driver extends AbstractUpdateContentTest {
  @override
  bool get enableNewAnalysisDriver => true;

  @failingTest
  test_updateContent() {
    //  Expected: non-empty
    //    Actual: []
    return super.test_updateContent();
  }
}
