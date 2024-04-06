import 'dart:math';

class DevUtil {
  static Stream<String> getFakeChatGptResponse() async* {
    String str = '';
    yield str;
    for (String word in chatGptResponseWords) {
      final random = Random();
      int s = random.nextInt(500);
      await Future.delayed(Duration(milliseconds: s));
      str += word;
      yield str;
    }
  }

  static const List<String> chatGptResponseWords = [
    "はい、",
    "オタワ",
    "は",
    "カナダ",
    "の",
    "首都",
    "です。",
    "はい、",
    "オタワ",
    "は",
    "カナダ",
    "の",
    "首都",
    "です。",
  ];
}
