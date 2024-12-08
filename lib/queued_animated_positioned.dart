import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

class QueuedAnimatedPositioned extends StatefulWidget {
  final Tuple2<double, double> offsets;
  final Widget child;
  final void Function()? onEnd;
  const QueuedAnimatedPositioned({
    Key? key,
    required this.child,
    required this.offsets,
    this.onEnd,
  }) : super(key: key);

  @override
  _QueuedAnimatedPositionedState createState() =>
      _QueuedAnimatedPositionedState();
}

class _QueuedAnimatedPositionedState extends State<QueuedAnimatedPositioned> {
  List<Tuple2<double, double>> queuedOffsets = [];
  late Tuple2<double, double> currentOffset;

  bool isAnimating = false;

  @override
  void initState() {
    super.initState();

    currentOffset = widget.offsets;
  }

  @override
  void didUpdateWidget(covariant QueuedAnimatedPositioned oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.offsets != widget.offsets) {
      queuedOffsets = List.from(queuedOffsets)..add(widget.offsets);
      if (!isAnimating) {
        isAnimating = true;
        setState(() {
          currentOffset = queuedOffsets.first;
        });
        queuedOffsets.remove(currentOffset);
      }
      if (kDebugMode) {
        print('didUpdateWidget ${queuedOffsets.length}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastItem = currentOffset;
    return AnimatedPositioned(
      child: widget.child,
      duration: const Duration(
        milliseconds: 125,
      ),
      curve: Curves.linear,
      bottom: lastItem.item1,
      left: lastItem.item2,
      onEnd: () {
        isAnimating = false;
        widget.onEnd?.call();
        if (queuedOffsets.isNotEmpty) {
          if (kDebugMode) {
            print(
                'end with condition, before remove queued ${queuedOffsets.length}');
          }
          final queuedItem = queuedOffsets.first;
          setState(() {
            currentOffset = Tuple2(queuedItem.item1, queuedItem.item2);
          });
          queuedOffsets.remove(currentOffset);
          if (kDebugMode) {
            print('end with condition, current queued ${queuedOffsets.length}');
          }
        }
      },
    );
  }
}
