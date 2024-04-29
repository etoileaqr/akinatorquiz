// ignore_for_file: no_leading_underscores_for_local_identifiers, non_constant_identifier_names

import 'package:flutter/cupertino.dart';

mixin MyDialog {
  Future<void> showOkDialog(
    BuildContext ctxt, {
    required Widget content,
    bool needTitle = true,
  }) async {
    TextStyle _TextStyle = const TextStyle(color: CupertinoColors.activeBlue);
    await showCupertinoDialog<void>(
      barrierDismissible: true,
      context: ctxt,
      builder: (_) => CupertinoAlertDialog(
        title: needTitle ? const Text('確認') : null,
        content: content,
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(_).pop(),
            isDefaultAction: true,
            child: Text('OK', style: _TextStyle),
          )
        ],
      ),
    );
  }

  Future<bool> showRequestPermissionDialog(
    BuildContext ctxt, {
    required String message,
  }) async {
    TextStyle _TextStyle = const TextStyle(color: CupertinoColors.activeBlue);
    bool? goToSetting = await showCupertinoDialog<bool>(
      barrierDismissible: true, // 領域外タップはnullが返る
      context: ctxt,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('確認'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('キャンセル', style: _TextStyle),
            onPressed: () => Navigator.of(_).pop(false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(_).pop(true),
            child: Text('OK', style: _TextStyle),
          ),
        ],
      ),
    );
    // 領域外タップを考慮して、「?? false」にする
    return goToSetting ?? false;
  }

  Future<int?> showOptionsDialog(
    BuildContext ctxt, {
    required String message,
    required List<Option> optionList,
  }) async {
    TextStyle _TextStyle = const TextStyle(color: CupertinoColors.activeBlue);
    int? selectedOptionId = await showCupertinoDialog<int>(
      barrierDismissible: true, // 領域外タップはnullが返る
      context: ctxt,
      builder: (_) => CupertinoAlertDialog(
        // title: const Text('確認'),
        content: Text(message),
        actions: [
          for (var option in optionList) ...{
            CupertinoDialogAction(
              onPressed: () => Navigator.of(_).pop(option.id),
              isDefaultAction: option.isDefaultAction,
              isDestructiveAction: option.isDestructiveAction,
              child: Text(option.value, style: _TextStyle),
            ),
          },
          CupertinoDialogAction(
            onPressed: () => Navigator.of(_).pop(null),
            isDestructiveAction: true,
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
    // 領域外タップを考慮して、「?? false」にする
    return selectedOptionId;
  }
}

class Option {
  Option({
    required this.id,
    required this.value,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
  });
  final int id;
  final String value;
  final bool isDefaultAction;
  final bool isDestructiveAction;
}
