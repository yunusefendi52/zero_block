import 'package:flutter/widgets.dart';
import 'package:zero_block/components/tile_automation_test_widget.dart';
import 'package:zero_block/main.dart';
import 'package:zero_block/myapp_store.dart';
import 'package:zero_block/tile_item_container.dart';
import 'package:zero_block/tiles/tile_text.dart';
import 'package:zero_block/utils.dart';

class PlayerMain extends StatelessWidget {
  final Player? playerItem;
  final AnimationController _scaleAnimiation;
  final double tileSize;

  const PlayerMain({
    Key? key,
    required this.playerItem,
    required AnimationController scaleAnimiation,
    required this.tileSize,
  })  : _scaleAnimiation = scaleAnimiation,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = MyAppStoreProvider.of(context).store;
    final child = TileItemContainer(
        // color: const Color(0xff543A26),
        // borderColor: const Color(0xff9B6D46),
        color: const Color(0xff664E4C),
        borderColor: const Color(0xffCCBAB8),
        tileSize: tileSize,
        child: TileAutomationTestWidget(
          player: playerItem!,
          child: ValueListenableBuilder<String>(
            valueListenable: playerItem!.data,
            builder: (context, data, child) {
              return TileText(
                data,
                style: getTextStyle(tileSize, textTileFontSize),
              );
            },
          ),
        ));
    return ValueListenableBuilder<bool>(
      valueListenable: store.editMode,
      builder: (context, data, child) {
        return data
            ? child!
            : Draggable<Player>(
                data: playerItem,
                feedback: const SizedBox(),
                onDragStarted: () {
                  if (store.firstTimeMove) {
                    store.firstTimeMove = false;
                    store.startTimer();
                  }
                  _scaleAnimiation.forward();
                },
                onDragEnd: (_) {
                  _scaleAnimiation.reverse();
                },
                child: child!,
              );
      },
      child: child,
    );
  }
}
