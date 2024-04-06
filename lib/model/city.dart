// ignore_for_file: unnecessary_this

import 'package:freezed_annotation/freezed_annotation.dart';

part '_generated/city.freezed.dart';
part '_generated/city.g.dart';

@unfreezed
class City with _$City {
  factory City({
    int? id,
    required String city,
  }) = _City;

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}
