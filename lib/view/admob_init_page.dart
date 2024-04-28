import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'my_dialog.dart';
import 'play_view.dart';

class AdmobInitPage extends HookWidget with MyDialog {
  const AdmobInitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isOpeningATTdialog = useState<bool>(false);

    if (isOpeningATTdialog.value) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.green,
        // TODO bodyのデザイン整える
        body: Center(
          child: ElevatedButton(
            child: const Text('OK'),
            onPressed: () async {
              isOpeningATTdialog.value = true;
              await Future.delayed(const Duration(milliseconds: 100));
              //ダイアログ表示
              var status =
                  await AppTrackingTransparency.requestTrackingAuthorization();
              if (kDebugMode) {
                print(status);
              }
              if (context.mounted) {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => const PlayView(),
                ));
              }
            },
          ),
        ),
      );
    }
  }
}
