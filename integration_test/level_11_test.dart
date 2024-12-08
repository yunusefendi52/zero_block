import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'package:zero_block/main.dart' as app;

import 'test_utils.dart';

void main() {
  testWidgets('Level 11', (WidgetTester tester) async {
    await app.main(
      levelId: '11',
    );
    await tester.pumpAndSettle();
    await tester.dragFromTo2(
      [
        // 1
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-1-2'))),
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
          tester.getCenter(find.byKey(const Key('tile-2-2'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-2'))),
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
        ),
        // 2
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-1-3'))),
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
          tester.getCenter(find.byKey(const Key('tile-5-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-5-3'))),
          tester.getCenter(find.byKey(const Key('tile-5-2'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-5-2'))),
          tester.getCenter(find.byKey(const Key('tile-4-2'))),
        ),
      ],
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(2));
  });
}
