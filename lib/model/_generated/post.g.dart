// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
      post: json['post'] as String,
      isChatGpt: json['isChatGpt'] as bool,
    );

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'post': instance.post,
      'isChatGpt': instance.isChatGpt,
    };
