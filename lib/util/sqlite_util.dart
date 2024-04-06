// import 'package:flutter/services.dart';
// import 'package:sqflite/sqflite.dart';

// import '../dto/app_data.dart';
// import '../constants.dart';
// import '../model/city.dart';
// import '../model/post.dart';

// class SqliteUtil {
//   static Future<Database?> createTables({required Set<String> sqls}) async {
//     Set<String> querys = {};
//     for (String sql in sqls) {
//       String s = await rootBundle.loadString(sql);
//       querys.add(s);
//     }
//     String dbPath = await getDatabasesPath();
//     String path = '$dbPath/akinatorquiz.db';
//     Database db = await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         for (String query in querys) {
//           await db.execute(query);
//         }
//       },
//     );
//     return db;
//   }

//   static Future<int> insertCity({required City city}) async {
//     Map<String, dynamic> jsonMap = city.toJson();
//     int id = await AppData.instance.sDb!.insert(
//       Constants.CITIES,
//       jsonMap,
//     );
//     return id;
//   }

//   static Future<int> insertPost({required Post post}) async {
//     Map<String, dynamic> jsonMap = post.toJson();
//     int id = await AppData.instance.sDb!.insert(
//       Constants.POSTS,
//       jsonMap,
//     );
//     return id;
//   }

//   static Stream<List<Post>>? selectPosts({required City city}) async* {
//     List<Map<String, Object?>> list = await AppData.instance.sDb!.query(
//       Constants.POSTS,
//       where: 'cityId = ?',
//       whereArgs: [city.id],
//       orderBy: 'postId ASC',
//     );
//     List<Post> posts = [];
//     for (Map<String, dynamic> map in list) {
//       posts.add(Post.fromJson(map));
//     }
//     yield posts;
//   }

//   // static void sendQuestionAndGetAnswerAsync({
//   //   required String formattedQuestion,
//   //   required int chatGptPostId,
//   // }) {
//   //   DevUtil.getFakeChatGptResponse().asBroadcastStream().listen((val) {
//   //     print('fake取得');
//   //     print(val);
//   //     AppData.instance.sDb!.update(
//   //       Constants.POSTS,
//   //       {
//   //         'post': val,
//   //       },
//   //       where: 'postId = ?',
//   //       whereArgs: [chatGptPostId], // "?"に代入する値
//   //     );
//   //   });

// //     main() {
// //   final members = ["Kboyさん", "Aoiさん", "kosukeさん"];
// //   // コードを修正: toSquared -> sqrt
// //   sqrt(members).listen((val) {
// //     print("sqrtで表示: " + val);
// //   });
// // }

// // // コードを修正: toSquared -> sqrt
// // Stream<String> sqrt(List<String> members) async* {
// //   for (String n in members) {
// //     yield n;
// //   }
// // }
//   // }
// }
