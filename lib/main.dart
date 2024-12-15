import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';
import 'package:responsive_layout_builder/responsive_layout_builder.dart';
import 'package:tuple/tuple.dart';
import 'package:zero_block/components/play_timer.dart';
import 'package:zero_block/firework_completed_widget.dart';
import 'package:zero_block/firework_move_widget.dart';
import 'package:zero_block/pages/levels_page.dart';
import 'package:zero_block/player_main.dart';
import 'package:zero_block/queued_animated_positioned.dart';
import 'package:zero_block/tile_item_container.dart';
import 'package:zero_block/tile_picker.dart';
import 'package:zero_block/tiles/player_enemy.dart';
import 'package:zero_block/utils.dart';
import 'package:zero_block/utils/utils.dart';

import 'myapp_store.dart';

TextStyle getTextStyle(double tileSize, double fontSize) {
  return TextStyle(
    fontSize: fontSize * tileSize,
  );
}

const textTileFontSize = 0.365;
// Or as another workaround maybe show the occupied type after onEnd animation? I don't know
const usePlayerAnimated = true;

Future main({
  String? levelId,
}) async {
  Future.delayed(const Duration(seconds: 1)).then((value) async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  });
  WidgetsFlutterBinding.ensureInitialized();
  // await SystemChrome.setPreferredOrientations(
  //   [DeviceOrientation.landscapeLeft],
  // );
  // await SystemChrome.setEnabledSystemUIMode(
  //   SystemUiMode.immersiveSticky,
  // );
  runApp(
    MyApp(
      levelId: levelId,
    ),
  );
}

class RouteData {
  late BuildContext context;
  late RouteSettings settings;
  late Uri uri;
}

final Map<String, Widget Function(RouteData)> _routes = {
  '/': (data) {
    final edit = data.uri.queryParameters['edit'] == '1';
    final levelId = data.uri.queryParameters['level'] ?? (edit ? '' : '1');
    final customLevel = data.uri.queryParameters['customLevel'] ?? '';
    return MyHomePage(
      edit: edit,
      levelId: levelId,
      customLevelId: customLevel,
    );
  }
};

