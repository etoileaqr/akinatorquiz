// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unnecessary_this, avoid_print

import 'dart:math';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../dto/app_data.dart';
import '../model/post.dart';
import '../model/item.dart';
import '../util/dev_util.dart';
import '../manager/sqlite_util.dart';
import '../util/widget_util.dart';

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

class _PlayViewState extends State<PlayView> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  Stream<String>? _data;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print("state = $state");
    switch (state) {
      case AppLifecycleState.inactive:
        print('非アクティブになったときの処理');
        break;
      case AppLifecycleState.paused:
        print('停止されたときの処理');
        break;
      case AppLifecycleState.resumed:
        print('再開されたときの処理');
        break;
      case AppLifecycleState.detached:
        print('破棄されたときの処理');
        break;
      default:
        print('default');
    }
    print(DateTime.now());
  }

  @override
  void dispose() {
    print("dispose");
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  void _initialize() {
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
    Item answerItem = targetList[Random().nextInt(targetList.length)];
    AppData.instance.answer = answerItem.name;
    Post firstPost = Post.chatGpt(content: '都市を選択しました');
    AppData.instance.posts.add(firstPost);
  }

  Future<void> _changeItem() async {
    // await SqliteUtil.deletePosts(
    //   genre: AppData.instance.genre,
    //   category: AppData.instance.category,
    // );
    // AppData.instance.posts = [];
    // for (Post post in AppData.instance.posts) {
    //   await SqliteUtil.insertPost(post: post);
    // }
    // List<Post> l = await SqliteUtil.selectPosts(
    //     genre: AppData.instance.genre,
    //     category: AppData.instance.category,
    //     scope: AppData.instance.scope);

    _initialize();
    // 画面の再描画
    setState(() {});
  }

  // TODO 途中
  // ignore: unused_element
  Future<void> _localSave() async {
    // まずdtoで持っている
    for (Post post in AppData.instance.posts) {
      await SqliteManager.insertPost(post: post);
    }
    AppData.instance.posts = [];
    List<Post> posts = await SqliteManager.selectPosts(
        genre: AppData.instance.genre, category: AppData.instance.category);
    AppData.instance.posts = posts;
  }

  // Streamの取得メソッド
  void _getStream() {
    _data = DevUtil.getFakeChatGptResponse(yourPost: AppData.instance.yourPost!)
        .asBroadcastStream();
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
                  Text(isChatGpt ? 'ChatGPT' : 'You', style: hStyle),
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
            appBar: AppBar(
              title: const Text('ホーム'),
              automaticallyImplyLeading: false,
            ),
            body: SafeArea(
              child: Consumer<StateController>(builder: (context, ctrl, child) {
                // 最終行までスクロールする
                _goToLast();

                return Column(children: [
                  Expanded(
                    child: Scrollbar(
                      // Scrollbar側にもcontrollerを設定する必要あり
                      controller: _scrollController,
                      child: SingleChildScrollView(
                        // controllerを設定
                        controller: _scrollController,
                        child: StreamBuilder(
                          stream: _data,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                // 取得が終わってから格納する
                                // 何度も追加してしまわないように、フラグを見る
                                if (!AppData.instance.alreadyLoaded) {
                                  String str = snapshot.data!;
                                  // 取得したデータをもとにインスタンスを作成し、dtoに格納
                                  Post post = Post.chatGpt(content: str);
                                  AppData.instance.posts.add(post);

                                  // 追加が完了したのでフラグを立てる
                                  AppData.instance.alreadyLoaded = true;
                                }

                                return postTileParentWidget();
                              } else {
                                return postTileParentWidget();
                              }
                            } else if (snapshot.connectionState ==
                                ConnectionState.active) {
                              // 取得中のデータ
                              String chatGptAnswer = snapshot.data!;

                              // 複数行に渡る可能性があるので、都度最終行までスクロールする。
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
                                              Text('ChatGPT', style: hStyle),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                child:
                                                    const CupertinoActivityIndicator(
                                                        radius: 8.5),
                                              ),
                                            ]),
                                            Text(chatGptAnswer,
                                                overflow: TextOverflow.visible,
                                                style: cStyle),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                    child: TextInputWidget(getStream: _getStream),
                  ),
                ]);
              }),
            ),

            drawer: _Drawer(),
            // floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            floatingActionButton: Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'hero1',
                    shape: const CircleBorder(),
                    backgroundColor: Colors.grey[200],
                    onPressed: () {
                      _key.currentState!.openDrawer();
                    },
                    child: const Icon(CupertinoIcons.list_dash),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FloatingActionButton.small(
                    heroTag: 'hero2',
                    shape: const CircleBorder(),
                    backgroundColor: Colors.blue[200],
                    onPressed: _changeItem,
                    child: const Icon(Icons.autorenew),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Drawer _Drawer() {
    // Icon? checkmark(Mode mode) {
    //   if (mode == AppData.instance.mode) {
    //     return const Icon(Icons.check, color: CupertinoColors.systemPurple);
    //   } else {
    //     return null;
    //   }
    // }
    // TODO 使わないかも
    // ignore: unused_element
    Text subtitle(dynamic obj) {
      return Text(
        obj == null ? '' : obj.posts.last.content,
        maxLines: 1,
        style: TextStyle(
          color: Colors.grey[400],
        ),
      );
    }

    Text buttonText(String item) => Text(
          item,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(fontSize: 14),
        );

    DropdownButton2 genreDropdownButton() {
      return DropdownButton2(
        value: AppData.instance.genre,
        onChanged: (value) {
          AppData.instance.genre = value!;
          AppData.instance.category =
              AppData.instance.genreMap[AppData.instance.genre]!.first;
          setState(() {});
        },
        items: AppData.instance.genreMap.keys
            .map((String item) =>
                DropdownMenuItem(value: item, child: buttonText(item)))
            .toList(),
      );
    }

    DropdownButton2 categoryDropdownButton() {
      return DropdownButton2(
        value: AppData.instance.category,
        onChanged: (value) {
          AppData.instance.category = value!;
          setState(() {});
        },
        items: AppData.instance.genreMap[AppData.instance.genre]!
            .map((String item) =>
                DropdownMenuItem(value: item, child: buttonText(item)))
            .toList(),
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
          // color: Colors.red,
          width: MediaQuery.of(context).size.width * 0.14,
          child: Column(children: [
            Icon(icon),
            Text(label, style: const TextStyle(fontSize: 10))
          ]),
        ),
      );
    }

    return Drawer(
      child: Column(children: [
        DrawerHeader(
          decoration: BoxDecoration(
              color: CupertinoColors.systemPurple.withOpacity(0.3)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(children: [
              //   // drawerIconButton(icon: Icons.abc, onPressed: () {})
              // ]),
              // Text(
              //   '出題範囲',
              //   style: TextStyle(fontSize: 14),
              // ),
              genreDropdownButton(),
              categoryDropdownButton(),
            ],
          ),
        ),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Flexible(
            child: Scrollbar(
              // ignore: prefer_const_literals_to_create_immutables
              child: ListView(children: [
                // ListTile(
                //   title: const Text('世界の都市'),
                //   subtitle: subtitle(AppData.instance.city),
                //   trailing: checkmark(Mode.WORLD_CITY),
                //   onTap: () {
                //     AppData.instance.mode = Mode.WORLD_CITY;
                //     _initialize();
                //     setState(() {});
                //     // Navigator.pop(context);
                //   },
                // ),
                // ListTile(
                //   title: const Text('日本史-人物'),
                //   subtitle: subtitle(AppData.instance.jHistory),
                //   trailing: checkmark(Mode.JAPANESE_HISTORY),
                //   onTap: () {
                //     AppData.instance.mode = Mode.JAPANESE_HISTORY;
                //     _initialize();
                //     setState(() {});
                //     // Navigator.pop(context);
                //   },
                // ),
                // ListTile(
                //   title: const Text('世界史-人物'),
                //   subtitle: subtitle(AppData.instance.wHistory),
                //   trailing: checkmark(Mode.WORLD_HISTORY),
                //   onTap: () {
                //     AppData.instance.mode = Mode.WORLD_HISTORY;
                //     _initialize();
                //     setState(() {});
                //     // Navigator.pop(context);
                //   },
                // ),
              ]),
            ),
          ),
        ),
        const Divider(),
        Container(
          margin: const EdgeInsets.fromLTRB(20.0, 0, 16.0, 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              footerButton(icon: Icons.help, label: '使い方', onPressed: () {}),
              footerButton(
                  icon: CupertinoIcons.exclamationmark_circle,
                  label: 'インフォ',
                  onPressed: () {}),
              footerButton(
                  icon: CupertinoIcons.flag, label: 'バグの報告', onPressed: () {}),
              footerButton(icon: Icons.share, label: 'シェア', onPressed: () {}),
            ],
          ),
        ),
      ]),
    );
  }
}

