import 'package:akinatorquiz/quiz_data.dart';

import 'model/typo_corrector.dart';

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

  List<String> cities = [];
  List<TypoCorrector> typoCorrectors = [];
  QuizData qd = const QuizData(city: '東京');
}
