// ignore_for_file: constant_identifier_names

import '../dto/app_data.dart';
import '../model/typo_corrector.dart';

class ConvertUtil {
  /// 音声認識で発生する誤字を修正する
  static String convertTypo({required String str}) {
    // 誤字を修正する（例：統計→東経）
    for (TypoCorrector corrector in AppData.instance.typoCorrectors) {
      for (String typo in corrector.typos) {
        str = str.replaceAll(typo, corrector.correct);
      }
    }
    return str;
  }
}
