// ignore_for_file: avoid_print

import 'dart:math';

import '../model/post.dart';
import '../main.dart';

class DevUtil {
  static Stream<String> getFakeChatGptResponse(
      {required Post yourPost}) async* {
    // Post chatGptPost = Post(
    //     cityId: yourPost.cityId, cityName: yourPost.cityName, isChatGpt: true);
    // int chatGptPostId = await SqliteUtil.insertPost(post: chatGptPost);
    // chatGptPost.postId = chatGptPostId;
    String str = '';
    yield str;
    // TODO yourPostの中身をChatGPTに投げる前に置換する

    for (String word in chatGptResponseWords) {
      final random = Random();
      int s = random.nextInt(500);
      await Future.delayed(Duration(milliseconds: s));
      str += word;
      // chatGptPost.content = str;
      // await SqliteUtil.updatePost(post: chatGptPost);
      yield str;
    }
  }

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
          .collection('genre')
          .doc(docName) // 'subjects'など
          .collection(collectionName) // 'world_cities'など
          .doc(r.doc)
          .set({'category': r.category, 'name': r.name});
    }
    print(list);
  }
}

class Content {
  Content({
    required this.doc,
    required this.category,
    required this.name,
  });
  final String doc;
  final String category;
  final String name;
}
