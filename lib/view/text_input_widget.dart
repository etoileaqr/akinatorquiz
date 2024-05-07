// ignore_for_file: prefer_const_constructors

// import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

import '../dto/app_data.dart';
import '../model/post.dart';
import 'play_view.dart';
import 'my_dialog.dart';

/// TextFormField側のウィジェット
// 画面全体を再描画しないように分ける
class TextInputWidget extends HookWidget with MyDialog {
  const TextInputWidget({super.key, required this.getFuture});
  // こちらからStreamメソッドを呼び出せるよう、関数をパラメータで渡す
  final Function getFuture;

  @override
  Widget build(BuildContext context) {
    // print('textFieldの再描画');
    // SpeechToText speechToText = SpeechToText();
    // final speechEnabled = useState<bool>(false);
    // final lastWords = useState<String>('');

    final controller = useTextEditingController();
    // 空文字で送れないようにフラグを用意
    final canSend = useState<bool>(false);
    // final isListening = useState<bool>(false);

    // useEffect(() {
    //   WidgetsBinding.instance.addPostFrameCallback((_) async {
    //     speechEnabled.value = await speechToText.initialize();
    //   });

    //   return null;
    // }, []);

    // void onSpeechResult(SpeechRecognitionResult result) {
    //   lastWords.value = result.recognizedWords;
    //   print(lastWords.value);
    //   controller.text = lastWords.value;
    // }

    // Future<void> startListening() async {
    //   await speechToText.listen(onResult: onSpeechResult);
    //   isListening.value = true;
    // }

    // Future<void> stopListening() async {
    //   await speechToText.stop();
    //   isListening.value = false;
    // }

    // Future<void> onTapMicIcon() async {
    //   // まずstatusを取得
    //   var micStatus = await Permission.microphone.status;
    //   var speechStatus = await Permission.speech.status;

    //   // 初回
    //   if (micStatus.isDenied) {
    //     // 「このあと出てくるダイアログで両方ともOKを押してね」ダイアログを表示
    //     if (context.mounted) {
    //       // TODO いい感じの絵を出した方がよさそう
    //       Widget content = const Text('てすとです');
    //       await showOkDialog(context, content: content);
    //     }
    //     micStatus = await Permission.microphone.request();
    //     speechStatus = await Permission.speech.request();
    //   } else if (micStatus.isPermanentlyDenied) {
    //     if (context.mounted) {
    //       // TODO 文言要修正??
    //       String msg = '音声入力を有効にするには、'
    //           '\n[設定] > [マイク] を ON にする必要があります';
    //       bool goToSetting =
    //           await showRequestPermissionDialog(context, message: msg);
    //       // アプリの設定画面を開く
    //       if (goToSetting) {
    //         AppData.instance.isOpeningSettings = true;
    //         await AppSettings.openAppSettings();
    //       }
    //     }
    //   } else if (speechStatus.isPermanentlyDenied) {
    //     if (context.mounted) {
    //       // TODO 文言要修正??
    //       String msg = '音声入力を有効にするには、'
    //           '\n[設定] > [音声認識] を ON にする必要があります';
    //       bool goToSetting =
    //           await showRequestPermissionDialog(context, message: msg);
    //       // アプリの設定画面を開く
    //       if (goToSetting) {
    //         AppData.instance.isOpeningSettings = true;
    //         await AppSettings.openAppSettings();
    //       }
    //     }
    //   } else {
    //     // 一応権限確認
    //     bool hasPermission = await speechToText.hasPermission;
    //     if (hasPermission) {
    //       // 初期化されていなかったら初めに初期化する
    //       if (!speechEnabled.value) {
    //         speechEnabled.value = await speechToText.initialize();
    //       }
    //       // 再生中かどうか
    //       if (speechToText.isListening) {
    //         // 停止
    //         await stopListening();
    //       } else {
    //         // 再生
    //         await startListening();
    //       }
    //     }
    //   }
    // }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              // 空文字以外なら送信可能とする
              if (value.isEmpty) {
                if (canSend.value) {
                  canSend.value = false;
                }
              } else {
                if (!canSend.value) {
                  canSend.value = true;
                }
              }
            },
            controller: controller,
            maxLines: 10,
            minLines: 1,
            decoration: InputDecoration(
              // suffixIcon: controller.text.isEmpty
              //     ? IconButton(
              //         onPressed: onTapMicIcon,
              //         icon: Icon(
              //           Icons.mic,
              //           color: Colors.grey[800],
              //         ),
              //       )
              //     : null,
              hintText: 'Message',
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
          ),
        ),
        // 余白
        const SizedBox(
          width: 10,
        ),
        // 送信ボタン
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: canSend.value ? Colors.black : Colors.grey[400],
          ),
          child: IconButton(
            onPressed: canSend.value
                ? () {
                    // 質問のインスタンスを生成し、dtoに格納
                    Post yourPost = Post.you(content: controller.text);
                    AppData.instance.yourPost = yourPost;
                    AppData.instance.posts.add(yourPost);

                    // dtoに格納したのでTextEditingControllerの中身を空にする
                    controller.clear();
                    // 送信ボタンを非活性にする
                    canSend.value = false;
                    // 再描画の際にデータを再取得できるよう、フラグを下ろす
                    AppData.instance.alreadyLoaded = false;

                    // Streamメソッドを呼び出す
                    getFuture();
                    // setStateNotifierを呼び出す
                    context.read<StateController>().setStateNotify();
                  }
                : null,
            icon: const Icon(
              Icons.arrow_upward,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
