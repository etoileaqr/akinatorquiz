import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../dto/app_data.dart';
import '../main.dart';
import '../manager/firestore_manager.dart';
import '../my_exception.dart';
import '../util/connection_util.dart';
import 'play_view.dart';

Stream<double> fetchMstFromFirestore() async* {
  // TODO 毎回DBからとってこなければならないのはマズいので、SQLiteに格納する
  // TODO はじめに、ネットワーク接続状況をチェックし、接続がなければ例外をスローする(NoConnectionException)
  await Future.delayed(const Duration(seconds: 1));
  try {
    final canConnect = await ConnectionUtil.checkConnectivityStatus();
    if (!canConnect) {
      throw NoConnectionException();
    }
    yield 0.1;

    // TODO バージョンマスタを見て更新が必要かチェック
    await Future.delayed(const Duration(seconds: 1));
    // 誤字変換マスタを取得
    AppData.instance.typos = await FirestoreManager.getTypos();
    // SQLiteに格納
    yield 0.2;

    // バージョンマスタを見て更新が必要かチェック
    await Future.delayed(const Duration(seconds: 1));
    // 辞書マスタを取得
    AppData.instance.dictMap = await FirestoreManager.getDictionary();
    // SQLiteに格納
    yield 0.3;

    // バージョンマスタを見て更新が必要かチェック
    await Future.delayed(const Duration(seconds: 1));
    // ジャンルマスタを取得
    AppData.instance.genreMap = await FirestoreManager.getGenreMap();
    // SQLiteに格納
    yield 0.4;

    // バージョンマスタを見て更新が必要かチェック
    await Future.delayed(const Duration(seconds: 1));
    // アイテムマスタを取得
    AppData.instance.itemMap =
        await FirestoreManager.getItemMap(genreMap: AppData.instance.genreMap);
    // SQLiteに格納
    yield 0.5;

    // prefsのバージョン情報の変数がnullならマスタがないことになってゲームをプレイできないので、
    // 例外をスローするかどうするか...
  } on NoConnectionException catch (e) {
    print(e);
    if (prefs.getInt('itemMstVer') == null) {
      // この場合どうするかだな・・
    } else {
      // 他は握りつぶしてOK
    }
  } catch (e) {
    // マスタ取得が途中で終わったなど・・
    print(e);
  }

  yield 1.0;
}

class StartUp extends HookWidget {
  const StartUp({super.key});

  @override
  Widget build(BuildContext context) {
    final func = useMemoized(fetchMstFromFirestore);
    final snapshot = useStream(func, initialData: null);

    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasData) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon(Icons.abc),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  const Text(
                    'アキネータークイズ',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).push(CupertinoPageRoute(
                          builder: (context) => const PlayView(),
                        ));
                      },
                      child: const Text('play')),
                  // Container(
                  //   margin: const EdgeInsets.only(bottom: 5),
                  //   child: GestureDetector(
                  //     onTap: () {},
                  //     child: const Text(
                  //       'created by アラキホシノスケ',
                  //       style: TextStyle(fontSize: 12),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      } else {
        return const Scaffold(
          body: Center(
            child: Text('アキネータークイズ'),
          ),
        );
      }
    } else if (snapshot.connectionState == ConnectionState.active) {
      if (snapshot.hasData) {
        double value = snapshot.data!;
        return Scaffold(
          body: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: LinearProgressIndicator(
                // backgroundColor: Colors.grey,
                color: Colors.black,
                value: value,
                minHeight: 2,
              ),
            ),
          ),
        );
      } else {
        return const Scaffold(
          body: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      }
    } else {
      return const Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }
  }
}
