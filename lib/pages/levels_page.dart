import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zero_block/myapp_store.dart';

class LevelData {
  late String value;
  late String name;
}

class LevelsStore extends ChangeNotifier
    implements ValueListenable<LevelsStore> {
  List<LevelData> levels = [];
  List<LevelData> customLevels = [];

  bool getLevelLoading = false;
  bool getCustomLevelLoading = false;

  getLevels() async {
    try {
      getLevelLoading = true;
      notify();

      var currentLevel = 1;
      levels.clear();
      while (true) {
        try {
          final _ = await rootBundle.load(
            'assets/levels/$currentLevel.json',
          );
          levels.add(
            LevelData()
              ..value = currentLevel.toString()
              ..name = currentLevel.toString(),
          );
          currentLevel++;
        } catch (e) {
          // TODO: Find a way to check if the file is not found instead of this
          if (kDebugMode) {
            print(e);
          }
          break;
        }
      }
    } finally {
      getLevelLoading = false;
    }
    notify();
  }

  Future getCustomLevels() async {
    try {
      getCustomLevelLoading = true;
      notify();

      final prefs = await SharedPreferences.getInstance();
      final customLevelsKeys =
          prefs.getKeys().where((element) => element.startsWith('cust_levels'));
      customLevels.clear();
      for (var item in customLevelsKeys) {
        final name = item.replaceAll('cust_levels', '');
        customLevels.add(
          LevelData()
            ..name = name
            ..value = item,
        );
      }
    } finally {
      getCustomLevelLoading = false;
    }
    notify();
  }

  @override
  LevelsStore get value => this;

  void notify() {
    notifyListeners();
  }
}

class LevelsPage extends StatefulWidget {
  const LevelsPage({Key? key}) : super(key: key);

  @override
  State<LevelsPage> createState() => _LevelsPageState();
}

class _LevelsPageState extends State<LevelsPage>
    with SingleTickerProviderStateMixin {
  var _tabIndex = 0;
  late final tabController = TabController(vsync: this, length: 2);

  final store = LevelsStore();

  @override
  void initState() {
    super.initState();

    store.addListener(() {
      setState(() {});
    });

    _tabIndex = tabController.index;
    tabController.addListener(() {
      setState(() {
        _tabIndex = tabController.index;
      });
    });

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      store.getLevels();
      store.getCustomLevels();
    });
  }

  @override
  void didUpdateWidget(covariant LevelsPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    store.getCustomLevels();
  }

  @override
  void dispose() {
    tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Levels',
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(
              child: Text('BUILT-IN LEVELS'),
            ),
            Tab(
              child: Text('CUSTOM LEVELS'),
            ),
          ],
        ),
        actions: [
          if (_tabIndex == 1)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final edited = await Navigator.of(context).pushNamed(
                  '/?edit=1',
                );
                if (edited == true) {
                  store.getCustomLevels();
                }
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          // Tab 1
          if (store.getLevelLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!store.getLevelLoading)
            ListView.builder(
              itemCount: store.levels.length,
              itemBuilder: (
                context,
                index,
              ) {
                final item = store.levels[index];
                return ListTile(
                  title: Text(
                    item.name,
                  ),
                  onTap: () {
                    Navigator.of(context).pop('?level=${item.value}');
                  },
                );
              },
            ),
          // Tab 2
          if (store.getCustomLevelLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!store.getCustomLevelLoading)
            Container(
              child: store.customLevels.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        'You haven\'t create custom level yet',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: store.customLevels.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final item = store.customLevels[index];
                        return ListTile(
                          title: Text(
                            item.name,
                          ),
                          onTap: () {
                            Navigator.of(context).pop(
                              '?customLevel=${item.value}',
                            );
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).pop(
                                '?customLevel=${item.value}&edit=1',
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
