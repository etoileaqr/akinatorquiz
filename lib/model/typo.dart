// ignore_for_file: unnecessary_this

import '../dto/app_data.dart';

class Typo {
  /* Fields */
  final String correct;
  final String wrong;

  /* Constructors */
  Typo({required this.correct, required this.wrong});

  /// TypoをJsonからデコードするConstructor
  Typo.fromFirestore(Map<String, dynamic> json)
      : this.correct = json['correct'] as String? ?? '',
        this.wrong = json['wrong'] as String? ?? '';

  /* Methods */
  /// 音声認識で発生する誤字を修正する
  static String convertTypo({required String str}) {
    // 誤字を修正する（例：統計→東経）
    for (Typo corrector in AppData.instance.typos) {
      str = str.replaceAll(corrector.wrong, corrector.correct);
    }
    return str;
  }
}
