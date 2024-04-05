// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../typo_corrector.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TypoCorrectorImpl _$$TypoCorrectorImplFromJson(Map<String, dynamic> json) =>
    _$TypoCorrectorImpl(
      correct: json['correct'] as String,
      typos: (json['typos'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$TypoCorrectorImplToJson(_$TypoCorrectorImpl instance) =>
    <String, dynamic>{
      'correct': instance.correct,
      'typos': instance.typos,
    };
