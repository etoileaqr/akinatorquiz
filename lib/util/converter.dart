import 'package:freezed_annotation/freezed_annotation.dart';

class BoolConverter implements JsonConverter<bool, Object> {
  const BoolConverter();

  @override
  bool fromJson(var json) {
    if (json is bool) {
      return json;
    } else if (json is int) {
      if (json == 0) {
        return false;
      } else if (json == 1) {
        return true;
      } else {
        throw UnimplementedError();
      }
    } else {
      throw UnimplementedError();
    }
  }

  @override
  int toJson(bool b) {
    if (b) {
      return 1;
    } else {
      return 0;
    }
  }
}

class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) {
    return DateTime.parse(json).toLocal();
  }

  @override
  String toJson(DateTime dateTime) {
    return dateTime.toLocal().toString();
  }
}
