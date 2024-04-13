// ignore_for_file: unnecessary_this

import '../util/converter.dart';
import '../dto/app_data.dart';

class Post {
  /* Fields */
  int? id;
  final String genre;
  final String category;
  final String scope;
  final String answer;
  String content = '';
  final bool isChatGpt;
  final DateTime postTime;

  /* Constructors */
  /// ChatGPTのPost
  Post.chatGpt({required this.content})
      : this.genre = AppData.instance.genre,
        this.category = AppData.instance.category,
        this.scope = AppData.instance.scope,
        this.answer = AppData.instance.answer,
        this.isChatGpt = true,
        this.postTime = DateTime.now();

  /// ユーザーのPost
  Post.you({required this.content})
      : this.genre = AppData.instance.genre,
        this.category = AppData.instance.category,
        this.scope = AppData.instance.scope,
        this.answer = AppData.instance.answer,
        this.isChatGpt = false,
        this.postTime = DateTime.now();

  /// PostをJsonからデコードするConstructor
  Post.fromJson(Map<String, dynamic> json)
      : this.id = json['id'] as int?,
        this.genre = json['genre'] as String? ?? '',
        this.category = json['category'] as String? ?? '',
        this.scope = json['scope'] as String? ?? '',
        this.answer = json['answer'] as String? ?? '',
        this.content = json['content'] as String? ?? '',
        this.isChatGpt = const BoolConverter().fromJson(json['isChatGpt']),
        this.postTime = const DateTimeConverter().fromJson(json['postTime']);

  /* Methods */
  Map<String, dynamic> toJson() => {
        'id': this.id,
        'genre': this.genre,
        'category': this.category,
        'scope': this.scope,
        'answer': this.answer,
        'content': this.content,
        'isChatGpt': const BoolConverter().toJson(this.isChatGpt),
        'postTime': const DateTimeConverter().toJson(this.postTime)
      };
}
