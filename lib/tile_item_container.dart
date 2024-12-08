import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:zero_block/utils.dart';

class _AnimatedScaleInitOneTime extends StatefulWidget {
  final Widget child;
  const _AnimatedScaleInitOneTime({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  __AnimatedScaleInitOneTimeState createState() =>
      __AnimatedScaleInitOneTimeState();
}

class __AnimatedScaleInitOneTimeState extends State<_AnimatedScaleInitOneTime> {
  double _scale = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      setState(() {
        _scale = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 350),
      child: widget.child,
    );
  }
}

class TileItemContainer extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final Widget child;
  final double tileSize;
  const TileItemContainer({
    Key? key,
    required this.child,
    required this.color,
    required this.borderColor,
    required this.tileSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.all(
      Radius.circular(tileSize / 6),
    );
    return _AnimatedScaleInitOneTime(
      child: Container(
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: borderRadius,
        ),
        padding: EdgeInsets.all(tileSize / 12.5),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
