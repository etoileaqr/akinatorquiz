// ignore_for_file: non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../dto/app_data.dart';
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
import '../context_extension.dart';
import 'my_dialog.dart';
import 'my_indicator.dart';

// TextFormField側から更新をかけるために、
// ChangeNotifierを使うことにした。
class StateController with ChangeNotifier {
  void setStateNotify() {
    notifyListeners();
  }
}

class PlayView extends StatefulWidget {
  const PlayView({super.key});

  @override
  State<PlayView> createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView>
    with WidgetsBindingObserver, MyDialog, MyIndicator {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  Future<List<Post>>? _localData;
  Future<String?>? _future;
  TextEditingController nameController = TextEditingController();
  AppData appData = AppData();

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        // print('非アクティブになったときの処理');
        break;
      case AppLifecycleState.paused:
        // print('停止されたときの処理');
        if (!appData.isOpeningSettings) {
          appData.shouldShowAd = true;
        }
        break;
      case AppLifecycleState.resumed:
        // print('再開されたときの処理');
        if (appData.shouldShowAd) {
          appOpenAdManager.loadAd();
          appData.shouldShowAd = false;
        }
        appData.isOpeningSettings = false;
        break;
      case AppLifecycleState.detached:
        // print('破棄されたときの処理');
        appData.shouldShowAd = false;
        appData.isOpeningSettings = false;
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // _animationController.dispose();
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
      appData.posts = [];
      await _initialize();
      List<Post> posts = await SqliteManager.selectPosts(
          genre: appData.genre, category: appData.category);
      appData.posts = posts;
      await SqliteManager.localSave(needReset: false);
      appData.isFirst = false;
      _localData = SqliteManager.selectPostsGroupBy();
      setState(() {});
    });
  }

  Future<void> _initialize() async {
    String qSentence = '';
    if (context.isTablet()) {
      qSentence = '選択したので当ててください。\nAIの都合上、答えるときは必ず 「答えは〜」で始めてください🙏';
    } else {
      qSentence = '選択したので当ててください。\nAIの都合上、答えるときは必ず\n「答えは〜」で始めてください🙏';
    }

    appData.hasAlreadyAnswered = false;
    List<Item> tmpList = appData.itemMap[appData.genre]![appData.category]!;
    int level = appData.level;
    List<Item> targetList = [];
    for (Item item in tmpList) {
      if (item.level <= level) {
        targetList.add(item);
      }
    }

    Item answerItem;
    if (appData.isFirst) {
      answerItem = Item(level: 1, name: '東京');

      Post p = Post.chatGpt(content: '都市を' + qSentence);
      SqliteManager.insertPost(post: p);
    } else {
      answerItem = targetList[Random().nextInt(targetList.length)];
    }

    appData.answer = answerItem.name;
    String s = qSentence;
    if (appData.dictMap.containsKey(appData.category)) {
      String jCate = appData.dictMap[appData.category]!.ja;
      jCate = jCate.replaceFirst('世界の', '');
      s = jCate + 'を' + s;
    }

    Post firstPost = Post.chatGpt(content: s);
    appData.posts.add(firstPost);
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
    double r = context.isTablet() ? 36 : 30;
    double textWidth = MediaQuery.of(context).size.width * 0.8;
    TextStyle hStyle = TextStyle(
        fontSize: context.isTablet() ? 22 : 18, fontWeight: FontWeight.w500);
    TextStyle cStyle =
        TextStyle(fontSize: context.isTablet() ? 20 : 16, height: 1.6);

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
                  Text(
                    isChatGpt ? Constants.CHAT_GPT : appData.userName,
                    style: hStyle,
                  ),
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
        for (Post p in appData.posts)
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
                                if (!appData.alreadyLoaded) {
                                  // 取得したデータをもとにインスタンスを作成し、dtoに格納
                                  String chatGptAnswer = snapshot.data!;
                                  Post post =
                                      Post.chatGpt(content: chatGptAnswer);
                                  appData.posts.add(post);

                                  // 追加が完了したのでフラグを立てる
                                  appData.alreadyLoaded = true;
                                }

                                return postTileParentWidget();
                              } else {
                                return postTileParentWidget();
                              }
                            } else if (snapshot.connectionState !=
                                ConnectionState.none) {
                              _goToLast();
                              return Column(children: [
                                for (Post p in appData.posts)
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
                await SqliteManager.localSave(needReset: false);
                if (appData.posts.isEmpty) {
                  await _initialize();
                } else {
                  appData.answer = appData.posts.last.answer;
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
                    20,
              ),
              child: _Column(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _Column() {
    bool flg = (MediaQuery.of(context).viewInsets.bottom < 200);

    if (flg) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _ListBulletButton(),
          SizedBox(
            height: context.isTablet() ? 20 : 7,
          ),
          _LevelChangeButton(),
          SizedBox(
            height: context.isTablet() ? 13 : 3,
          ),
          _FloatingActionButton(),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ignore: avoid_unnecessary_containers
          Container(
            // margin: const EdgeInsets.only(bottom: 70),
            child: FloatingActionButton(
              heroTag: 'hero4',
              shape: const CircleBorder(),
              onPressed: () async {
                List<Option> optionList = getOptionList();
                primaryFocus?.unfocus();
                await Future.delayed(const Duration(milliseconds: 100));
                int? selected;
                if (mounted) {
                  selected = await showOptionsDialog(
                    context,
                    message: '以下からヒントをお選びください',
                    optionList: optionList,
                  );
                }

                if (selected != null) {
                  if (mounted) {
                    if (selected == 1) {
                      String char = appData.answer.substring(0, 1);
                      showOkDialog(
                        context,
                        content: Text('最初の1文字目は「$char」です'),
                        needTitle: false,
                      );
                    } else {
                      int i = appData.answer.length;
                      showOkDialog(
                        context,
                        content: Text('文字数は$i文字です'),
                        needTitle: false,
                      );
                    }
                  }
                }
              },
              child: Image.asset('assets/file/hint.png'),
            ),
          ),
        ],
      );
    }
  }

  List<Option> getOptionList() {
    List<Option> optionList = [];
    if (appData.category == 'world_cities') {
      Option opt1 = Option(id: 1, value: '最初の1文字目をみる');
      Option opt2 = Option(id: 2, value: '文字数をみる');
      optionList = [opt1, opt2];
    } else if (appData.category == 'elements') {
      Option opt1 = Option(id: 1, value: '最初の1文字目をみる');
      Option opt2 = Option(id: 2, value: '文字数をみる');
      optionList = [opt1, opt2];
    } else {
      Option opt1 = Option(id: 1, value: '最初の1文字目をみる');
      Option opt2 = Option(id: 2, value: '文字数をみる');
      optionList = [opt1, opt2];
    }
    return optionList;
  }

  FloatingActionButton _ListBulletButton() {
    if (context.isTablet()) {
      return FloatingActionButton.large(
        heroTag: 'hero1',
        shape: const CircleBorder(),
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey[200],
        onPressed: () {
          _key.currentState!.openDrawer();
        },
        child: const Icon(CupertinoIcons.list_bullet),
      );
    } else {
      return FloatingActionButton(
        heroTag: 'hero1',
        shape: const CircleBorder(),
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey[200],
        onPressed: () {
          _key.currentState!.openDrawer();
        },
        child: const Icon(CupertinoIcons.list_bullet),
      );
    }
  }

  FloatingActionButton _LevelChangeButton() {
    final record = CommonUtil.getLabelAndColor();
    String label = record.label;
    Color color = record.color;

    return FloatingActionButton(
      mini: !context.isTablet(),
      heroTag: 'hero2',
      shape: const CircleBorder(),
      backgroundColor: color,
      onPressed: () async {
        switch (appData.level) {
          case 1:
            appData.level = 2;
            break;
          case 2:
            appData.level = 3;
            break;
          case 3:
            appData.level = 1;
            break;
        }
        await SqliteManager.localSave(needReset: true);

        // リセット感を出すために、0.1秒間だけQuestionがない瞬間を作る
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 100));

        await _initialize();
        // 画面の再描画
        setState(() {});
      },
      child: Text(
        label,
        style: TextStyle(fontSize: context.isTablet() ? 22 : 14),
      ),
    );
  }

  FloatingActionButton _FloatingActionButton() {
    bool hasAnswer = false;
    if (appData.posts.length > 1) {
      hasAnswer = true;
    }
    return FloatingActionButton(
      mini: !context.isTablet(),
      heroTag: 'hero3',
      shape: const CircleBorder(),
      foregroundColor: hasAnswer ? Colors.black : Colors.grey[350],
      backgroundColor:
          hasAnswer ? Colors.blue[200] : Colors.grey[400]!.withOpacity(0.7),
      onPressed: hasAnswer
          ? () async {
              await SqliteManager.localSave(needReset: true);

              // リセット感を出すために、0.1秒間だけQuestionがない瞬間を作る
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 100));

              await _initialize();
              // 画面の再描画
              setState(() {});
            }
          : null,
      child: Stack(children: [
        const Icon(Icons.autorenew),
        if (!hasAnswer)
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
        appData.dictMap[item]!.ja,
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
          value: appData.genre,
          onChanged: (value) {
            if (value != appData.genre) {
              appData.genre = value!;
              appData.category = appData.genreMap[appData.genre]!.first;
              statefulBuilderSetState(() {});
            }
          },
          items: appData.genreMap.keys.map((String item) {
            bool isSelected = (item == appData.genre);
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
          value: appData.category,
          onChanged: (value) {
            appData.category = value!;
            statefulBuilderSetState(() {});
          },
          items: appData.genreMap[appData.genre]!.map((String item) {
            bool isSelected = (item == appData.category);
            return DropdownMenuItem(
                value: item, child: buttonText(item, isSelected));
          }).toList(),
          buttonStyleData: buttonStyle(),
          dropdownStyleData: dropdownStyle(),
        ),
      );
    }

    InkWell footerButton({
      required Widget icon,
      required String label,
      required VoidCallback onPressed,
    }) {
      return InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.14,
          child: Column(children: [
            icon,
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
      width: context.isTablet() ? context.screenWidth * 0.7 : null,
      child: Column(children: [
        StatefulBuilder(
          builder: (context, setState) => DrawerHeader(
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
                                          appData.dictMap[p.genre]!.ja,
                                          AppData
                                              .instance.dictMap[p.category]!.ja,
                                        ),
                                        onTap: () {
                                          appData.genre = p.genre;
                                          appData.category = p.category;
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
                      Post p = appData.posts.last;
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
                              appData.dictMap[p.genre]!.ja,
                              appData.dictMap[p.category]!.ja,
                            ),
                            onTap: () {
                              appData.genre = p.genre;
                              appData.category = p.category;
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
              // footerButton(
              //     icon: const Icon(Icons.help), label: '使い方', onPressed: () {}),
              footerButton(
                  icon: const Icon(CupertinoIcons.info),
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
                  icon: const Icon(CupertinoIcons.flag),
                  label: '報告/要望',
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '入力してください。';
                                      }
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

                      showOkDialog(context,
                          content: const Text('ありがとうございます！！'));
                    }
                  }),
              if (!context.isTablet())
                footerButton(
                  icon: const Icon(Icons.share),
                  label: 'シェア',
                  onPressed: () async {
                    // TODO リリースしたらホームページのリンク入れる
                    String shareText = '『アキネータークイズ』をプレイしよう!!';
                    String subject = '『アキネータークイズ』をプレイしよう!!';
                    // シェアする文章を引数で渡す
                    await Share.share(shareText, subject: subject);
                  },
                ),
            ],
          ),
        ),
      ]),
    );
  }
}
