// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../typo_corrector.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TypoCorrector _$TypoCorrectorFromJson(Map<String, dynamic> json) {
  return _TypoCorrector.fromJson(json);
}

/// @nodoc
mixin _$TypoCorrector {
  String get correct => throw _privateConstructorUsedError;
  List<String> get typos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TypoCorrectorCopyWith<TypoCorrector> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TypoCorrectorCopyWith<$Res> {
  factory $TypoCorrectorCopyWith(
          TypoCorrector value, $Res Function(TypoCorrector) then) =
      _$TypoCorrectorCopyWithImpl<$Res, TypoCorrector>;
  @useResult
  $Res call({String correct, List<String> typos});
}

/// @nodoc
class _$TypoCorrectorCopyWithImpl<$Res, $Val extends TypoCorrector>
    implements $TypoCorrectorCopyWith<$Res> {
  _$TypoCorrectorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correct = null,
    Object? typos = null,
  }) {
    return _then(_value.copyWith(
      correct: null == correct
          ? _value.correct
          : correct // ignore: cast_nullable_to_non_nullable
              as String,
      typos: null == typos
          ? _value.typos
          : typos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TypoCorrectorImplCopyWith<$Res>
    implements $TypoCorrectorCopyWith<$Res> {
  factory _$$TypoCorrectorImplCopyWith(
          _$TypoCorrectorImpl value, $Res Function(_$TypoCorrectorImpl) then) =
      __$$TypoCorrectorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String correct, List<String> typos});
}

/// @nodoc
class __$$TypoCorrectorImplCopyWithImpl<$Res>
    extends _$TypoCorrectorCopyWithImpl<$Res, _$TypoCorrectorImpl>
    implements _$$TypoCorrectorImplCopyWith<$Res> {
  __$$TypoCorrectorImplCopyWithImpl(
      _$TypoCorrectorImpl _value, $Res Function(_$TypoCorrectorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? correct = null,
    Object? typos = null,
  }) {
    return _then(_$TypoCorrectorImpl(
      correct: null == correct
          ? _value.correct
          : correct // ignore: cast_nullable_to_non_nullable
              as String,
      typos: null == typos
          ? _value._typos
          : typos // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TypoCorrectorImpl implements _TypoCorrector {
  _$TypoCorrectorImpl(
      {required this.correct, required final List<String> typos})
      : _typos = typos;

  factory _$TypoCorrectorImpl.fromJson(Map<String, dynamic> json) =>
      _$$TypoCorrectorImplFromJson(json);

  @override
  final String correct;
  final List<String> _typos;
  @override
  List<String> get typos {
    if (_typos is EqualUnmodifiableListView) return _typos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_typos);
  }

  @override
  String toString() {
    return 'TypoCorrector(correct: $correct, typos: $typos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TypoCorrectorImpl &&
            (identical(other.correct, correct) || other.correct == correct) &&
            const DeepCollectionEquality().equals(other._typos, _typos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, correct, const DeepCollectionEquality().hash(_typos));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TypoCorrectorImplCopyWith<_$TypoCorrectorImpl> get copyWith =>
      __$$TypoCorrectorImplCopyWithImpl<_$TypoCorrectorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TypoCorrectorImplToJson(
      this,
    );
  }
}

abstract class _TypoCorrector implements TypoCorrector {
  factory _TypoCorrector(
      {required final String correct,
      required final List<String> typos}) = _$TypoCorrectorImpl;

  factory _TypoCorrector.fromJson(Map<String, dynamic> json) =
      _$TypoCorrectorImpl.fromJson;

  @override
  String get correct;
  @override
  List<String> get typos;
  @override
  @JsonKey(ignore: true)
  _$$TypoCorrectorImplCopyWith<_$TypoCorrectorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
