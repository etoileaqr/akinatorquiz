// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unused_local_variable, unused_import

import 'dart:math';

import 'package:akinatorquiz/constants.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

import '../model/post.dart';
import '../main.dart';

class DevUtil {
  // static Stream<String> getFakeChatGptResponse(
  //     {required Post yourPost}) async* {
  //   // Post chatGptPost = Post(
  //   //     cityId: yourPost.cityId, cityName: yourPost.cityName, isChatGpt: true);
  //   // int chatGptPostId = await SqliteUtil.insertPost(post: chatGptPost);
  //   // chatGptPost.postId = chatGptPostId;
  //   String str = '';
  //   yield str;
  //   // ChatGPTに投げる前に、質問文の最後に、
  //   // "「はい」か「いいえ」か「部分的にそう」で答えてください。"
  //   // をつける
  //   String question = yourPost.answer +
  //       'は' +
  //       yourPost.content +
  //       '\n' +
  //       Constants.question_annotation;

  //   Stream<ChatResponseSSE> stream = openAI.onChatCompletionSSE(
  //     request: ChatCompleteText(
  //       model: GptTurboChatModel(),
  //       messages: [
  //         Messages(
  //           role: Role.system,
  //           content: question,
  //         )
  //       ],
  //       maxToken: 100,
  //     ),
  //   );
  //   stream.listen((event) {
  //     final text = event.choices?.last.message?.content ?? '';
  //     str += text;
  //     yield str;
  //   });

  //   // for (String word in chatGptResponseWords) {
  //   //   final random = Random();
  //   //   int s = random.nextInt(500);
  //   //   await Future.delayed(Duration(milliseconds: s));
  //   //   str += word;
  //   //   // chatGptPost.content = str;
  //   //   // await SqliteUtil.updatePost(post: chatGptPost);
  //   //   yield str;
  //   // }
  // }

  static const List<String> chatGptResponseWords = [
    "はい、",
    "オタワ",
    "は",
    "カナダ",
    "の",
    "首都",
    "です。",
    "はい、",
    "オタワ",
    "は",
    "カナダ",
    "の",
    "首都",
    "です。",
  ];

  Future<void> insertMstToDb({
    required String docName,
    required String collectionName,
    required List<Content> list,
  }) async {
    // var list = await FileUtil.getCities();

    for (var r in list) {
      firestore
          .collection('mst')
          .doc(docName) // 'subjects'など
          .collection(collectionName) // 'world_cities'など
          .doc(r.doc)
          .set({'level': r.level, 'name': r.name});
    }
    print(list);
  }
}

class Content {
  Content({
    required this.doc,
    required this.level,
    required this.name,
  });
  final String doc;
  final int level;
  final String name;
}
