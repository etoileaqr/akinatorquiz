import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../constants.dart';
import '../model/post.dart';
import '../main.dart';

class SqliteManager {
  static Future<Database?> createTables({required Set<String> sqls}) async {
    Set<String> querys = {};
    for (String sql in sqls) {
      String s = await rootBundle.loadString(sql);
      querys.add(s);
    }
    String dbPath = await getDatabasesPath();
    String path = '$dbPath/akinatorquiz.db';
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        for (String query in querys) {
          await db.execute(query);
        }
      },
    );
    return db;
  }

  static Future<int> insertPost({required Post post}) async {
    int id = 0;
    try {
      Map<String, dynamic> jsonMap = post.toJson();
      id = await sqliteDb!.insert(
        Constants.POSTS,
        jsonMap,
      );
    } catch (e) {
      // TODO 本来はupsertしたいが、今は一旦握りつぶすことで対処している・・
      // print(e);
    }
    return id;
  }

  // static Future<int> updatePost({required Post post}) async {
  //   int i = await AppData.instance.sDb!.update(
  //     Constants.POSTS,
  //     {
  //       'content': post.content,
  //     },
  //     where: 'postId = ?',
  //     whereArgs: [post.postId], // "?"に代入する値
  //   );
  //   return i;
  // }

  static Future<List<Post>> selectPosts(
      {required String genre, required String category}) async {
    List<Map<String, Object?>> list = await sqliteDb!.query(
      Constants.POSTS,
      where: 'genre = ? AND category = ?',
      whereArgs: [genre, category],
      orderBy: 'postTime ASC',
    );
    List<Post> posts = [];
    for (Map<String, dynamic> map in list) {
      posts.add(Post.fromJson(map));
    }
    return posts;
  }

  static Future<void> deletePosts(
      {required String genre, required String category}) async {
    await sqliteDb!.delete(
      Constants.POSTS,
      where: 'genre = ? AND category = ?',
      whereArgs: [genre, category],
    );
  }

  static Future<List<Post>> selectPostsGroupBy() async {
    List<Map<String, Object?>> list = await sqliteDb!.query(
      Constants.POSTS,
      // where: 'genre = ? AND category = ?',
      // whereArgs: [genre, category],
      orderBy: 'postTime DESC',
      groupBy: 'genre, category',
    );
    // TODO このままだと古い順にGROUP BYしてしまう・・
    List<Post> posts = [];
    for (Map<String, dynamic> map in list) {
      posts.add(Post.fromJson(map));
    }
    // print(posts.length);
    return posts;
  }
}
