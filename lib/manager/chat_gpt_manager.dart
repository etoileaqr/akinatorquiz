// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/foundation.dart';

import '../constants.dart';
import '../dto/app_data.dart';
import '../main.dart';
import '../model/post.dart';
import '../my_exception.dart';

class ChatGptManager {
  static String judgeIfIsCorrect({required Post yourPost}) {
    String realAnswer = yourPost.answer;
    String yourAnswer = yourPost.content;
    if (yourAnswer.contains(realAnswer)) {
      AppData.instance.hasAlreadyAnswered = true;
      return 'はい、正解です！答えは$realAnswerです';
    } else if (yourAnswer.contains('教え')) {
      AppData.instance.hasAlreadyAnswered = true;
      return '答えは「$realAnswer」です!!';
    } else {
      String text = '残念ながら不正解です...' '\n答えを見る場合は、「答えを教えて」と言ってください。';
      return text;
    }
  }

  static Future<String?> receiveChatGptResponse({
    String annotation = Constants.question_annotation,
    int count = 1,
    bool isRetry = false,
    bool hasInconsistency = false,
    List<Messages>? messagesList,
  }) async {
    if (AppData.instance.yourPost == null) {
      return null;
    } else if (AppData.instance.yourPost!.content.contains('答え')) {
      return judgeIfIsCorrect(yourPost: AppData.instance.yourPost!);
    } else if (AppData.instance.yourPost!.content
        .contains('${AppData.instance.answer}ですか')) {
      return judgeIfIsCorrect(yourPost: AppData.instance.yourPost!);
    } else {
      // _data = DevUtil.getFakeChatGptResponse(yourPost: AppData.instance.yourPost!)
      //     .asBroadcastStream();
      messagesList ??= [];

      String content = AppData.instance.yourPost!.content;

      String cate = AppData.instance.dictMap[AppData.instance.category]!.ja;
      String sss = 'その' + cate;
      sss = sss.replaceFirst('その世界の都市', 'その都市');

      try {
        String question = '';
        if (hasInconsistency) {
          question = 'どっちですか？';
        } else if (content.contains(sss)) {
          question = content.replaceAll(sss, AppData.instance.yourPost!.answer);
        } else {
          question = AppData.instance.yourPost!.answer + 'は' + content;
        }

        if (AppData.instance.hasAlreadyAnswered) {
          annotation = '50文字以内で簡潔に答えてください。';
        }
        messagesList = [
          ...messagesList,
          Messages(
            role: Role.system,
            content: annotation,
          ),
          Messages(
            role: Role.user,
            content: question,
          )
        ];

        if (kDebugMode) {
          print(question);
        }

        ChatCTResponse? response = await openAI.onChatCompletion(
          request: ChatCompleteText(
            model: GptTurboChatModel(),
            messages: messagesList,
            maxToken: 100,
          ),
        );

        String text = response?.choices.last.message?.content ?? '';

        if (hasInconsistency) {
          hasInconsistency = false;
          // 通常のcatchで受ける
          throw NeedRetryException(
              chatGptAnswer: text, messagesList: messagesList);
        }
        if (!isRetry && text.length > 7) {
          throw NeitherYesNorNoException(
              chatGptAnswer: text, messagesList: messagesList);
        }
        if (isRetry) {
          if (text.length < 5) {
            throw InConsistencyException(
                chatGptAnswer: text, messagesList: messagesList);
          } else if (text.length > 7) {
            throw NoKnowledgeException(
                chatGptAnswer: text, messagesList: messagesList);
          }
        }
        return text;
      } on ChatGptException catch (e) {
        if (count < 5) {
          Messages m = Messages(
            role: Role.assistant,
            content: e.chatGptAnswer,
          );
          e.messagesList.add(m);
          // それぞれ
          e.retry(++count);
        }
      } catch (e) {
        if (count < 3) {
          if (kDebugMode) {
            print('何するかは未定..');
          }
        }
        // rethrowして呼び出し元でcatchしてダイアログとか出すか〜
        rethrow;
      }
      return 'ChatGPTが苦手とする質問のようです..😢'
          '\n別の質問文も試してみて、うまくいかない場合は「使い方」を見ていただくか、'
          '「バグの報告」をしてくださると助かります🙇‍♂️';
    }
  }
}
