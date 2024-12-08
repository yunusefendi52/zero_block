import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:zero_block/math_expression/math_expression.dart';
import 'package:zero_block/myapp_store.dart';

class PlayerTileModel extends Tuple2<String, PlayerType> {
  const PlayerTileModel(String item1, PlayerType item2) : super(item1, item2);
}

class TilePickerStore extends ChangeNotifier
    implements ValueListenable<TilePickerStore> {
  late var tiles = [
    const PlayerTileModel('PLAYER', PlayerType.main),
    const PlayerTileModel('SUBTRACT', PlayerType.subtraction),
    const PlayerTileModel('ADD', PlayerType.addition),
    const PlayerTileModel('MULTIPLY', PlayerType.playerMultiple),
    const PlayerTileModel('DIVIDE', PlayerType.playerDivide),
  ];

  PlayerTileModel? _selectedTile;
  PlayerTileModel? get selectedTile => _selectedTile;
  set selectedTile(PlayerTileModel? value) {
    _selectedTile = value;
    notifyListeners();
  }

  late String data;

  String? lifetime;

  @override
  get value => this;
}

class TilePicker extends StatefulWidget {
  final TilePickerStore store;
  const TilePicker({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  _TilePickerState createState() => _TilePickerState();
}

class _TilePickerState extends State<TilePicker> {
  TilePickerStore get store => widget.store;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TilePickerStore>(
      valueListenable: store,
      builder: (context, store, child) {
        return AlertDialog(
          title: const Text('TILE PICKER'),
          actions: [
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                if (!kDebugMode) {
                  final mathExp = MathExpression();
                  store.data = mathExp.evaluate(store.data).toString();
                }
                Navigator.of(context).pop(store);
              },
            ),
          ],
          contentPadding: const EdgeInsets.all(0),
          content: Padding(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<PlayerTileModel>(
                    isExpanded: true,
                    value: store.selectedTile,
                    hint: const Text('Pick Tile Type'),
                    onChanged: (newValue) {
                      store.selectedTile = newValue;
                    },
                    items: store.tiles.map(
                      (value) {
                        return DropdownMenuItem<PlayerTileModel>(
                          value: value,
                          child: Text(
                            value.item1,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  Wrap(
                    spacing: 10,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter your number',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    onChanged: (v) {
                      store.data = v;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                    ],
                  ),
                  Wrap(
                    spacing: 10,
                  ),
                  if (store.selectedTile?.item2 != PlayerType.main)
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Lifetime',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      onChanged: (v) {
                        store.lifetime = v;
                      },
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