class MyApp extends StatelessWidget {
  final String? levelId;
  const MyApp({
    Key? key,
    this.levelId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero Block',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color.fromRGBO(60, 64, 67, 1),
        primarySwatch: Colors.blue,
        fontFamily: 'Jua',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final String routeName;
        if (levelId != null) {
          routeName = '${settings.name}?level=$levelId';
        } else {
          routeName = settings.name!;
        }
        final uri = Uri.parse(routeName);

        if (kDebugMode) {
          print(settings.name);
        }

        return MaterialPageRoute(
          builder: (context) {
            final routeName = uri.path;
            final route = _routes.containsKey(routeName)
                ? _routes[routeName]
                : _routes['/'];
            final page = route!(
              RouteData()
                ..context = context
                ..settings = settings
                ..uri = uri,
            );
            return page;
          },
          settings: settings,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool edit;
  final String levelId;
  final String customLevelId;
  const MyHomePage({
    Key? key,
    required this.levelId,
    this.customLevelId = '',
    this.edit = false,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MyAppStoreProvider extends InheritedWidget {
  final MyAppStore store;
  const MyAppStoreProvider(
      {Key? key, required Widget child, required this.store})
      : super(key: key, child: child);
  Widget build(BuildContext context) => child;

  static MyAppStoreProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyAppStoreProvider>()!;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final _store = MyAppStore();
  late final TextEditingController? nameController;

  @override
  void initState() {
    super.initState();

    if (widget.edit) {
      final now = DateTime.now();
      _store.name.value =
          'custom levels ${now.year}_${now.month}_${now.day}_${now.hour}_${now.minute}_${now.second}';
      nameController = TextEditingController.fromValue(
        TextEditingValue(text: _store.name.value),
      );
    } else {
      nameController = TextEditingController();
    }

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final shareLevel = getPlayShareLevel();
      _store.levelId = widget.levelId;
      _store.customLevel = widget.customLevelId;
      _store.editMode.value = widget.edit;
      _store.shareLevel = shareLevel;
      removePlayShareLevel();
      _store.reset(widget.edit).then((_) {
        if (widget.edit) {
          nameController!.text = _store.name.value;
        }
      });
    });
  }

  @override
  void dispose() {
    nameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final mainTiles = AspectRatio(
      aspectRatio: 1,
      child: ValueListenableBuilder<List<Player>>(
        valueListenable: _store.players,
        builder: (context, data, child) {
          if (data.isEmpty) {
            return const SizedBox();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final layoutWidth = constraints.maxWidth;
              final layoutHeight = constraints.maxHeight;
              const columnCount = 7;
              const rowCount = 7;
              final tileSize = layoutWidth / rowCount;

              final yMargin = (layoutHeight - (columnCount * tileSize)) / 2;
              final xMargin = (layoutWidth - (rowCount * tileSize)) / 2;

              late final List<PlayerTile> playerWidgets = [];
              for (var columnIndex = columnCount;
                  columnIndex >= 0;
                  columnIndex--) {
                for (var rowIndex = rowCount; rowIndex >= 0; rowIndex--) {
                  final playerItem = data.firstWhereOrNull((element) {
                    return element.vector.value.dx == rowIndex &&
                        element.vector.value.dy == columnIndex;
                  });

                  final tile = PlayerTile(
                    columnIndex: columnIndex,
                    rowIndex: rowIndex,
                    player: playerItem,
                    tileSize: tileSize,
                    xMargin: xMargin,
                    yMargin: yMargin,
                  );
                  playerWidgets.add(tile);
                }
              }
              playerWidgets.sort((v1, v2) {
                final k1 = (v1.player?.type.value.index ?? -1) * -1;
                final k2 = (v2.player?.type.value.index ?? -1) * -1;
                return k1.compareTo(k2);
              });

              // Better management for z-index based layout
              // but a little bit lag on debug (not tested on release)
              return Stack(
                children: playerWidgets,
              );

              // A little bit good on debug (good on release)
              // But not really good at z-index thing
              // return Stack(
              //   children: List.generate(
              //     rowCount,
              //     (rowIndex) {
              //       return Stack(
              //         children: List.generate(
              //           columnCount,
              //           (columnIndex) {
              //             final playerItem = data.firstWhereOrNull((element) {
              //               return element.vector.value.dx == rowIndex &&
              //                   element.vector.value.dy == columnIndex;
              //             });

              //             return PlayerTile(
              //               columnIndex: columnIndex,
              //               rowIndex: rowIndex,
              //               player: playerItem,
              //               tileSize: tileSize,
              //               xMargin: xMargin,
              //               yMargin: yMargin,
              //             );
              //           },
              //         ),
              //       );
              //     },
              //   ),
              // );
            },
          );
        },
      ),
    );

    late final topHeight = MediaQuery.of(context).viewPadding.top;

    late final body = MyAppStoreProvider(
      store: _store,
      child: ResponsiveLayoutBuilder(
        builder: (BuildContext context, ScreenSize size) {
          late final headers = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.edit)
                const SizedBox(
                  height: 5,
                ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(
                  'Zero Block',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(
                  'Move brown tiles until it reaches 0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    wordSpacing: 5,
                  ),
                ),
              ),
            ],
          );
          late final editWidgets = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (await _store.saveTiles()) {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop(true);
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          );
          late final playWidgets = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!widget.edit)
                ValueListenableBuilder<String>(
                  valueListenable: _store.name,
                  builder: (context, data, child) {
                    if (data.isEmpty) {
                      return const SizedBox();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      child: Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                          ),
                          label: Text(
                            'LEVEL ${isBlank(widget.customLevelId) ? data : 'CUSTOM $data'}',
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                          ),
                          onPressed: () async {
                            final queryParam = await showDialog<String?>(
                              context: context,
                              builder: (context) {
                                return const LevelsPage();
                              },
                            );
                            if (queryParam != null && queryParam.isNotEmpty) {
                              Navigator.of(context).pushNamed('/$queryParam');
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(
                height: 5,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('RESET'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                ),
                onPressed: () {
                  _store.reset(false);
                },
              ),
            ],
          );
          late final children = [
            // Row(
            //   children: [
            //     headers,
            //     // if (widget.edit) editWidgets,
            //     // if (!widget.edit) playWidgets,
            //     // if (!widget.edit) const PlayTimer(),
            //   ],
            // ),
            // headers,
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'ZERO BLOCK',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          'MOVE BROWN BLOCK UNTIL IT REACHES TO 0',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.edit) const PlayTimer(),
                  if (!widget.edit) playWidgets,
                  if (widget.edit) editWidgets,
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                // Important, so the aspect ratio is working when resized to wide landscape
                child: Center(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _store.isResetting,
                    child: mainTiles,
                    builder: (context, data, child) {
                      return data ? const CircularProgressIndicator(
                        color: Colors.white,
                      ) : child!;
                    },
                  ),
                ),
              ),
            ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        },
      ),
    );

