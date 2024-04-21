// ignore_for_file: unnecessary_this

class Version {
  /* Fields */
  final String name;
  final int version;

  /* Constructors */
  /// Default
  Version({
    required this.name,
    required this.version,
  });

  String getKey() {
    return this.name;
  }

  /// VersionをJsonからデコードするConstructor
  Version.fromJson(Map<String, dynamic> json)
      : this.name = json['name'] as String? ?? '',
        this.version = json['version'] as int? ?? 0;

  /* Methods */
  Map<String, dynamic> toJson() => {
        'name': this.name,
        'version': this.version,
      };
}
