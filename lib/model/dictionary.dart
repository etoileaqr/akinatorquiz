// ignore_for_file: unnecessary_this

class Dictionary {
  /* Fields */
  final String key;
  final String ja;

  /* Constructors */
  /// Default
  Dictionary({
    required this.key,
    required this.ja,
  });

  /// PostをJsonからデコードする
  Dictionary.fromFirestore({
    required this.key,
    required Map<String, dynamic> map,
  }) : this.ja = map['ja'] as String? ?? '';
}
