import 'package:flutter/material.dart';
import 'package:quiver/strings.dart' as s;

class MathExpression {
  final _mathOperator = RegExp(r'[\+\-\/\*]');

  late final Map<String, double> _cachedResults = {};

  static double normalizeParseDouble(String value) {
    late final isNegativeValue = value.startsWith('-');
    late final isPositiveValue = value.startsWith('+');
    if (isNegativeValue || isPositiveValue) {
      value = value.substring(1);
    }
    return isNegativeValue ? -double.parse(value) : double.parse(value);
  }

  // It's a simple parser, no need to go any further (creating parse,tokenizer,etc) than this at least for now
  double evaluate(
    String expression, {
    bool cache = false,
  }) {
    if (cache) {
      if (_cachedResults.containsKey(expression)) {
        final cachedResult = _cachedResults[expression];
        return cachedResult!;
      }
    }

    final parser = Parse(MathTokenizer(expression));
    final resultNode = parser.parseExpression();
    final result = resultNode.eval();
    if (cache) {
      _cachedResults.putIfAbsent(
        expression,
        () => result,
      );
      if (_cachedResults.length > 50) {
        _cachedResults.remove(
          _cachedResults.keys.first,
        );
      }
    }
    return result;
  }
}

abstract class BaseNode {
  double eval();
}

class MathDoubleNode implements BaseNode {
  final double number;
  MathDoubleNode(this.number);

  @override
  double eval() {
    return number;
  }
}

class MathNodeBinary implements BaseNode {
  final BaseNode leftValue;
  final BaseNode rightValue;
  final double Function(double leftValue, double rightValue) op;

  MathNodeBinary(this.leftValue, this.rightValue, this.op);

  @override
  double eval() {
    final result = op(leftValue.eval(), rightValue.eval());
    return result;
  }
}

enum Token {
  eof,
  add,
  subtract,
  number,
  multiply,
  divide,
}

class MathTokenizer {
  MathTokenizer(String expString) {
    exp = expString.split('').iterator;
    nextChar();
    nextToken();
  }

  late final Iterator<String> exp;
  String _currentString = '';
  int get _currentChar {
    return _currentString.runes.first;
  }

  Token _currentToken = Token.eof;
  double _number = 0;

  Token get token {
    return _currentToken;
  }

  double get number {
    return _number;
  }

  void nextChar() {
    try {
      exp.moveNext();
      final currentChar = exp.current;
      _currentString = currentChar.isEmpty ? '\\0' : currentChar;
    } catch (e) {
      _currentString = '\\0';
    }
  }

  void nextToken() {
    while (s.isWhitespace(_currentChar)) {
      nextChar();
    }

    switch (_currentString) {
      case '\\0':
        nextChar();
        _currentToken = Token.eof;
        return;
      case '+':
        nextChar();
        _currentToken = Token.add;
        return;
      case '-':
        nextChar();
        _currentToken = Token.subtract;
        return;
      case '*':
        nextChar();
        _currentToken = Token.multiply;
        return;
      case '/':
        nextChar();
        _currentToken = Token.divide;
        return;
    }

    if (s.isDigit(_currentChar) || _currentString == '.') {
      final List<String> listString = [];
      bool haveDecimalPoint = false;
      while (s.isDigit(_currentChar) ||
          (!haveDecimalPoint && _currentString == '.')) {
        listString.add(_currentString);
        haveDecimalPoint = _currentString == '.';
        nextChar();
      }

      final numberString = listString.join('');
      _number = double.parse(numberString);
      _currentToken = Token.number;
      return;
    }

    throw Error();
  }
}

class Parse {
  Parse(this.tokenizer);

  final MathTokenizer tokenizer;

  BaseNode parseExpression() {
    final node = parseAddSubtract();

    if (tokenizer.token != Token.eof) {
      throw StateError('parseExpression error');
    }

    return node;
  }

  BaseNode parseAddSubtract() {
    var lhs = parseMultipyDivide();

    while (true) {
      double Function(double leftValue, double rightValue)? op;
      if (tokenizer.token == Token.add) {
        op = (v1, v2) => v1 + v2;
      } else if (tokenizer.token == Token.subtract) {
        op = (v1, v2) => v1 - v2;
      }

      if (op == null) {
        return lhs;
      }

      tokenizer.nextToken();

      final rhs = parseMultipyDivide();

      lhs = MathNodeBinary(lhs, rhs, op);
    }
  }

  BaseNode parseMultipyDivide() {
    var lhs = parseUnary();

    while (true) {
      double Function(double leftValue, double rightValue)? op;
      if (tokenizer.token == Token.multiply) {
        op = (v1, v2) => v1 * v2;
      } else if (tokenizer.token == Token.divide) {
        op = (v1, v2) => v1 / v2;
      }

      if (op == null) {
        return lhs;
      }

      tokenizer.nextToken();

      final rhs = parseUnary();

      lhs = MathNodeBinary(lhs, rhs, op);
    }
  }

  BaseNode parseUnary() {
    if (tokenizer.token == Token.add) {
      tokenizer.nextToken();
      return parseUnary();
    }

    if (tokenizer.token == Token.subtract) {
      tokenizer.nextToken();

      final rhs = parseUnary();

      return NodeUnary(rhs, (v) => -v);
    }

    return parseLeaf();
  }

  BaseNode parseLeaf() {
    if (tokenizer.token == Token.number) {
      final node = MathDoubleNode(tokenizer.number);
      tokenizer.nextToken();
      return node;
    }

    throw StateError('Unexpected token ${tokenizer.token}');
  }
}

class NodeUnary implements BaseNode {
  NodeUnary(this.rhs, this.op);

  final BaseNode rhs;
  final double Function(double rhs) op;

  @override
  double eval() {
    final rhsValue = rhs.eval();

    final result = op(rhsValue);
    return result;
  }
}
