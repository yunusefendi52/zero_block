import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';
import 'package:zero_block/main.dart' as app;

import 'test_utils.dart';

void main() {
  // IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences.setMockInitialValues({});
  
  testWidgets('Level 1', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();
    final a1 = tester.getCenter(find.byKey(const Key('tile-0-5')));
    final a2 = tester.getCenter(find.byKey(const Key('tile-4-5')));
    final a3 = tester.getCenter(find.byKey(const Key('tile-5-4')));
    final a4 = tester.getCenter(find.byKey(const Key('tile-5-1')));
    final a5 = tester.getCenter(find.byKey(const Key('tile-5-1')));
    final a6 = tester.getCenter(find.byKey(const Key('tile-4-1')));
    await tester.dragFromTo(
      a1,
      a2,
    );
    await tester.dragFromTo(
      a3,
      a4,
    );
    await tester.dragFromTo(
      a5,
      a6,
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('Level 2', (WidgetTester tester) async {
    await app.main(
      levelId: '2',
    );
    await tester.pumpAndSettle();
    await tester.dragFromTo2(
      [
        // First part
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
          tester.getCenter(find.byKey(const Key('tile-3-4'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-4'))),
          tester.getCenter(find.byKey(const Key('tile-5-4'))),
        ),
        // Seconds part
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-6-1'))),
          tester.getCenter(find.byKey(const Key('tile-5-1'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-5-1'))),
          tester.getCenter(find.byKey(const Key('tile-5-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-5-3'))),
          tester.getCenter(find.byKey(const Key('tile-4-3'))),
        ),
      ],
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('Level 3', (WidgetTester tester) async {
    await app.main(
      levelId: '3',
    );
    await tester.pumpAndSettle();
    await tester.dragFromTo2(
      [
        // 1
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-4'))),
          tester.getCenter(find.byKey(const Key('tile-2-1'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-1'))),
          tester.getCenter(find.byKey(const Key('tile-3-1'))),
        ),
        // 2
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-1'))),
          tester.getCenter(find.byKey(const Key('tile-4-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-3'))),
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-3'))),
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
        ),
      ],
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('Level 4', (WidgetTester tester) async {
    await app.main(
      levelId: '4',
    );
    await tester.pumpAndSettle();
    await tester.dragFromTo2(
      [
        // 1
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-1-4'))),
          tester.getCenter(find.byKey(const Key('tile-1-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-1-3'))),
          tester.getCenter(find.byKey(const Key('tile-4-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-3'))),
          tester.getCenter(find.byKey(const Key('tile-4-4'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-4'))),
          tester.getCenter(find.byKey(const Key('tile-2-4'))),
        ),
        // 2
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-1'))),
          tester.getCenter(find.byKey(const Key('tile-4-1'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-1'))),
          tester.getCenter(find.byKey(const Key('tile-4-2'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-2'))),
          tester.getCenter(find.byKey(const Key('tile-1-2'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-1-2'))),
          tester.getCenter(find.byKey(const Key('tile-1-1'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-1-1'))),
          tester.getCenter(find.byKey(const Key('tile-2-1'))),
        ),
      ],
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(2));
  });

  testWidgets('Level 5', (WidgetTester tester) async {
    await app.main(
      levelId: '5',
    );
    await tester.pumpAndSettle();
    await tester.dragFromTo2(
      [
        // 1
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-1-1'))),
          tester.getCenter(find.byKey(const Key('tile-1-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-1-3'))),
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
        ),
        // 2
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-4'))),
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-2'))),
          tester.getCenter(find.byKey(const Key('tile-2-2'))),
        ),
        // 3
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-3-1'))),
          tester.getCenter(find.byKey(const Key('tile-4-1'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-1'))),
          tester.getCenter(find.byKey(const Key('tile-4-2'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-2'))),
          tester.getCenter(find.byKey(const Key('tile-5-2'))),
        ),
      ],
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(3));
  });

  testWidgets('Level 6', (WidgetTester tester) async {
    await app.main(
      levelId: '6',
    );
    await tester.pumpAndSettle();
    await tester.dragFromTo2(
      [
        // 1
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-2-1'))),
          tester.getCenter(find.byKey(const Key('tile-2-4'))),
        ),
        // 2
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-1'))),
          tester.getCenter(find.byKey(const Key('tile-4-3'))),
        ),
        Tuple2(
          tester.getCenter(find.byKey(const Key('tile-4-3'))),
          tester.getCenter(find.byKey(const Key('tile-2-3'))),
        ),
      ],
    );
    await tester.closeFinished();
    expect(find.text('0'), findsNWidgets(2));
  });
}
