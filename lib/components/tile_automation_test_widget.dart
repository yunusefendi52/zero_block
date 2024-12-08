import 'package:flutter/material.dart';
import 'package:zero_block/myapp_store.dart';

class TileAutomationTestWidget extends StatelessWidget {
  final Player player;
  final Widget child;
  const TileAutomationTestWidget({
    Key? key,
    required this.player,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: player.automationKey,
      child: child,
    );
  }
}
