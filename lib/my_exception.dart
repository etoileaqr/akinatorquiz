import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import '../manager/chat_gpt_manager.dart';

// ログ出しなどを将来的にすることもあるかなと思ったので、一応作成して継承させている。
abstract class MyException implements Exception {
  // String get message;
  // String get _errorName;
  // String get description;
  // @override
  // String toString() => '$_errorName: $message';
}

class NoConnectionException extends MyException {}

abstract class ChatGptException extends MyException {
  ChatGptException({
    required this.chatGptAnswer,
    required this.messagesList,
  });
  List<Messages> messagesList;
  int? count;
  String chatGptAnswer;
  String get annotation;
  void retry(int count);
}

class NeitherYesNorNoException extends ChatGptException {
  NeitherYesNorNoException({
    required super.chatGptAnswer,
    required super.messagesList,
  });

  @override
  String get annotation =>
      '断定できない場合は、「たぶんそう」・「たぶん違う」・「部分的にそう」・「わかりません」から選んでください';

  @override
  void retry(int count) {
    ChatGptManager.receiveChatGptResponse(
      annotation: annotation,
      isRetry: true,
      count: count,
      messagesList: messagesList,
    );
  }
}

class InConsistencyException extends ChatGptException {
  InConsistencyException({
    required super.chatGptAnswer,
    required super.messagesList,
  });

  @override
  String get annotation => 'わからない場合は「わからない」と答えてください';

  @override
  void retry(int count) {
    ChatGptManager.receiveChatGptResponse(
      annotation: annotation,
      hasInconsistency: true,
      count: count,
      messagesList: messagesList,
    );
  }
}

class NoKnowledgeException extends ChatGptException {
  NoKnowledgeException({
    required super.chatGptAnswer,
    required super.messagesList,
  });

  @override
  String get annotation => 'わからない場合は「わからない」と答えてください';

  @override
  void retry(int count) {
    ChatGptManager.receiveChatGptResponse(
      annotation: annotation,
      count: count,
      messagesList: messagesList,
    );
  }
}

class NeedRetryException extends ChatGptException {
  NeedRetryException(
      {required super.chatGptAnswer, required super.messagesList});

  @override
  String get annotation => '';

  @override
  void retry(int count) {
    ChatGptManager.receiveChatGptResponse(
      count: count,
      messagesList: messagesList,
    );
  }
}
