import 'package:flutter/material.dart';

class WidgetUtil {
  static int getTextLinesLength({
    required String text,
    required TextStyle style,
    required double maxWidth,
    int? maxLines,
  }) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
        maxLines: maxLines);
    tp.layout(maxWidth: maxWidth);
    return tp.computeLineMetrics().length;
  }

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
}
