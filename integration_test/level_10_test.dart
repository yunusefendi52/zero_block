import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'package:zero_block/main.dart' as app;

import 'test_utils.dart';

void main() {
  testWidgets('Level 10', (WidgetTester tester) async {
    await app.main(
      levelId: '10',
    );
    await tester.pumpAndSettle();
    await tester.dragFromTo2(
      [
        // 1
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-0-4'))),
          tester.getCenter(find.byKey(const Key('tile-3-4'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-4'))),
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
          tester.getCenter(find.byKey(const Key('tile-6-2'))),
        ),
      ],
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(1));
  });
}
