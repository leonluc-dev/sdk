// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart = 2.7

import 'package:expect/expect.dart';

/*strong.class: Class1a:explicit=[Class1a],needsArgs*/
/*omit.class: Class1a:needsArgs*/
class Class1a<T> {
  Class1a();
}

/*strong.class: Class1b:needsArgs*/
/*omit.class: Class1b:needsArgs*/
class Class1b<T> extends Class1a<T> {
  Class1b();
}

/*strong.class: Class1c:needsArgs*/
/*omit.class: Class1c:needsArgs*/
class Class1c<T> extends Class1a<T> {
  Class1c();
}

/*strong.class: Class2:*/
/*omit.class: Class2:*/
class Class2<T> {
  Class2();
}

/*strong.member: test:*/
/*omit.member: test:*/
test(Class1a c, Type type) {
  return c.runtimeType == type;
}

/*strong.member: main:*/
/*omit.member: main:*/
main() {
  Expect.isTrue(test(new Class1a(), Class1a));
  Expect.isFalse(test(new Class1b<int>(), Class1a));
  Expect.isFalse(test(new Class1c<int>(), Class1a));
  new Class2<int>();
}
