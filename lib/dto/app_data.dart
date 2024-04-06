import '../model/post.dart';
import '../model/typo_corrector.dart';

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

  // Database? sDb;
  List<String> cities = [];
  List<TypoCorrector> typoCorrectors = [];
  // City? city;
  String city = '';
  List<Post> posts = [];
  bool alreadyLoaded = false;
}
