import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:zero_block/main.dart';
import 'package:zero_block/math_expression/math_expression.dart';
import 'package:zero_block/tile_picker.dart';
import 'package:quiver/strings.dart';
import 'package:collection/collection.dart';
import 'package:zero_block/utils.dart';

const animateSomeAnimatinOnMove = true;

const custLevelsKey = 'cust_v2_levels';

extension OffsetExtensions on Offset {
  Offset copy() {
    return Offset(dx, dy);
  }
}

int increment = 0;

enum PlayerType {
  none,
  main,
  subtraction,
  occupied,
  fireworkMove,
  fireworkCompleted,
  tilePicker,
  addition,
  playerMultiple,
  playerDivide,
}

class Player {
  Player(this.id);
  int id;

  final type = ValueNotifier<PlayerType>(PlayerType.none);
  final vector = ValueNotifier<Offset>(const Offset(0, 0));
  bool scaleOnInit = false;
  final data = ValueNotifier<String>('');
  final lifetime = ValueNotifier<int>(1);

  bool isMainPlayerCompleted = false;
  late final playerCompletedNotifier =
      ValueNotifier<bool>(isMainPlayerCompleted);

  late final mathExp = MathExpression();

  void evaluatePlayer(Player other) {
    try {
      final exp = '${data.value}${other.data.value}';
      if (kDebugMode) {
        print('Math expression $exp');
      }
      final double result = mathExp.evaluate(exp);
      data.value = removeDecimalZeroFormat(result);
      final playerVector = other.vector.value.copy();
      // final dragPlayerVector = vector.value.copy();
      vector.value = playerVector;

      if (type.value == PlayerType.main) {
        final isCompleted = double.parse(data.value) == 0;
        isMainPlayerCompleted = isCompleted;
        if (isCompleted) {
          playerCompletedNotifier.value = isCompleted;
        }
      }
      // if (animateSomeAnimatinOnMove) {
      //   other.type.value = PlayerType.fireworkMove;
      //   // other.vector.value = dragPlayerVector;
      //   // other.vectorDefer = dragPlayerVector;
      // } else {
      //   other.type.value = PlayerType.occupied;
      //   other.vector.value = dragPlayerVector;
      // }
      if (other.type.value != PlayerType.main) {
        other.lifetime.value--;
      }
      if (other.lifetime.value <= 0) {
        other.type.value = PlayerType.occupied;
      }
      // if (isCompleted) {
      //   other.type.value = PlayerType.fireworkCompleted;
      // } else {
      //   if (animateSomeAnimatinOnMove) {
      //     other.type.value = PlayerType.fireworkMove;
      //     // other.vector.value = dragPlayerVector;
      //     other.vectorDefer = dragPlayerVector;
      //   } else {
      //     other.type.value = PlayerType.occupied;
      //     other.vector.value = dragPlayerVector;
      //   }
      // }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static Player fromMap(Map map, int id) {
    return Player(id)
      ..type.value = PlayerType.values[map['type']]
      ..vector.value = Offset(
        map['vector']['x'].toDouble(),
        map['vector']['y'].toDouble(),
      )
      ..data.value = map['data']
      ..lifetime.value = map['lifetime'] ?? 1;
  }

  static List<Player> fromMapList(list) {
    int incr = 0;
    final l = list.map((e) {
      incr++;
      return fromMap(e, incr);
    });
    return List<Player>.from(l);
  }

  Map toMap() {
    final map = {
      'type': type.value.index,
      'vector': {
        'x': vector.value.dx,
        'y': vector.value.dy,
      },
      'data': data.value,
      'lifetime': lifetime.value,
    };
    return map;
  }

  static List toMapList(List<Player> list) {
    return list.map((e) {
      return e.toMap();
    }).toList();
  }

  late final v = vector.value;
  late final automationKey = Key(
    'tile-${removeDecimalZeroFormat(v.dx)}-${removeDecimalZeroFormat(v.dy)}',
  );
}

const periodic = Duration(milliseconds: 1);

class _LevelIdData {
  late String name;
  late List<Player> players;
}

class MyTimer {
  Timer? timer;

  void startTimer(void Function(Timer timer) callback) {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    timer = Timer.periodic(periodic, callback);
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
  }
}

class MyAppStore {
  final name = ValueNotifier<String>('');
  String? levelId;
  String? customLevel;
  final players = ValueNotifier<List<Player>>([]);
  final editMode = ValueNotifier<bool>(false);
  late final timer = MyTimer();
  final duration = ValueNotifier<Duration>(const Duration());
  final isResetting = ValueNotifier<bool>(false);

  bool firstTimeMove = true;

  String? shareLevel;

  void startTimer() {
    timer.startTimer(timerCallback);
  }

  void stopTimer() {
    timer.stopTimer();
  }

  void _stopAndResetTimer() {
    stopTimer();
    firstTimeMove = true;
    duration.value = const Duration();
  }

