import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../context_extension.dart';
import 'my_dialog.dart';
import 'play_view.dart';

class AdmobInitPage extends HookWidget with MyDialog {
  const AdmobInitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isOpeningATTdialog = useState<bool>(false);

    double h = context.screenHeight * 0.5;
    double r = 529 / 757;
    double w = h * r;

    if (isOpeningATTdialog.value) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(),
      );
    } else {
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: w,
                  height: h,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset('assets/file/att_dlg.PNG'),
                  ),
                ),
                SizedBox(
                  height: context.screenHeight * 0.03,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(
                      w,
                      context.screenHeight * 0.05,
                    ),
                    backgroundColor: Colors.purple[300],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: context.isTablet() ? 26 : 20,
                    ),
                  ),
                  onPressed: () async {
                    isOpeningATTdialog.value = true;
                    await Future.delayed(const Duration(milliseconds: 100));
                    //ダイアログ表示
                    var status = await AppTrackingTransparency
                        .requestTrackingAuthorization();
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
              ]),
        ),
      );
    }
  }
}
