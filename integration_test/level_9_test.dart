import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';
import 'package:zero_block/main.dart' as app;

import 'test_utils.dart';

void main() {
  testWidgets('Level 9', (WidgetTester tester) async {
    await app.main(
      levelId: '9',
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
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
          tester.getCenter(find.byKey(const Key('tile-4-3'))),
        ),
        // 2
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-1'))),
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
        ),  
        // 3
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-4'))),
          tester.getCenter(find.byKey(const Key('tile-2-4'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-4'))),
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
          tester.getCenter(find.byKey(const Key('tile-1-3'))),
        ),
      ],
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(3));
  });
}
