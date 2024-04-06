// ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:math';
import 'package:akinatorquiz/util/chat_gpt_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../dto/app_data.dart';
import '../model/city.dart';
import '../model/post.dart';
import '../util/sqlite_util.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Post> _alreadyPosts = [];
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    // アイコンのサイズ
    double radius = 30;
    // 条件分岐の基準値を0にするとキーボードが閉じ切ってからレイアウトが調整され
    // ガタンとなってしまうので、基準値を50に設定しておく
    bool isKeyboardShown = (MediaQuery.of(context).viewInsets.bottom > 50);

    Container yourIcon() => Container(
          width: radius,
          height: radius,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'assets/file/test_photo.JPG',
              fit: BoxFit.fill,
            ),
          ),
        );

    Container chatGptIcon() => Container(
          width: radius,
          height: radius,
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/file/openai-white-logomark.png',
            fit: BoxFit.fill,
          ),
        );

    Widget Tiles({required bool isChatGpt, required String message}) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            isChatGpt ? chatGptIcon() : yourIcon(),
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isChatGpt ? 'ChatGPT' : 'You',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      message,
                      overflow: TextOverflow.visible,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ))
          ]);
    }

    Widget alreadyPostsWidget() {
      return Scrollbar(
          child: ListView(
        children: [
          for (Post p in _alreadyPosts) ...{
            Column(
              children: [
                Tiles(
                    isChatGpt: p.isChatGpt == 1 ? true : false,
                    message: p.post),
                const SizedBox(height: 20),
              ],
            ),
          }
        ],
      ));
    }

    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ホーム'),
        ),
        body: _isPlaying
            ? Column(children: [
                Expanded(
                  child: StreamBuilder(
                    stream:
                        SqliteUtil.selectPosts(city: AppData.instance.city!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          List<Post> posts = snapshot.data!;
                          _alreadyPosts = posts;
                          return Scrollbar(
                              child: ListView(
                            children: [
                              for (Post p in posts) ...{
                                Column(
                                  children: [
                                    Tiles(
                                        isChatGpt:
                                            p.isChatGpt == 1 ? true : false,
                                        message: p.post),
                                    const SizedBox(height: 20),
                                  ],
                                ),
                              }
                            ],
                          ));
                        } else {
                          return alreadyPostsWidget();
                        }
                      } else {
                        return alreadyPostsWidget();
                      }
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 10,
                    bottom: isKeyboardShown ? 10 : 30,
                  ),
                  child: const TextInputWidget(),
                ),
              ])
            : ElevatedButton(
                onPressed: () async {
                  // ランダムに都市を選択
                  int num = Random().nextInt(AppData.instance.cities.length);
                  String c = AppData.instance.cities[num];
                  // インスタンス化してsqliteに格納
                  City city = City(city: c);
                  int id = await SqliteUtil.insertCity(city: city);
                  // idとcityをkeyとしてdtoで保持
                  city.id = id;
                  AppData.instance.city = city;

                  // 最初の1行目だけこちらで生成する
                  Post post = Post(
                    cityId: id,
                    city: c,
                    post: '都市を選択しました。',
                    isChatGpt: 1,
                  );
                  await SqliteUtil.insertPost(post: post);
                  _isPlaying = true;
                  setState(() {});
                },
                child: const Text('Game Start'),
              ),
      ),
    );
  }
}

class TextInputWidget extends HookWidget {
  const TextInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final canSend = useState<bool>(false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextFormField(
            onChanged: (value) {
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
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: controller.text.isEmpty ? Colors.grey[400] : Colors.black,
          ),
          child: IconButton(
            onPressed: () async {
              primaryFocus?.unfocus();
              // 質問
              Post yourPost = Post(
                cityId: AppData.instance.city!.id!,
                city: AppData.instance.city!.city,
                post: controller.text,
                isChatGpt: 0,
              );
              // まず質問文をsqliteに格納
              await SqliteUtil.insertPost(post: yourPost);
              // chatGptの解答（この時点では空文字で格納する）
              Post chatGptPost = Post(
                cityId: AppData.instance.city!.id!,
                city: AppData.instance.city!.city,
                post: '',
                isChatGpt: 1,
              );
              //
              int chatGptPostId =
                  await SqliteUtil.insertPost(post: chatGptPost);
              // ChatGPTに聞く前にフォーマット
              String formattedQuestion =
                  ChatGptUtil.formatWhenQuestion(q: yourPost.post);
              // ChatGPTへの質問送信と解答受信を裏で【非同期的に】実施する
              SqliteUtil.sendQuestionAndGetAnswerAsync(
                formattedQuestion: formattedQuestion,
                chatGptPostId: chatGptPostId,
              );
              controller.clear();
              canSend.value = false;
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
