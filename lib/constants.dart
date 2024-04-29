// ignore_for_file: constant_identifier_names

class Constants {
  // 'dictionary'
  static const String DICTIONARY = 'dictionary';
  // 'genres'
  static const String GENRES = 'genres';
  // 'items'
  static const String ITEMS = 'items';
  // 'posts'
  static const String POSTS = 'posts';
  // 'typos'
  static const String TYPOS = 'typos';
  // 'versions'
  static const String VERSIONS = 'versions';

  static const Set<String> mstSet = {
    DICTIONARY,
    GENRES,
    ITEMS,
    TYPOS,
  };

  /// 'all'
  static const String ALL = 'all';

  /// 'ChatGPT'
  static const String CHAT_GPT = 'ChatGPT';

  /// '「はい」か「いいえ」か「部分的にそう」で答えてください。'
  static const String question_annotation = '「はい」か「いいえ」のみで答えてください。';

  /// '選択したので当ててください。\nAIの都合上、答えるときは必ず\n「答えは〜」で始めてください🙏'
  static const String qSentence =
      '選択したので当ててください。\nAIの都合上、答えるときは必ず\n「答えは〜」で始めてください🙏';
}
