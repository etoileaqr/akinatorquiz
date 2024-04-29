import '../main.dart';
import '../model/item.dart';
import '../model/typo.dart';
import '../model/dictionary.dart';
import '../model/post.dart';

class AppData {
  // シングルトンインスタンスを保持する静的な変数
  static final AppData instance = AppData._internal();

  // インスタンスを取得するためのファクトリコンストラクタ
  // 常に同じインスタンスを返す
  factory AppData() {
    return instance;
  }

  // インスタンス生成時に使用されるプライベートな名前付きコンストラクタ
  AppData._internal();

  List<Typo> typos = [];
  Post? yourPost;
  bool alreadyLoaded = false;

  Map<String, Dictionary> dictMap = {};
  Map<String, List<String>> genreMap = {};
  Map<String, Map<String, List<Item>>> itemMap = {};
  // String scope = '';
  String answer = '東京';
  List<Post> posts = [];

  bool hasAlreadyAnswered = false;

  bool isOpeningSettings = false;

  /* genre */
  String get genre => prefs.getString('genre') ?? 'subjects';
  set genre(String value) {
    prefs.setString('genre', value);
  }

  /* category */
  String get category => prefs.getString('category') ?? 'world_cities';
  set category(String value) {
    prefs.setString('category', value);
  }

  /* shouldShowAd */
  bool get shouldShowAd => prefs.getBool('shouldShowAd') ?? false;
  set shouldShowAd(bool value) {
    prefs.setBool('shouldShowAd', value);
  }

  /* level */
  int get level => prefs.getInt('level') ?? 1;
  set level(int value) {
    prefs.setInt('level', value);
  }

  /* isFirst */
  bool get isFirst => prefs.getBool('isFirst') ?? true;
  set isFirst(bool value) {
    prefs.setBool('isFirst', value);
  }

  /* userName */
  String get userName => prefs.getString('userName') ?? 'You';
  set userName(String value) {
    prefs.setString('userName', value);
  }
}
