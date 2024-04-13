import '../model/post.dart';

class CommonUtil {
  static Map<String, List<Post>> getTimeLineArchive(List<Post> list) {
    // 同日の午前0時ぴったりを"今日"とする
    DateTime now = DateTime.now();
    Map<String, List<Post>> map = {};

    // 毎回書くのは面倒なので。
    void updateMap(String key, Post post) {
      map.update(key, (value) {
        value.add(post);
        return value;
      }, ifAbsent: () => [post]);
    }

    for (Post p in list) {
      int diff = now.difference(p.postTime).inDays;
      if (diff < 1) {
        updateMap('Today', p);
      } else if (diff < 2) {
        updateMap('Yesterday', p);
      } else if (diff < 7) {
        updateMap('$diff days ago', p);
      } else if (diff < 14) {
        updateMap('Last week', p);
      } else if (diff < 30) {
        int num = diff ~/ 7;
        updateMap('$num weeks ago', p);
      } else if (diff < 60) {
        updateMap('Last month', p);
      } else if (diff < 365) {
        int num = diff ~/ 30;
        updateMap('$num months ago', p);
      } else if (diff < 730) {
        updateMap('Last year', p);
      } else if (diff > 0) {
        // これ以上は正の整数を判定条件にしておこう...
        int num = diff ~/ 365;
        updateMap('$num years ago', p);
      } else {
        updateMap('unknown', p);
      }
    }

    return map;
  }
}
