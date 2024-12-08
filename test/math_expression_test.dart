import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'package:zero_block/math_expression/math_expression.dart';

void main() {
  test('Init tokenizer', () {
    final tokenizer = MathTokenizer('9 + 5');
    expect(tokenizer.token, Token.number);
    expect(tokenizer.number, 9);

    tokenizer.nextToken();
    expect(tokenizer.token, Token.add);
  });

  group('Can calculate left value and right value', () {
    final List<Tuple2<String, double>> exps = [
      const Tuple2('5+3', 8),
      const Tuple2('3 + 5', 8),
      const Tuple2('9 + 1', 10),
      const Tuple2('001 +23', 24),
      const Tuple2('23+   0', 23),
      const Tuple2('23.0+ 000.0', 23),
      const Tuple2('41-40', 1),
      const Tuple2('3-1', 2),
      const Tuple2('0-1', -1),
      const Tuple2('-1', -1),
      const Tuple2('+5', 5),
      const Tuple2('--5', 5),
      const Tuple2('--++-+-5', 5),
      const Tuple2('--++-+-5 + 5 + 10', 20),
      const Tuple2('10 - 5 +5', 10),
      const Tuple2('5/2', 2.5),
      const Tuple2('6 /2', 3),
      const Tuple2('10 /5', 2),
      const Tuple2('10 /5', 2),
      const Tuple2('12.0 /6.0000', 2),
      const Tuple2('+12.0 /6.0000', 2),
      const Tuple2('-12.0 /6.0000', -2),
      const Tuple2('-12.0 /-6.0000', 2),
      const Tuple2('12.0 /-6.0000', -2),
      const Tuple2('+12.0 /-6.0000', -2),
      const Tuple2('+12.0 --6.0000', 18),
      const Tuple2('-12.0 --6.0000', -6),
      const Tuple2('6/10', 0.6),
    ];
    final mathExp = MathExpression();
    for (var item in exps) {
      test(item, () {
        final result = mathExp.evaluate(item.item1);
        expect(result, item.item2);
      });
    }
  });
}
