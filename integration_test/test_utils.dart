import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuple/tuple.dart';

extension TesterExt on WidgetTester {
  Future dragFromTo(Offset a, Offset b) async {
    final aPoint = a;
    final bPoint = b - a;
    final duration = (bPoint.dx.abs() + bPoint.dy.abs()) * 9.5;
    // print('duration: (x:${bPoint.dx},y:${bPoint.dy}) $duration');
    await timedDragFrom(
        aPoint,
        bPoint,
        Duration(
          milliseconds: duration.toInt(),
        ));
  }

  Future dragFromTo2(
    List<Tuple2<Offset, Offset>> tuplePoints, {
    Duration duration = const Duration(seconds: 3),
  }) async {
    for (var item in tuplePoints) {
      await dragFromTo(
        item.item1,
        item.item2,
      );
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }

  Future closeFinished() async {
    await pumpAndSettle();
    await Future.delayed(const Duration(milliseconds: 500));
    await tap(find.byKey(const Key('close-finished')));
    await Future.delayed(const Duration(milliseconds: 500));
    await pumpAndSettle();
  }
}

extension FutureExt on List<Future<dynamic>> {
  Future seq() async {
    for (var item in this) {
      await item;
    }
  }
}
