// ignore_for_file: non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../dto/app_data.dart';
import '../main.dart';
import '../manager/admob_manager.dart';
import '../manager/chat_gpt_manager.dart';
import '../manager/firestore_manager.dart';
import '../model/post.dart';
import '../model/item.dart';
import '../util/common_util.dart';
import '../manager/sqlite_manager.dart';
import '../util/widget_util.dart';
import 'custom_text_field_dialog.dart';
import 'text_input_widget.dart';

// TextFormField側から更新をかけるために、
// ChangeNotifierを使うことにした。
class StateController with ChangeNotifier {
  void setStateNotify() {
    notifyListeners();
  }
}

// bool isAppOpenAdShowing = false;

class PlayView extends StatefulWidget {
  const PlayView({super.key});

  @override
  State<PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  Future<List<Post>>? _localData;
  Future<String?>? _future;
  TextEditingController nameController = TextEditingController();

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // print("state = $state");
    switch (state) {
      case AppLifecycleState.inactive:
        // print('非アクティブになったときの処理');
        break;
      case AppLifecycleState.paused:
        // print('停止されたときの処理');
        if (!AppData.instance.isOpeningSettings) {
          AppData.instance.shouldShowAd = true;
        }

        break;
      case AppLifecycleState.resumed:
        // print('再開されたときの処理');
        if (AppData.instance.shouldShowAd) {
          appOpenAdManager.loadAd();
          AppData.instance.shouldShowAd = false;
        }
        AppData.instance.isOpeningSettings = false;
        break;
      case AppLifecycleState.detached:
        // print('破棄されたときの処理');
        AppData.instance.shouldShowAd = false;
        AppData.instance.isOpeningSettings = false;
        break;
      default:
      // print('default');
    }
    // print(DateTime.now());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    nameController.dispose();
    appOpenAdManager.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future(() async {
      AppData.instance.posts = [];
      await _initialize();
      List<Post> posts = await SqliteManager.selectPosts(
          genre: AppData.instance.genre, category: AppData.instance.category);
      if (posts.length > 1) {
        if (posts.last.content.contains('選択したので当ててください')) {
          posts.removeLast();
        }
      }
      AppData.instance.posts = posts;
      await _localSave();
      prefs.setBool('isFirst', false);
      _localData = SqliteManager.selectPostsGroupBy();
      setState(() {});
    });
  }

  Future<void> _initialize() async {
    List<Item> tmpList = AppData
        .instance.itemMap[AppData.instance.genre]![AppData.instance.category]!;
    String scope = AppData.instance.scope;
    List<Item> targetList = [];
    if (scope.isEmpty) {
      targetList = tmpList;
    } else {
      for (Item item in tmpList) {
        if (item.scope == scope) {
          targetList.add(item);
        }
      }
    }
    bool isFirst = prefs.getBool('isFirst') ?? true;
    Item answerItem;
    if (isFirst) {
      answerItem = Item(scope: 'アジア', name: '東京');
      Post p = Post.chatGpt(
          content:
              '都市を選択したので当ててください。' '\nAIの都合上、答えるときは必ず' '\n「答えは〜」で始めてください🙏');
      SqliteManager.insertPost(post: p);
    } else {
      answerItem = targetList[Random().nextInt(targetList.length)];
    }

    AppData.instance.answer = answerItem.name;
    String s = '';
    if (AppData.instance.category == 'world_cities') {
      s = '都市を選択したので当ててください。' '\nAIの都合上、答えるときは必ず' '\n「答えは〜」で始めてください🙏';
    } else {
      s = '選択したので当ててください。' '\nAIの都合上、答えるときは必ず' '\n「答えは〜」で始めてください🙏';
    }
    if (kDebugMode) {
      print(answerItem.name);
    }
    Post firstPost = Post.chatGpt(content: s);
    AppData.instance.posts.add(firstPost);
  }

  Future<void> _localSave() async {
    // まずdtoで持っているPostsをSqliteに登録する
    for (Post post in AppData.instance.posts) {
      await SqliteManager.insertPost(post: post);
    }
    AppData.instance.posts = [];
    List<Post> posts = await SqliteManager.selectPosts(
        genre: AppData.instance.genre, category: AppData.instance.category);
    AppData.instance.posts = posts;
  }

  // Streamの取得メソッド
  void _getFuture() async {
    // TODO isEmulator的なので条件分岐して、スタブ化したものを入れる
    _future = ChatGptManager.receiveChatGptResponse();
  }

  // キーボードを出している都合上、
  // 新しいTileが画面外にいってしまうので、
  // 若干のラグを持たせて最下部までスクロールさせる
  void _goToLast() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    // アイコンのサイズ
    double r = 30;
    double textWidth = MediaQuery.of(context).size.width * 0.8;
    TextStyle hStyle =
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
    TextStyle cStyle = const TextStyle(fontSize: 16, height: 1.6);

    // 1回の質問or解答のタイル
    Widget postTile({required bool isChatGpt, required String message}) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // アイコン
            isChatGpt
                ? WidgetUtil.chatGptIcon(radius: r)
                : WidgetUtil.yourIcon(radius: r),
            SizedBox(
              width: textWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名前
                  Text(isChatGpt ? Constants.CHAT_GPT : 'You', style: hStyle),
                  // content
                  Text(message, overflow: TextOverflow.visible, style: cStyle),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // メンテが楽なようにまとめただけ
    Widget postTileParentWidget() {
      return Column(children: [
        for (Post p in AppData.instance.posts)
          postTile(isChatGpt: p.isChatGpt, message: p.content),
      ]);
    }

    return ChangeNotifierProvider<StateController>(
      create: (_) => StateController(),
      child: GestureDetector(
        // キーボード外をタップしたらキーボードを閉じる
        onTap: () => primaryFocus?.unfocus(),
        child: PopScope(
          canPop: false,
          child: Scaffold(
            key: _key,
            // appBar: AppBar(
            //   title: const Text('ホーム'),
            //   automaticallyImplyLeading: false,
            // ),
            body: SafeArea(
              child: Consumer<StateController>(builder: (context, ctrl, child) {
                // 最終行までスクロールする
                _goToLast();

                return Column(children: [
                  // 広告Widget
                  Container(
                    width: 320,
                    height: 50,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: AdWidget(ad: BannerAdManager().bannerAd),
                  ),
                  Expanded(
                    child: Scrollbar(
                      // Scrollbar側にもcontrollerを設定する必要あり
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        // controllerを設定
                        controller: _scrollController,
                        child: FutureBuilder(
                          future: _future,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                // 取得が終わってから格納する
                                // 何度も追加してしまわないように、フラグを見る
                                if (!AppData.instance.alreadyLoaded) {
                                  // 取得したデータをもとにインスタンスを作成し、dtoに格納
                                  String chatGptAnswer = snapshot.data!;
                                  Post post =
                                      Post.chatGpt(content: chatGptAnswer);
                                  AppData.instance.posts.add(post);

                                  // 追加が完了したのでフラグを立てる
                                  AppData.instance.alreadyLoaded = true;
                                }

                                return postTileParentWidget();
                              } else {
                                return postTileParentWidget();
                              }
                            } else if (snapshot.connectionState !=
                                ConnectionState.none) {
                              _goToLast();
                              return Column(children: [
                                for (Post p in AppData.instance.posts)
                                  postTile(
                                      isChatGpt: p.isChatGpt,
                                      message: p.content),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // アイコン
                                      WidgetUtil.chatGptIcon(radius: r),
                                      SizedBox(
                                        width: textWidth,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 名前
                                            Row(children: [
                                              Text(Constants.CHAT_GPT,
                                                  style: hStyle),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                child:
                                                    const CupertinoActivityIndicator(
                                                        radius: 8.5),
                                              ),
                                            ]),
                                            Text('',
                                                overflow: TextOverflow.visible,
                                                style: cStyle),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ]);
                            } else {
                              return postTileParentWidget();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: TextInputWidget(getFuture: _getFuture),
                  ),
                ]);
              }),
            ),

            drawer: _Drawer(),
            onDrawerChanged: (whenOpen) async {
              if (whenOpen) {
                _localData = SqliteManager.selectPostsGroupBy();
              } else {
                await _localSave();
                if (AppData.instance.posts.isEmpty) {
                  await _initialize();
                } else {
                  AppData.instance.answer = AppData.instance.posts.last.answer;
                }
                // 画面の再描画
                setState(() {});
              }
            },
            // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            floatingActionButton: Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top +
                      MediaQuery.of(context).size.height * 0.15 +
                      20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'hero1',
                    shape: const CircleBorder(),
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey[200],
                    onPressed: () {
                      // await Future.delayed(Duration(seconds: 5));
                      _key.currentState!.openDrawer();
                    },
                    child: const Icon(CupertinoIcons.list_bullet),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  // FloatingActionButton.small(
                  //   heroTag: 'hero2',
                  //   shape: const CircleBorder(),
                  //   foregroundColor: Colors.grey[700],
                  //   backgroundColor: Colors.grey[200],
                  //   onPressed: () {},
                  //   child: const Icon(Icons.filter_alt_outlined),
                  // ),
                  // const SizedBox(
                  //   height: 3,
                  // ),
                  //
                  _FloatingActionButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  FloatingActionButton _FloatingActionButton() {
    bool flg = false;
    if (AppData.instance.posts.isNotEmpty) {
      if (AppData.instance.posts.last.content.contains('選択したので当ててください')) {
        flg = true;
      }
    }
    return FloatingActionButton.small(
      heroTag: 'hero3',
      shape: const CircleBorder(),
      foregroundColor: flg ? Colors.grey[350] : Colors.black,
      backgroundColor:
          flg ? Colors.grey[400]!.withOpacity(0.7) : Colors.blue[200],
      onPressed: flg
          ? null
          : () async {
              await _localSave();
              await _initialize();
              // 画面の再描画
              setState(() {});
            },
      child: Stack(children: [
        const Icon(Icons.autorenew),
        if (flg)
          Icon(
            Icons.clear,
            color: Colors.grey[350],
          )
      ]),
    );
  }

  Drawer _Drawer() {
    double dropdownButtonWidth = MediaQuery.of(context).size.width * 0.4;

    Widget buttonText(String item, bool isSelected) {
      Color color = isSelected
          ? Colors.blueAccent
          : const Color.fromARGB(255, 25, 25, 25);
      return Text(
        AppData.instance.dictMap[item]!.ja,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(fontSize: 14, color: color),
      );
    }

    ButtonStyleData buttonStyle() => ButtonStyleData(
          height: 40,
          width: dropdownButtonWidth,
          padding: const EdgeInsets.only(left: 14, right: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.black26, width: 1.2),
            color: const Color.fromARGB(255, 252, 252, 252),
          ),
          // elevation: 2,
        );

    DropdownStyleData dropdownStyle() => DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.black26),
            color: const Color.fromARGB(255, 252, 252, 252),
          ),
          offset: const Offset(-20, 0),
          elevation: 2,
        );

    // setStateを渡さないとStatefulBuilderのうまみが活きない
    // ※ちょっと長ったらしいが、わかりやすいように命名しておく。
    Widget genreDropdownButton(Function statefulBuilderSetState) {
      return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          value: AppData.instance.genre,
          onChanged: (value) {
            if (value != AppData.instance.genre) {
              AppData.instance.genre = value!;
              AppData.instance.category =
                  AppData.instance.genreMap[AppData.instance.genre]!.first;
              statefulBuilderSetState(() {});
            }
          },
          items: AppData.instance.genreMap.keys.map((String item) {
            bool isSelected = (item == AppData.instance.genre);
            return DropdownMenuItem(
                value: item, child: buttonText(item, isSelected));
          }).toList(),
          buttonStyleData: buttonStyle(),
          dropdownStyleData: dropdownStyle(),
        ),
      );
    }

    // setStateを渡さないとStatefulBuilderのうまみが活きない
    // ※ちょっと長ったらしいが、わかりやすいように命名しておく。
    Widget categoryDropdownButton(Function statefulBuilderSetState) {
      return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          value: AppData.instance.category,
          onChanged: (value) {
            AppData.instance.category = value!;
            statefulBuilderSetState(() {});
          },
          items: AppData.instance.genreMap[AppData.instance.genre]!
              .map((String item) {
            bool isSelected = (item == AppData.instance.category);
            return DropdownMenuItem(
                value: item, child: buttonText(item, isSelected));
          }).toList(),
          buttonStyleData: buttonStyle(),
          dropdownStyleData: dropdownStyle(),
        ),
      );
    }

    InkWell footerButton({
      required IconData icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.14,
          child: Column(children: [
            Icon(icon),
            Text(label, style: const TextStyle(fontSize: 10))
          ]),
        ),
      );
    }

    SizedBox header(text) => SizedBox(
        width: MediaQuery.of(context).size.width * 0.25, child: Text(text));

    Text text(String g, String c) => Text(
          g + ' － ' + c,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        );

    return Drawer(
      child: Column(children: [
        StatefulBuilder(
          builder: (context, setState) => DrawerHeader(
            // decoration: BoxDecoration(
            //     color: CupertinoColors.systemPurple.withOpacity(0.3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(children: [
                  header('ジャンル'),
                  genreDropdownButton(setState),
                ]),
                Row(children: [
                  header('カテゴリー'),
                  categoryDropdownButton(setState),
                ]),
              ],
            ),
          ),
        ),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Flexible(
            child: Scrollbar(
              child: FutureBuilder(
                future: _localData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      List<Post> posts = snapshot.data!;

                      Map<String, List<Post>> map =
                          CommonUtil.getTimeLineArchive(posts);

                      return Scrollbar(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: ListView.separated(
                            itemCount: map.entries.length,
                            itemBuilder: (context, index) {
                              String key = map.entries.toList()[index].key;
                              List<Post> list =
                                  map.entries.toList()[index].value;

                              return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, top: 10, bottom: 5),
                                      child: Text(
                                        key,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    for (Post p in list) ...{
                                      ListTile(
                                        title: text(
                                          AppData.instance.dictMap[p.genre]!.ja,
                                          AppData
                                              .instance.dictMap[p.category]!.ja,
                                        ),
                                        onTap: () {
                                          AppData.instance.genre = p.genre;
                                          AppData.instance.category =
                                              p.category;
                                          setState(() {});
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    }
                                  ]);
                            },
                            separatorBuilder: (context, index) =>
                                const Divider(),
                          ),
                        ),
                      );
                    } else {
                      Post p = AppData.instance.posts.last;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding:
                                EdgeInsets.only(left: 15, top: 10, bottom: 5),
                            child: Text(
                              'Today',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ListTile(
                            title: text(
                              AppData.instance.dictMap[p.genre]!.ja,
                              AppData.instance.dictMap[p.category]!.ja,
                            ),
                            onTap: () {
                              AppData.instance.genre = p.genre;
                              AppData.instance.category = p.category;
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  } else {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        const Divider(),
        Container(
          margin: const EdgeInsets.fromLTRB(20.0, 4.0, 16.0, 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              footerButton(icon: Icons.help, label: '使い方', onPressed: () {}),
              footerButton(
                  icon: CupertinoIcons.info,
                  label: 'インフォ',
                  onPressed: () {
                    showCupertinoDialog(
                      context: context,
                      builder: (_) => CupertinoAlertDialog(
                        content: const Text('新しい機能が追加されたらこちらに表示します！！'),
                        actions: [
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => Navigator.of(_).pop(),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: CupertinoColors.activeBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              footerButton(
                  icon: CupertinoIcons.flag,
                  label: 'バグの報告',
                  onPressed: () async {
                    bool sent = await showCupertinoDialog(
                        context: context,
                        builder: (_) {
                          return CustomTextFieldDialog(
                            title: 'アプリの改善にご協力ください🙏',
                            contentWidget: Card(
                              color: Colors.transparent,
                              elevation: 0.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: nameController,
                                    maxLength: 30,
                                    maxLines: 1,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.text,
                                    // textInputAction: TextInputAction.next,
                                    // decoration: const InputDecoration(
                                    //   labelText: 'バグの概要',
                                    //   errorMaxLines: 2,
                                    // ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        // return 'Name must not be null or empty.';
                                        return '入力してください。';
                                      }

                                      // if (value.length > 10) {
                                      //   return '';
                                      // }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            cancelActionText: 'キャンセル',
                            cancelAction: () {},
                            defaultActionText: '送信',
                            action: () async {
                              String content = nameController.text;
                              try {
                                await FirestoreManager.insertBugToDb(
                                    content: content);
                              } catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                              }
                            },
                          );
                        });
                    if (sent) {
                      await Future.delayed(const Duration(milliseconds: 200));
                      nameController.clear();
                      if (!mounted) {
                        return;
                      }

                      showCupertinoDialog(
                        context: context,
                        builder: (_) => CupertinoAlertDialog(
                          content: const Text('ありがとうございます！！'),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () => Navigator.of(_).pop(),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  color: CupertinoColors.activeBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
              footerButton(
                  icon: Icons.share,
                  label: 'シェア',
                  onPressed: () async {
                    // TODO リリースしたらホームページのリンク入れる
                    String shareText = 'アプリ『アキネータークイズ』';
                    // シェアする文章を引数で渡す
                    await Share.share(shareText);
                  }),
            ],
          ),
        ),
      ]),
    );
  }
}
