// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomTextFieldDialog extends StatelessWidget {
  const CustomTextFieldDialog({
    Key? key,
    required this.title,
    required this.contentWidget,
    this.cancelActionText,
    this.cancelAction,
    required this.defaultActionText,
    this.action,
  }) : super(key: key);

  final String title;
  final Widget contentWidget;
  final String? cancelActionText;
  final Function? cancelAction;
  final String defaultActionText;
  final Function? action;

  @override
  Widget build(BuildContext context) {
    const key = GlobalObjectKey<FormState>('FORM_KEY');

    if (kIsWeb || Platform.isAndroid) {
      return AlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
            color: CupertinoColors.systemGrey,
          ),
        ),
        content: Form(
          key: key,
          child: contentWidget,
        ),
        actions: [
          if (cancelActionText != null)
            TextButton(
              child: Text(
                cancelActionText!,
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),
              onPressed: () {
                if (cancelAction != null) cancelAction!();
                Navigator.of(context).pop(false);
              },
            ),
          TextButton(
            child: Text(
              defaultActionText,
              style: const TextStyle(color: CupertinoColors.activeBlue),
            ),
            onPressed: () {
              if (key.currentState!.validate()) {
                print('Validate OK');
                if (action != null) action!();
                Navigator.of(context).pop(true);
              } else {
                print('Validate NG');
              }
            },
          ),
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
            color: CupertinoColors.systemGrey,
          ),
        ),
        content: Form(
          key: key,
          child: contentWidget,
        ),
        actions: [
          if (cancelActionText != null)
            CupertinoDialogAction(
              child: Text(
                cancelActionText!,
                style: const TextStyle(color: CupertinoColors.destructiveRed),
              ),
              onPressed: () {
                if (cancelAction != null) cancelAction!();
                Navigator.of(context).pop(false);
              },
            ),
          CupertinoDialogAction(
            child: Text(
              defaultActionText,
              style: const TextStyle(color: CupertinoColors.activeBlue),
            ),
            onPressed: () {
              if (key.currentState!.validate()) {
                print('Validate OK');
                if (action != null) action!();
                Navigator.of(context).pop(true);
              } else {
                print('Validate NG');
              }
            },
          ),
        ],
      );
    }
  }
}
