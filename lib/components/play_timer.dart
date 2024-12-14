import 'package:flutter/material.dart';
import 'package:zero_block/main.dart';

class PlayTimer extends StatefulWidget {
  const PlayTimer({Key? key}) : super(key: key);

  @override
  _PlayTimerState createState() => _PlayTimerState();
}

class _PlayTimerState extends State<PlayTimer> {
  @override
  Widget build(BuildContext context) {
    late final store = MyAppStoreProvider.of(context).store;
    return ValueListenableBuilder<Duration>(
      valueListenable: store.duration,
      builder: (
        context,
        data,
        child,
      ) {
        final hours = data.inHours % 24;
        final minutes = data.inMinutes % 60;
        final seconds = data.inSeconds % 60;
        final milliseconds = data.inMilliseconds % 1000;
        final readable =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}';
        return Text(
          readable,
          style: const TextStyle(
            fontSize: 22,
          ),
        );
      },
    );
  }
}
