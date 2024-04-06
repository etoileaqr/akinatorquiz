// ignore_for_file: unnecessary_this

import 'package:freezed_annotation/freezed_annotation.dart';

part '_generated/post.freezed.dart';
part '_generated/post.g.dart';

@unfreezed
class Post with _$Post {
  factory Post({
    int? postId,
    required int cityId,
    required String city,
    required String post,
    required int isChatGpt,
  }) = _Post;

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
}
