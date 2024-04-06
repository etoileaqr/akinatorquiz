// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
      postId: json['postId'] as int?,
      cityId: json['cityId'] as int,
      city: json['city'] as String,
      post: json['post'] as String,
      isChatGpt: json['isChatGpt'] as int,
    );

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'postId': instance.postId,
      'cityId': instance.cityId,
      'city': instance.city,
      'post': instance.post,
      'isChatGpt': instance.isChatGpt,
    };
