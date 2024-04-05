import '../app_data.dart';

class ChatGptUtil {
  /// 答える
  static String answerQuiz({required String a}) {
    //TODO 今のところフォーマットの予定はないが・・多分何かしないといけないんだろうな・・
    return a;
  }

  /// chatGPTに聞く用に文字列をフォーマットする
  static String askQuestion({required String q}) {
    /* 「その都市」という言葉が質問の中に入っていたら、
      正解の都市名に変換してchatGPTに投げることにする */
    q = q.replaceAll("その都市", AppData.instance.qd.city);
    return q;
  }

  /// chatGPTからの返事に都市名が入っていた場合は、「その都市」に置換して返す
  static String formatWhenReply({required String reply}) {
    reply = reply.replaceAll(AppData.instance.qd.city, "その都市");
    return reply;
  }
}
