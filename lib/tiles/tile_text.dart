import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TileText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Key? textKey;
  const TileText(
    this.text, {
    Key? key,
    required this.style,
    this.textKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AutoSizeText(
        text,
        textKey: textKey,
        textAlign: TextAlign.center,
        style: style,
        maxLines: 1,
      ),
    );
  }
}
