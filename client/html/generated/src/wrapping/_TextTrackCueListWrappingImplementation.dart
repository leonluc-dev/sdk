// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.

class TextTrackCueListWrappingImplementation extends DOMWrapperBase implements TextTrackCueList {
  TextTrackCueListWrappingImplementation._wrap(ptr) : super._wrap(ptr) {}

  int get length() { return _ptr.length; }

  TextTrackCue getCueById(String id) {
    return LevelDom.wrapTextTrackCue(_ptr.getCueById(id));
  }

  TextTrackCue item(int index) {
    return LevelDom.wrapTextTrackCue(_ptr.item(index));
  }
}
