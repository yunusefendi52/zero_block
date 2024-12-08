import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zero_block/components/tile_automation_test_widget.dart';
import 'package:zero_block/main.dart';
import 'package:zero_block/myapp_store.dart';
import 'package:zero_block/tile_item_container.dart';
import 'package:zero_block/tiles/tile_text.dart';
import 'package:zero_block/utils.dart';

class PlayerEnemy extends StatelessWidget {
  final double tileSize;
  final Player playerItem;
  final Color color;
  final Color borderColor;
  const PlayerEnemy({
    Key? key,
    required this.tileSize,
    required this.playerItem,
    required this.color,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DragTarget<Player>(
      builder: (
        context,
        accepted,
        rejected,
      ) {
        return TileAutomationTestWidget(
          player: playerItem,
          child: ValueListenableBuilder<int>(
            valueListenable: playerItem.lifetime,
            builder: (context, lifetime, child) {
              late final lifetimeString = lifetime.toString();
              late final lifetimeSize = tileSize * 100 / 400;

              return TileItemContainer(
                color: lifetime > 1 ? color.toLightness(0.325) : color,
                borderColor: borderColor,
                tileSize: tileSize,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      child: lifetime > 1
                          ? Container(
                              height: lifetimeSize,
                              width: lifetimeSize,
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: TileText(
                                lifetimeString,
                                style: getTextStyle(tileSize, 0.2).copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: playerItem.data,
                      builder: (context, data, child) {
                        final filteredData =
                            data.replaceAll('*', 'x').replaceAll('/', '÷');
                        return TileText(
                          filteredData,
                          style: getTextStyle(tileSize, textTileFontSize),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      onWillAccept: (dragData) {
        if (dragData == null) {
          return false;
        }

        final localPlayerItem = playerItem;

        if (dragData.id != localPlayerItem.id &&
            localPlayerItem.type.value != PlayerType.main) {
          final dragVector = dragData.vector.value;
          final possibleOffsets = [
            Offset(dragVector.dx + 1, dragVector.dy),
            Offset(dragVector.dx - 1, dragVector.dy),
            Offset(dragVector.dx, dragVector.dy + 1),
            Offset(dragVector.dx, dragVector.dy - 1),
          ];
          final canMove =
              possibleOffsets.contains(localPlayerItem.vector.value) &&
                  !dragData.isMainPlayerCompleted;
          if (kDebugMode) {
            print('can move $canMove');
          }
          if (canMove) {
            dragData.evaluatePlayer(localPlayerItem);
          }
        }
        return false;
      },
    );
  }
}
