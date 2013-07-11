// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:unittest/unittest.dart';

import 'package:analyzer_experimental/src/generated/ast.dart';
import 'package:analyzer_experimental/src/generated/scanner.dart';
import 'package:analyzer_experimental/src/services/formatter.dart';
import 'package:analyzer_experimental/src/services/formatter_impl.dart';
import 'package:analyzer_experimental/src/services/writer.dart';

main() {

  /// Formatter tests
  group('formatter', () {

    test('failed parse', () {
      var formatter = new CodeFormatter();
      expect(() => formatter.format(CodeKind.COMPILATION_UNIT, '~'),
                   throwsA(new isInstanceOf<FormatterException>()));
    });

    test('CU (1)', () {
      expectCUFormatsTo(
          'class A  {\n'
          '}',
          'class A {\n'
          '}'
        );
    });

    test('CU (2)', () {
      expectCUFormatsTo(
          'class      A  {  \n'
          '}',
          'class A {\n'
          '}'
        );
    });

    test('CU (3)', () {
      expectCUFormatsTo(
          'class A {\n'
          '  }',
          'class A {\n'
          '}'
        );
    });

    test('CU (4)', () {
      expectCUFormatsTo(
          ' class A {\n'
          '}',
          'class A {\n'
          '}'
        );
    });

    test('CU (method indent)', () {
      expectCUFormatsTo(
          'class A {\n'
          'void x(){\n'
          '}\n'
          '}',
          'class A {\n'
          '  void x() {\n'
          '  }\n'
          '}'
        );
    });

    test('CU (method indent - 2)', () {
      expectCUFormatsTo(
          'class A {\n'
          ' static  bool x(){ return true; }\n'
          ' }',
          'class A {\n'
          '  static bool x() {\n'
          '    return true;\n'
          '  }\n'
          '}'
        );
    });

    test('CU (method indent - 3)', () {
      expectCUFormatsTo(
          'class A {\n'
          ' int x() =>   42   + 3 ;  \n'
          '   }',
          'class A {\n'
          '  int x() => 42 + 3;\n'
          '}'
        );
    });

    test('CU (method indent - 4)', () {
      expectCUFormatsTo(
          'class A {\n'
          ' int x() { \n'
          'if (true) {return 42;\n'
          '} else { return false; }\n'
          '   }'
          '}',
          'class A {\n'
          '  int x() {\n'
          '    if (true) {\n'
          '      return 42;\n'
          '    } else {\n'
          '      return false;\n'
          '    }\n'
          '  }\n'
          '}'
        );
    });

    test('stmt', () {
      expectStmtFormatsTo(
         'if (true){\n'
         'if (true){\n'
         'if (true){\n'
         'return true;\n'
         '} else{\n'
         'return false;\n'
         '}\n'
         '}\n'
         '}else{\n'
         'return false;\n'
         '}',
         'if (true) {\n'
         '  if (true) {\n'
         '    if (true) {\n'
         '      return true;\n'
         '    } else {\n'
         '      return false;\n'
         '    }\n'
         '  }\n'
         '} else {\n'
         '  return false;\n'
         '}'
        );
    });


    test('initialIndent', () {
      var formatter = new CodeFormatter(
          new FormatterOptions(initialIndentationLevel: 2));
      var formattedSource = formatter.format(CodeKind.STATEMENT, 'var x;');
      expect(formattedSource, startsWith('    '));
    });

  });


  /// Line tests
  group('line', () {

    test('space', () {
      var line = new Line(indent: 0);
      line.addSpaces(2);
      expect(line.toString(), equals('  '));
    });

    test('initial indent', () {
      var line = new Line(indent: 2);
      expect(line.toString(), equals('    '));
    });

    test('initial indent (tabbed)', () {
      var line = new Line(indent:1, useTabs: true);
      expect(line.toString(), equals('\t'));
    });

    test('addToken', () {
      var line = new Line();
      line.addToken(new LineToken('foo'));
      expect(line.toString(), equals('foo'));
    });

    test('addToken (2)', () {
      var line = new Line(indent: 1);
      line.addToken(new LineToken('foo'));
      expect(line.toString(), equals('  foo'));
    });

  });


  /// Writer tests
  group('writer', () {

    test('basic print', () {
      var writer = new SourceWriter();
      writer.print('foo');
      writer.print(' ');
      writer.print('bar');
      expect(writer.toString(), equals('foo bar'));
    });

    test('newline', () {
      var writer = new SourceWriter();
      writer.print('foo');
      writer.newline();
      expect(writer.toString(), equals('foo\n'));
    });

    test('basic print (with indents)', () {
      var writer = new SourceWriter();
      writer.print('foo');
      writer.indent();
      writer.newline();
      writer.print('bar');
      writer.unindent();
      writer.newline();
      writer.print('baz');
      expect(writer.toString(), equals('foo\n  bar\nbaz'));
    });

  });


  /// Helper method tests
  group('helpers', () {

    test('indentString', () {
      expect(getIndentString(0), '');
      expect(getIndentString(1), ' ');
      expect(getIndentString(4), '    ');
    });

    test('indentString (tabbed)', () {
      expect(getIndentString(0, useTabs: true), '');
      expect(getIndentString(1, useTabs: true), '\t');
      expect(getIndentString(3, useTabs: true), '\t\t\t');
    });

    test('repeat', () {
      expect(repeat('x', 0), '');
      expect(repeat('x', 1), 'x');
      expect(repeat('x', 4), 'xxxx');
    });

  });

}

Token classKeyword(int offset) =>
    new KeywordToken(Keyword.CLASS, offset);

Token identifier(String value, int offset) =>
    new StringToken(TokenType.IDENTIFIER, value, offset);

Token openParen(int offset) =>
    new StringToken(TokenType.OPEN_PAREN, '{', offset);

Token closeParen(int offset) =>
    new StringToken(TokenType.CLOSE_PAREN, '}', offset);

Token chain(List<Token> tokens) {
  for (var i = 0; i < tokens.length - 1; ++i) {
    tokens[i].setNext(tokens[i + 1]);
  }
  return tokens[0];
}

String formatCU(src, {options: const FormatterOptions()}) =>
    new CodeFormatter(options).format(CodeKind.COMPILATION_UNIT, src);

String formatStatement(src, {options: const FormatterOptions()}) =>
    new CodeFormatter(options).format(CodeKind.STATEMENT, src);

expectCUFormatsTo(src, expected) => expect(formatCU(src), equals(expected));

expectStmtFormatsTo(src, expected) => expect(formatStatement(src),
    equals(expected));
