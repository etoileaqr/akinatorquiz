// ignore_for_file: unnecessary_this

import 'package:freezed_annotation/freezed_annotation.dart';

part '_generated/typo_corrector.freezed.dart';
part '_generated/typo_corrector.g.dart';

@freezed
class TypoCorrector with _$TypoCorrector {
  factory TypoCorrector({
    required String correct,
    required List<String> typos,
  }) = _TypoCorrector;

  factory TypoCorrector.fromJson(Map<String, dynamic> json) =>
      _$TypoCorrectorFromJson(json);
}