/// TextFormField側のウィジェット
// 画面全体を再描画しないように分ける
class TextInputWidget extends HookWidget {
  const TextInputWidget({super.key, required this.getStream});
  // こちらからStreamメソッドを呼び出せるよう、関数をパラメータで渡す
  final Function getStream;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    // 空文字で送れないようにフラグを用意
    final canSend = useState<bool>(false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              // 空文字以外なら送信可能とする
              if (value.isEmpty) {
                canSend.value = false;
              } else {
                canSend.value = true;
              }
            },
            controller: controller,
            maxLines: 10,
            minLines: 1,
            decoration: InputDecoration(
              suffixIcon: controller.text.isEmpty
                  ? IconButton(
                      onPressed: () async {
                        //TODO 樋山さんへ
                        // ここに音声認識処理を実装かな？と思っております
                        // ※_controller.textに代入
                      },
                      icon: Icon(
                        Icons.mic,
                        color: Colors.grey[800],
                      ),
                    )
                  : null,
              hintText: 'Message',
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
          ),
        ),
        // 余白
        const SizedBox(
          width: 10,
        ),
        // 送信ボタン
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.text.isEmpty ? Colors.grey[400] : Colors.black,
          ),
          child: IconButton(
            onPressed: controller.text.isEmpty
                ? null
                : () {
                    // 質問のインスタンスを生成し、dtoに格納
                    Post yourPost = Post.you(content: controller.text);
                    AppData.instance.yourPost = yourPost;
                    AppData.instance.posts.add(yourPost);

                    // dtoに格納したのでTextEditingControllerの中身を空にする
                    controller.clear();
                    // 送信ボタンを非活性にする
                    canSend.value = false;
                    // 再描画の際にデータを再取得できるよう、フラグを下ろす
                    AppData.instance.alreadyLoaded = false;

                    // Streamメソッドを呼び出す
                    getStream();
                    // setStateNotifierを呼び出す
                    context.read<StateController>().setStateNotify();
                  },
            icon: const Icon(
              Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
