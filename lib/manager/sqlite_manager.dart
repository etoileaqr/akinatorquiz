import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../constants.dart';
// import '../model/dictionary.dart';
import '../dto/app_data.dart';
import '../model/post.dart';
import '../main.dart';
import '../model/typo.dart';
import '../model/version.dart';

class SqliteManager {
  static Future<Database> openAndGetDbInstance() async {
    String dbPath = await getDatabasesPath();
    String path = '$dbPath/akinatorquiz.db';
    Database db = await openDatabase(path, version: 1);
    return db;
  }

  static Future<void> createTables() async {
    Set<String> tables = Set.from(Constants.mstSet);
    tables.add(Constants.POSTS);
    tables.add(Constants.VERSIONS);
    Set<String> querys = {};
    for (String tableName in tables) {
      String sql = 'assets/sql/create_$tableName.sql';
      String query = await rootBundle.loadString(sql);
      querys.add(query);
    }

    for (String query in querys) {
      await sqliteDb.execute(query);
    }
  }

  static Future<void> initMstVersions() async {
    String jsonData =
        await rootBundle.loadString('assets/file/initial_mst_versions.json');
    List list = json.decode(jsonData);
    List<Version> versions =
        list.map((data) => Version.fromJson(data)).toList();
    for (var version in versions) {
      await sqliteDb.insert(Constants.VERSIONS, version.toJson());
    }
  }

  static Future<List<dynamic>> getLocalMstVersion(
      {required String mstName}) async {
    List<dynamic> list = await sqliteDb.query(
      Constants.VERSIONS,
      where: 'name=?',
      whereArgs: [mstName],
    );
    return list;
  }

  static Future<void> updateMstVersion({
    required Map<String, Object?> map,
    required String mstName,
  }) async {
    await sqliteDb.update(
      Constants.VERSIONS,
      map,
      where: 'name=?',
      whereArgs: [mstName],
    );
  }

  static Future<int> insertPost({required Post post}) async {
    int id = 0;

    // try {
    //   await sqliteDb.query(
    //     Constants.POSTS,
    //     where: 'id=?',
    //     whereArgs: [post.id],
    //   );
    //   // await sqliteDb.transaction((txn) async {
    //   //   sqliteDb.query(
    //   //     Constants.POSTS,
    //   //     where: 'id=?',
    //   //     whereArgs: [post.id],
    //   //   );
    //   // });
    // } catch (e) {
    //   print(e);
    // }
    // return id;
    try {
      Map<String, dynamic> jsonMap = post.toJson();
      id = await sqliteDb.insert(
        Constants.POSTS,
        jsonMap,
      );
    } catch (e) {
      // TODO 本来はupsertしたいが、今は一旦握りつぶすことで対処している・・
      if (kDebugMode) {
        // print(e);
      }
    }
    // print(id);
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
    List<Map<String, Object?>> list = await sqliteDb.query(
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
    await sqliteDb.delete(
      Constants.POSTS,
      where: 'genre = ? AND category = ?',
      whereArgs: [genre, category],
    );
  }

  static Future<List<Post>> selectPostsGroupBy() async {
    List<Map<String, Object?>> list = await sqliteDb.query(
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

  static Future<void> deleteAndInsertTypoMst(
      {required List<Typo> typos}) async {
    List<dynamic> list = await sqliteDb.query(Constants.TYPOS);
    if (list.isNotEmpty) {
      await sqliteDb.delete(Constants.TYPOS);
    }
    for (Typo typo in typos) {
      await sqliteDb.insert(Constants.TYPOS, typo.toJson());
    }
  }

  // static Future<void> deleteAndInsertDictionaryMst(
  //     {required Map<String, Dictionary> dictMap}) async {
  //   List<dynamic> list = await sqliteDb.query(Constants.DICTIONARY);
  //   if (list.isNotEmpty) {
  //     await sqliteDb.delete(Constants.DICTIONARY);
  //   }
  //   for (MapEntry<String, Dictionary> dict in dictMap.entries) {

  //     await sqliteDb.insert(Constants.TYPOS, typo.toJson());
  //   }
  // }

  static Future<void> localSave({required bool needReset}) async {
    if (needReset) {
      await deletePosts(
        genre: AppData.instance.genre,
        category: AppData.instance.category,
      );
      AppData().posts = [];
    }
    // まずdtoで持っているPostsをSqliteに登録する
    for (Post post in AppData.instance.posts) {
      await insertPost(post: post);
    }
    AppData.instance.posts = [];
    List<Post> posts = await selectPosts(
        genre: AppData.instance.genre, category: AppData.instance.category);
    AppData.instance.posts = posts;
  }
}
