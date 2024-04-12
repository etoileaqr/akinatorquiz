// ignore_for_file: non_constant_identifier_names

import '../constants.dart';
import '../dto/app_data.dart';
import '../model/dictionary.dart';
import '../main.dart';
import '../model/item.dart';

class FirestoreManager {
  // dictionaryマスタの取得
  static Future<Map<String, Dictionary>> getDictionary() async {
    Map<String, Dictionary> dictMap = {};
    var dict_collections = await firestore.collection('dictionary').get();
    for (var dict_snapshot in dict_collections.docs) {
      String key = dict_snapshot.id;
      Map<String, dynamic> map = dict_snapshot.data();
      Dictionary dict = Dictionary.fromFirestore(key: key, map: map);
      dictMap[key] = dict;
    }
    return dictMap;
  }

  // Genreのマップ取得
  static Future<Map<String, List<String>>> getGenreMap() async {
    Map<String, List<String>> genreMap = {};
    var genre_collections = await firestore.collection('genres').get();
    for (var genre_snapshot in genre_collections.docs) {
      Map<String, dynamic> map = genre_snapshot.data();
      genreMap.update(
        map['genre'],
        (value) {
          value.add(map['category']);
          return value;
        },
        ifAbsent: () => [map['category']],
      );
    }
    return genreMap;
  }

  static Future<Map<String, Map<String, List<Item>>>> getItemMap(
      {required Map<String, List<String>> genreMap}) async {
    Map<String, Map<String, List<Item>>> itemMap = {Constants.ALL: {}};

    var mst_ref = firestore.collection('mst');
    List<Item> tmpAllList1 = [];
    for (MapEntry<String, List<String>> mapEntry
        in AppData.instance.genreMap.entries) {
      // わかりやすいように格納しているだけ。
      String genre = mapEntry.key;
      List<String> categories = mapEntry.value;
      // 先に初期化しておく
      itemMap[genre] = <String, List<Item>>{};
      List<Item> tmpAllList2 = [];
      for (String category in categories) {
        List<Item> list = [];
        var snapshot = await mst_ref.doc(genre).collection(category).get();
        for (var item_snapshot in snapshot.docs) {
          Map<String, dynamic> map = item_snapshot.data();
          Item item = Item.fromJson(map);
          list.add(item);
          tmpAllList1.add(item);
          tmpAllList2.add(item);
        }
        itemMap[genre]![category] = list;
      }
      itemMap[genre]![Constants.ALL] = tmpAllList2;
    }
    itemMap[Constants.ALL]![Constants.ALL] = tmpAllList1;
    return itemMap;
  }
}
