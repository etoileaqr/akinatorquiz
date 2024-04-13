import 'package:flutter/material.dart';

class WidgetUtil {
  // 中身のスタイル
  static TextStyle contentStyle =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
  static double iconRadius = 30;

  // static int getTextLinesLength({
  //   required String text,
  //   required TextStyle style,
  //   required double maxWidth,
  //   int? maxLines,
  // }) {
  //   final tp = TextPainter(
  //       text: TextSpan(text: text, style: style),
  //       textDirection: TextDirection.ltr,
  //       maxLines: maxLines);
  //   tp.layout(maxWidth: maxWidth);
  //   return tp.computeLineMetrics().length;
  // }

  // ユーザーのアイコン（カスタマイズとかダルいから固定にしたいな・・）
  static Container yourIcon({required double radius}) {
    return Container(
      width: radius,
      height: radius,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          'assets/file/test_photo.JPG',
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  // こっちは固定
  static Container chatGptIcon({required double radius}) {
    return Container(
      width: radius,
      height: radius,
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        'assets/file/openai-white-logomark.png',
        fit: BoxFit.fill,
      ),
    );
  }

  // アラキのアイコン
  static Container devIcon({required double radius}) {
    return Container(
      width: radius,
      height: radius,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          'assets/file/test_photo.JPG',
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  // 1回の質問or解答のタイル
  static Widget postTile({
    required bool isChatGpt,
    required String message,
    required double textWidth,
  }) {
    // ユーザー名とかのヘッダースタイル
    TextStyle hStyle = const TextStyle(fontSize: 16, height: 1.6);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // アイコン
          isChatGpt
              ? WidgetUtil.chatGptIcon(radius: iconRadius)
              : WidgetUtil.yourIcon(radius: iconRadius),
          SizedBox(
            width: textWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header
                Text(isChatGpt ? 'ChatGPT' : 'You', style: hStyle),
                // content
                Text(message,
                    overflow: TextOverflow.visible, style: contentStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
