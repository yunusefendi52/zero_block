import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:quiver/strings.dart';
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

      levels.clear();
      for (var i = 1; i <= 15; i++) {
        levels.add(
          LevelData()
            ..value = i.toString()
            ..name = i.toString(),
        );
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

      final sp = SharedPreferencesAsync();
      final customLevelsKeys = await sp
          .getKeys()
          .then((e) => e.where((e) => e.startsWith('cust_levels')).toList());
      customLevels.clear();
      for (final item in customLevelsKeys) {
        final name = item.replaceAll('cust_levels', '');
        customLevels.add(
          LevelData()
            ..name = name
            ..value = item,
        );
      }
      customLevels.sort(
        (e1, e2) => int.parse(e1.name).compareTo(int.parse((e2.name))),
      );
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
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Tab 1
          if (store.getLevelLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!store.getLevelLoading)
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
              ),
              itemCount: store.levels.length,
              itemBuilder: (
                context,
                index,
              ) {
                final item = store.levels[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(15),
                  child: LayoutBuilder(builder: (context, boxConstraints) {
                    return Center(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: (40 / 100) * boxConstraints.maxHeight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
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
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 8,
                      ),
                      itemCount: store.customLevels.length,
                      itemBuilder: (
                        context,
                        index,
                      ) {
                        final item = store.customLevels[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: () {
                                  Navigator.of(context).pop(
                                    '?customLevel=${item.value}',
                                  );
                                },
                                child: LayoutBuilder(
                                    builder: (context, boxConstraints) {
                                  return Center(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: (40 / 100) *
                                            boxConstraints.maxHeight,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                Navigator.of(context).pop(
                                  '?customLevel=${item.value}&edit=1',
                                );
                              },
                              child: Center(
                                child: Text(
                                  'EDIT',
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () async {
                                final sp = SharedPreferencesAsync();
                                final spLevel = await sp
                                    .getString('cust_levels${item.name}');
                                if (isBlank(spLevel)) {
                                  return;
                                }
                                await Clipboard.setData(
                                  ClipboardData(text: spLevel!),
                                );
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('LEVEL COPIED'),
                                      content: Text(
                                        'YOU CAN SHARE THIS TO OTHER AND ENTER THE CODE WHEN STARTING THE GAME',
                                      ),
                                      actions: [
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'OK',
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Center(child: Text('COPY')),
                            ),
                          ],
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
