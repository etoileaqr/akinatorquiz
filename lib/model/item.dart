// ignore_for_file: unnecessary_this

class Item {
  /* Fields */
  final String scope;
  final String name;

  /* Constructors */
  /// Default
  Item({
    required this.scope,
    required this.name,
  });

  /// PostをJsonからデコードするConstructor
  Item.fromJson(Map<String, dynamic> json)
      : this.scope = json['scope'] as String? ?? '',
        this.name = json['name'] as String? ?? '';
}
