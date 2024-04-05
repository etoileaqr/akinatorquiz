import 'dart:convert';

import 'package:flutter/services.dart';

class FileUtil {
  static Future<List<List<String>>> loadCsv(String path) async {
    List<List<String>> list = [];
    String csvText = await rootBundle.loadString(path);
    var lines = LineSplitter.split(csvText);
    for (String line in lines) {
      list.add(line.split(','));
    }
    return list;
  }

  static Future<Iterable> loadJson(String path) async {
    String jsonData = await rootBundle.loadString(path);
    Iterable jsonResponse = json.decode(jsonData);
    return jsonResponse;
  }

  static Future<List<String>> getCities() async {
    List<List<String>> citiesCsv = await loadCsv('assets/dev/cities.csv');
    List<String> list = [];
    for (List<String> row in citiesCsv) {
      list.add(row[1]);
    }
    list.removeAt(0);
    return list;
  }
}