    return Scaffold(
      body: kIsWeb
          ? body
          : Padding(
              padding: EdgeInsets.only(
                top: topHeight,
              ),
              child: body,
            ),
    );
  }
}

class PlayerTile extends StatefulWidget {
  final int columnIndex;
  final int rowIndex;
  final double tileSize;
  final double yMargin;
  final double xMargin;
  final Player? player;

  const PlayerTile({
    Key? key,
    required this.columnIndex,
    required this.rowIndex,
    required this.tileSize,
    required this.yMargin,
    required this.xMargin,
    required this.player,
  }) : super(key: key);

  @override
  _PlayerTileState createState() => _PlayerTileState();
}

bool completedDialogShown = false;

class _PlayerTileState extends State<PlayerTile> with TickerProviderStateMixin {
  Player? get playerItem => widget.player;

  late final _scaleAnimiation = AnimationController(
    vsync: this,
    lowerBound: 1,
    upperBound: 1.1,
    duration: const Duration(
      milliseconds: 80,
    ),
  );

  @override
  void initState() {
    super.initState();

    if (playerItem != null) {
      playerItem!.playerCompletedNotifier.addListener(_onPlayerCompleted);
    }
  }

  @override
  void didUpdateWidget(covariant PlayerTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    oldWidget.player?.playerCompletedNotifier.removeListener(
      _onPlayerCompleted,
    );
    playerItem?.playerCompletedNotifier.addListener(_onPlayerCompleted);
  }

  @override
  void dispose() {
    _scaleAnimiation.dispose();
    if (playerItem != null) {
      playerItem!.playerCompletedNotifier.removeListener(_onPlayerCompleted);
    }

    super.dispose();
  }

  pickTile() async {
    final pickerStore = await showDialog<TilePickerStore?>(
      context: context,
      builder: (_) {
        return TilePicker(
          store: TilePickerStore(),
        );
      },
    );
    if (pickerStore != null) {
      final playerId = widget.player!.id;
      final myStore = MyAppStoreProvider.of(context).store;
      myStore.replacePlayer(playerId, pickerStore);
    }
  }

