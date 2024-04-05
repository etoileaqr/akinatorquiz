import 'dart:math';

class DevUtil {
  static Stream<String> getFakeChatGptResponse() async* {
    for (String word in chatGptResponseWords) {
      final random = Random();
      int s = random.nextInt(2000);
      await Future.delayed(Duration(milliseconds: s));
      yield word;
    }
  }

  static const List<String> chatGptResponseWords = [
    "はい",
    "オタワ",
    "は",
    "カナダ",
    "の",
    "首都",
    "です。"
  ];
}
