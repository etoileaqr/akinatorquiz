// ignore_for_file: non_constant_identifier_names

import '../constants.dart';
import '../dto/app_data.dart';
import '../model/dictionary.dart';
import '../main.dart';
import '../model/item.dart';
import '../model/typo.dart';

class FirestoreManager {
  // typoマスタの取得
  static Future<List<Typo>> getTypos() async {
    List<Typo> list = [];
    var collections = await firestore.collection('typos').get();
    for (var snapshot in collections.docs) {
      Map<String, dynamic> map = snapshot.data();
      Typo typo = Typo.fromFirestore(map);
      list.add(typo);
    }
    return list;
  }

  // dictionaryマスタの取得
  static Future<Map<String, Dictionary>> getDictionary() async {
    Map<String, Dictionary> dictMap = {};
    var collections = await firestore.collection('dictionary').get();
    for (var snapshot in collections.docs) {
      String key = snapshot.id;
      Map<String, dynamic> map = snapshot.data();
      Dictionary dict = Dictionary.fromFirestore(key: key, map: map);
      dictMap[key] = dict;
    }
    return dictMap;
  }

  // Genreのマップ取得
  static Future<Map<String, List<String>>> getGenreMap() async {
    Map<String, List<String>> genreMap = {};
    var collections = await firestore.collection('genres').get();
    for (var snapshot in collections.docs) {
      Map<String, dynamic> map = snapshot.data();
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

    var mstRef = firestore.collection('mst');
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
        var category_snapshot =
            await mstRef.doc(genre).collection(category).get();
        for (var item_snapshot in category_snapshot.docs) {
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
