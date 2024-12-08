import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class FireworkCompletedWidget extends StatefulWidget {
  final Widget child;
  final void Function()? onEnd;
  const FireworkCompletedWidget({
    Key? key,
    required this.child,
    this.onEnd,
  }) : super(key: key);

  @override
  _FireworCompletedWidgetState createState() => _FireworCompletedWidgetState();
}

class _FireworCompletedWidgetState extends State<FireworkCompletedWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);

  @override
  void initState() {
    super.initState();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onEnd?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.85,
      child: Lottie.asset(
        // 'assets/animations/3009_sparkles.json',
        'assets/animations/16627_firework.json',
        // 'assets/animations/79108_fireworks_01.json', ahh yes/no
        // 'assets/animations/83980_fireworkc.json',
        controller: _controller,
        onLoaded: (composition) {
          _controller
            ..duration = composition.duration
            ..forward();
        },
      ),
    );
  }
}
