// ignore_for_file: unnecessary_this

class Item {
  /* Fields */
  final int level;
  final String name;

  /* Constructors */
  /// Default
  Item({
    required this.level,
    required this.name,
  });

  /// ItemをJsonからデコードするConstructor
  Item.fromJson(Map<String, dynamic> json)
      : this.level = json['level'] as int? ?? 1,
        this.name = json['name'] as String? ?? '';
}