  replacePlayer(int id, TilePickerStore tilePickerStore) {
    final p = players.value;
    final itemIndex = p.indexWhere((element) => element.id == id);
    final item = p[itemIndex];
    String getDataOperator() {
      switch (tilePickerStore.selectedTile!.item2) {
        case PlayerType.subtraction:
          return '-';
        case PlayerType.addition:
          return '+';
        case PlayerType.playerMultiple:
          return '*';
        case PlayerType.playerDivide:
          return '/';
        default:
          return '';
      }
    }

    item.type.value = tilePickerStore.selectedTile!.item2;
    item.data.value = '${getDataOperator()}${tilePickerStore.data}';
    final lifetime = int.tryParse(tilePickerStore.lifetime ?? '') ?? 1;
    item.lifetime.value = lifetime > 0 ? lifetime : 1;
  }

  removeEditedPlayer(int id) {
    final p = players.value;
    final itemIndex = p.indexWhere((element) => element.id == id);
    final item = p[itemIndex];
    item.type.value = PlayerType.tilePicker;
    item.data.value = '';
  }

  static Future<_LevelIdData?> _getLevelDataFromId({
    String? customLevel,
    String? levelId,
    String? shareLevel,
  }) async {
    String jsonString = '';
    if (isNotBlank(shareLevel)) {
      final jsonStringBase64 = shareLevel!;
      jsonString = utf8.decode(base64Decode(jsonStringBase64));
    } else if (!isBlank(customLevel)) {
      final sp = SharedPreferencesAsync();
      final jsonStringBase64 = (await sp.getString(customLevel!))!;
      jsonString = utf8.decode(base64Decode(jsonStringBase64));
    } else if (!isBlank(levelId)) {
      jsonString = await rootBundle.loadString('assets/levels/$levelId.json');
    } else {
      return null;
    }
    final playerLevelModel = fromJson(jsonString);
    final name = playerLevelModel['name'];
    final p = Player.fromMapList(playerLevelModel['tiles']);
    return _LevelIdData()
      ..name = name
      ..players = p;
  }

  Future reset(bool edit) async {
    try {
      isResetting.value = true;

      _stopAndResetTimer();
      if (edit) {
        List<Player> p = [];
        int incr = 0;
        final level = await _getLevelDataFromId(
          levelId: levelId,
          customLevel: customLevel,
        );
        final levelPlayers = level?.players;
        for (var x = 0; x < 30; x++) {
          for (var y = 0; y < 30; y++) {
            incr++;
            const type = PlayerType.tilePicker;
            final vector = Offset(x.toDouble(), y.toDouble());
            final playerLevel = levelPlayers?.firstWhereOrNull(
              (element) => element.vector.value == vector,
            );
            if (playerLevel != null) {
              playerLevel.id = incr;
              p.add(playerLevel);
            } else {
              p.add(
                Player(incr)
                  ..type.value = type
                  ..vector.value = vector
                  ..data.value = type == PlayerType.main ? '5' : '-1',
              );
            }
          }
        }
        if (level != null) {
          if (level.name.isNotEmpty) {
            name.value = level.name;
          }
        }
        players.value = p;
      } else {
        final level = await _getLevelDataFromId(
          levelId: levelId,
          customLevel: customLevel,
          shareLevel: shareLevel,
        );
        if (level == null) {
          if (kDebugMode) {
            print('level null and is not loaded');
          }
          return;
        }
        name.value = level.name;
        players.value = level.players;
      }
    } finally {
      isResetting.value = false;
    }
  }

  Future<bool> saveTiles() async {
    try {
      final tilesJson = base64Encode(utf8.encode(toJson()));
      final sp = SharedPreferencesAsync();
      if (kDebugMode) {
        print(tilesJson);
      }
      await sp.setString(
        '$custLevelsKey${name.value.trim()}',
        tilesJson,
      );
      final lastCounter = int.tryParse(name.value);
      if (lastCounter == null) {
        print('Error lastCounter, not set to integer');
      }
      await sp.setInt(lastCounterKey, lastCounter!);
      return true;
    } catch (error) {
      // ignore: avoid_print
      print(error);
      return false;
    }
  }

  static Map fromJson(String value) {
    return jsonDecode(value);
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  Map toMap() {
    final tilesOnly = players.value.where((element) {
      switch (element.type.value) {
        case PlayerType.main:
        case PlayerType.subtraction:
        case PlayerType.addition:
        case PlayerType.playerMultiple:
        case PlayerType.playerDivide:
          return true;
        default:
          if (element.type.value.toString().startsWith('player')) {
            return true;
          } else {
            return false;
          }
      }
    }).toList();
    return {
      'name': name.value.trim(),
      'tiles': Player.toMapList(tilesOnly),
    };
  }

  void timerCallback(Timer timer) {
    duration.value = duration.value + periodic;
  }

  int nextLevel() {
    try {
      final levelId = this.levelId;
      if (levelId != null) {
        final levelIdInt = int.tryParse(levelId);
        if (levelIdInt != null) {
          final nextLevelInt = levelIdInt + 1;
          return nextLevelInt;
        }
      }
    } catch (error) {
      print(error);
    }

    return -1;
  }
}