  Widget _getPlayerWidget() {
    switch (playerItem!.type.value) {
      case PlayerType.main:
        return Stack(
          children: [
            PlayerMain(
              playerItem: playerItem,
              scaleAnimiation: _scaleAnimiation,
              tileSize: widget.tileSize,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: playerItem!.playerCompletedNotifier,
              builder: (context, data, child) {
                if (data != true) {
                  return const SizedBox();
                }

                return FireworkCompletedWidget(
                  child: TileItemContainer(
                    borderColor: Colors.transparent,
                    color: Colors.transparent,
                    tileSize: widget.tileSize,
                    child: const SizedBox(),
                  ),
                  onEnd: () {
                    playerItem!.playerCompletedNotifier.value = false;
                  },
                );
              },
            ),
          ],
        );
      case PlayerType.subtraction:
        return PlayerEnemy(
          playerItem: playerItem!,
          tileSize: widget.tileSize,
          color: const Color(0xff00A0CC),
          borderColor: const Color(0xff5CDCFF),
        );
      case PlayerType.addition:
        return PlayerEnemy(
          playerItem: playerItem!,
          tileSize: widget.tileSize,
          color: const Color(0xff389457),
          borderColor: const Color(0xff97D8AD),
        );
      case PlayerType.playerMultiple:
        return PlayerEnemy(
          playerItem: playerItem!,
          tileSize: widget.tileSize,
          color: const Color(0xffDC5641),
          borderColor: const Color(0xffECA398),
        );
      case PlayerType.playerDivide:
        return PlayerEnemy(
          playerItem: playerItem!,
          tileSize: widget.tileSize,
          color: const Color(0xff7D30FF),
          borderColor: const Color(0xffB185FF),
        );
      case PlayerType.occupied:
        final color = Colors.lightBlue.shade700;
        return Transform.scale(
          scale: 0.25,
          child: TileItemContainer(
            borderColor: color,
            color: color,
            tileSize: widget.tileSize,
            child: const SizedBox(),
          ),
        );
      case PlayerType.fireworkMove:
        const color = Colors.orange;
        return FireworkMoveWidget(
          child: TileItemContainer(
            borderColor: color,
            color: color,
            tileSize: widget.tileSize,
            child: const SizedBox(),
          ),
          onEnd: () {
            // if (animateSomeAnimatinOnMove) {
            //   playerItem!.vector.value = playerItem!.vectorDefer.copy();
            //   playerItem!.type.value = PlayerType.occupied;
            // }
          },
        );
      case PlayerType.fireworkCompleted:
        const color = Colors.orange;
        return FireworkMoveWidget(
          child: TileItemContainer(
            borderColor: color,
            color: color,
            tileSize: widget.tileSize,
            child: const SizedBox(),
          ),
        );
      case PlayerType.tilePicker:
        // Handled other place
        return const SizedBox();
      case PlayerType.none:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = MyAppStoreProvider.of(context).store;
    return ValueListenableBuilder<bool>(
      valueListenable: store.editMode,
      builder: (
        context,
        isEditMode,
        child,
      ) {
        return ValueListenableBuilder<Offset?>(
          valueListenable: playerItem?.vector ?? ValueNotifier<Offset?>(null),
          builder: (
            context,
            data,
            child,
          ) {
            final rowIndex = data?.dx ?? widget.rowIndex.toDouble();
            final columnIndex = data?.dy ?? widget.columnIndex.toDouble();
            late final animatedScaleChild = AnimatedBuilder(
              animation: _scaleAnimiation,
              child: ValueListenableBuilder<PlayerType>(
                valueListenable: playerItem?.type ??
                    ValueNotifier<PlayerType>(PlayerType.none),
                builder: (
                  context,
                  data,
                  child,
                ) {
                  late final playerWidget = _getPlayerWidget();
                  late Widget gridWidget;
                  late final iconButtonSize = widget.tileSize * 215 / 1000;
                  if (playerItem != null) {
                    if (isEditMode == true) {
                      final color = Colors.grey.shade600;
                      gridWidget = Stack(
                        children: [
                          Positioned.fill(
                            child: data == PlayerType.tilePicker
                                ? TileItemContainer(
                                    borderColor: color,
                                    color: color,
                                    tileSize: widget.tileSize,
                                    child: InkWell(
                                      onTap: () async {
                                        pickTile();
                                      },
                                      child: Icon(
                                        Icons.add,
                                        size: widget.tileSize * 600 / 1000,
                                      ),
                                    ),
                                  )
                                : playerWidget,
                          ),
                          if (data != PlayerType.tilePicker)
                            Positioned(
                              left: 0,
                              bottom: 0,
                              child: InkWell(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(
                                    Icons.edit,
                                    size: iconButtonSize,
                                  ),
                                ),
                                onTap: () {
                                  pickTile();
                                },
                              ),
                            ),
                          if (data != PlayerType.tilePicker)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: InkWell(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Icon(
                                    Icons.close,
                                    size: iconButtonSize,
                                  ),
                                ),
                                onTap: () {
                                  removeEditedTile();
                                },
                              ),
                            ),
                        ],
                      );
                    } else {
                      gridWidget = playerWidget;
                    }
                  }
                  return GridItem(
                    tileSize: widget.tileSize,
                    child: playerItem == null ? const SizedBox() : gridWidget,
                  );
                },
              ),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimiation.value,
                  child: child,
                );
              },
            );

            final bottom = columnIndex * widget.tileSize + widget.yMargin;
            final left = rowIndex * widget.tileSize + widget.xMargin;
            final isPlayer = playerItem?.type.value == PlayerType.main;
            return isPlayer && usePlayerAnimated
                ? QueuedAnimatedPositioned(
                    offsets: Tuple2(
                      bottom,
                      left,
                    ),
                    child: animatedScaleChild,
                  )
                : Positioned(
                    bottom: bottom,
                    left: left,
                    child: animatedScaleChild,
                  );

            // Decrease performance on web?
            // return AnimatedPositioned(
            //   bottom: columnIndex * widget.tileSize + widget.yMargin,
            //   left: rowIndex * widget.tileSize + widget.xMargin,
            //   duration: const Duration(
            //     milliseconds: 300,
            //   ),
            //   curve: Curves.linear,
            // );
          },
        );
      },
    );
  }

  void removeEditedTile() {
    final playerId = widget.player!.id;
    final myStore = MyAppStoreProvider.of(context).store;
    myStore.removeEditedPlayer(playerId);
  }

  void _onPlayerCompleted() {
    final myStore = MyAppStoreProvider.of(context).store;
    final playersLength = myStore.players.value
        .where((element) => element.type.value == PlayerType.main)
        .length;
    final mainPlayersLength = myStore.players.value
        .where((element) => element.isMainPlayerCompleted)
        .length;
    final allPlayersCompleted = mainPlayersLength == playersLength;
    if (kDebugMode) {
      print(
        'Is all players completed $allPlayersCompleted, mainPlayersLength: $mainPlayersLength, playersLength: $playersLength',
      );
    }
    if (allPlayersCompleted) {
      myStore.stopTimer();

      Future show() async {
        if (completedDialogShown) {
          print('completedDialogShown shown');
          return;
        }
        await showDialog(
          context: context,
          builder: (context) {
            final partyPopper = Image.asset(
              'assets/partypopper.png',
              height: 24,
            );
            return Dialog(
              alignment: Alignment.center,
              child: SizedBox(
                width: 80,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          partyPopper,
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'Good job',
                            style: TextStyle(
                              fontSize: 28,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          partyPopper,
                        ],
                      ),
                      MyAppStoreProvider(
                        store: myStore,
                        child: const PlayTimer(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            key: const Key('close-finished'),
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await myStore.reset(false);
                            },
                          ),
                          if (myStore.customLevel == null ||
                              myStore.customLevel!.isEmpty)
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () async {
                                completedDialogShown = false;
                                myStore.players.value = [];
                                final nextLevelInt = myStore.nextLevel();
                                if (nextLevelInt != -1) {
                                  final levelId =
                                      nextLevelInt.toStringAsFixed(0);
                                  try {
                                    final _ = await rootBundle.load(
                                      'assets/levels/$levelId.json',
                                    );
                                    var index = 0;
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            '/?level=$levelId', (r) {
                                      if (index == 1) {
                                        return false;
                                      }

                                      index++;
                                      return true;
                                    });
                                  } catch (e) {
                                    // TODO: Find a way to check if the file is not found instead of this
                                    if (kDebugMode) {
                                      print(e);
                                    }
                                  }
                                }
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        completedDialogShown = false;
      }

      show();
      completedDialogShown = true;
    }
  }
}

class GridItem extends StatelessWidget {
  final Widget child;
  final double tileSize;

  const GridItem({
    Key? key,
    required this.child,
    required this.tileSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tileSize,
      width: tileSize,
      padding: EdgeInsets.all(tileSize * 40 / 1000),
      child: child,
    );
  }
}
