import 'package:akinatorquiz/model/typo.dart';
import 'package:akinatorquiz/view/admob_init_page.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../constants.dart';
import '../dto/app_data.dart';
import '../main.dart';
import '../manager/firestore_manager.dart';
import '../manager/sqlite_manager.dart';
import '../model/version.dart';
import '../my_exception.dart';
import '../util/connection_util.dart';
import 'play_view.dart';

Stream<double> fetchMstFromFirestore() async* {
  // TODO 毎回DBからとってこなければならないのはマズいので、SQLiteに格納する
  // TODO はじめに、ネットワーク接続状況をチェックし、接続がなければ例外をスローする(NoConnectionException)
  try {
    final canConnect = await ConnectionUtil.checkConnectivityStatus();
    if (!canConnect) {
      throw NoConnectionException();
    }
    yield 0.1;

    List<dynamic> allLocalVersions = await sqliteDb.query(Constants.VERSIONS);
    if (allLocalVersions.isEmpty) {
      await SqliteManager.initMstVersions();
    }

    // Firestoreからバージョン情報を取得する
    Map<String, Version> versionMap = await FirestoreManager.fetchVersions();

    // ①誤字変換マスタ
    try {
      // 1.SQLiteからバージョンを取得
      List<dynamic> sqTyposTmp =
          await SqliteManager.getLocalMstVersion(mstName: Constants.TYPOS);
      Version sqTypoVersion = Version.fromJson(sqTyposTmp.first);
      // 2.Firestoreからバージョンを取得
      Version fsTypoVersion = versionMap[Constants.TYPOS]!;
      List<Typo> typos = [];
      // 3.Firestoreのバージョンの方が大きい場合は、Firestoreから取得する
      if (fsTypoVersion.version > sqTypoVersion.version) {
        typos = await FirestoreManager.fetchTypos();
        await SqliteManager.deleteAndInsertTypoMst(typos: typos);
        await SqliteManager.updateMstVersion(
          map: fsTypoVersion.toJson(),
          mstName: Constants.TYPOS,
        );
      } else {
        List<dynamic> l = await sqliteDb.query(Constants.TYPOS);
        typos = l.map((data) => Typo.fromJson(data)).toList();
      }
      // 4.DTOで保持
      AppData.instance.typos = typos;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      yield 0.2;
    }

    // ②辞書マスタ
    // try {
    //   // 1.SQLiteからバージョンを取得
    //   List<dynamic> sqDictTmp =
    //       await SqliteManager.getLocalMstVersion(mstName: Constants.DICTIONARY);
    //   Version sqDictVersion = Version.fromJson(sqDictTmp.first);
    //   // 2.Firestoreからバージョンを取得
    //   Version fsDictVersion = versionMap[Constants.DICTIONARY]!;
    //   Map<String, Dictionary> dictMap = {};
    //   // 3.Firestoreのバージョンの方が大きい場合は、Firestoreから取得する
    //   if (fsDictVersion.version > sqDictVersion.version) {
    //     dictMap = await FirestoreManager.fetchDictionary();
    //     await SqliteManager.deleteAndInsertTypoMst(typos: dicts);
    //     await SqliteManager.updateMstVersion(
    //       map: fsDictVersion.toJson(),
    //       mstName: Constants.DICTIONARY,
    //     );
    //   } else {
    //     List<dynamic> l = await sqliteDb!.query(Constants.DICTIONARY);
    //     dicts = l.map((data) => Dictionary.fromJson(data));
    //   }
    //   // 4.DTOで保持
    //   AppData.instance.typos = typos;
    // } catch (e) {
    // } finally {
    //   yield 0.3;
    // }
    AppData.instance.dictMap = await FirestoreManager.fetchDictionary();
    yield 0.4;
    // SQLiteに格納

    // TODO バージョンマスタを見て更新が必要かチェック
    // await Future.delayed(const Duration(seconds: 1));
    // ジャンルマスタを取得
    AppData.instance.genreMap = await FirestoreManager.fetchGenreMap();
    // SQLiteに格納
    yield 0.6;

    // TODO バージョンマスタを見て更新が必要かチェック
    // await Future.delayed(const Duration(seconds: 1));
    // アイテムマスタを取得
    AppData.instance.itemMap = await FirestoreManager.fetchItemMap(
        genreMap: AppData.instance.genreMap);
    // SQLiteに格納
    yield 0.8;

    // prefsのバージョン情報の変数がnullならマスタがないことになってゲームをプレイできないので、
    // 例外をスローするかどうするか...
  } on NoConnectionException catch (e) {
    if (kDebugMode) {
      print(e);
    }
    if (prefs.getInt('itemMstVer') == null) {
      // この場合どうするかだな・・
    } else {
      // 他は握りつぶしてOK
    }
  } catch (e) {
    // マスタ取得が途中で終わったなど・・
    if (kDebugMode) {
      print(e);
    }
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
        // ATT未設定かどうかチェック
        // final status = await AppTrackingTransparency
        //     .trackingAuthorizationStatus;
        // if (context.mounted) {
        // 未設定の場合、設定ページへ飛ばす
        if (attStatus == TrackingStatus.notDetermined) {
          return const AdmobInitPage();
          // Navigator.of(context).push(CupertinoPageRoute(
          //   builder: (context) => const AdmobInitPage(),
          // ));
        } else {
          return const PlayView();
          // それ以外は通常のプレイ画面へ
          // Navigator.of(context).push(CupertinoPageRoute(
          //   builder: (context) => const PlayView(),
          // ));
        }
        // }
        // return Scaffold(
        //   body: SafeArea(
        //     child: Center(
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //         // crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //           // Icon(Icons.abc),
        //           SizedBox(height: MediaQuery.of(context).size.height * 0.1),
        //           const Text(
        //             'アキネータークイズ',
        //             style: TextStyle(fontSize: 20),
        //           ),
        //           SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        //           TextButton(
        //               onPressed: () async {
        //                 // ATT未設定かどうかチェック
        //                 final status = await AppTrackingTransparency
        //                     .trackingAuthorizationStatus;
        //                 if (context.mounted) {
        //                   // 未設定の場合、設定ページへ飛ばす
        //                   if (status == TrackingStatus.notDetermined) {
        //                     Navigator.of(context).push(CupertinoPageRoute(
        //                       builder: (context) => const AdmobInitPage(),
        //                     ));
        //                   } else {
        //                     // それ以外は通常のプレイ画面へ
        //                     Navigator.of(context).push(CupertinoPageRoute(
        //                       builder: (context) => const PlayView(),
        //                     ));
        //                   }
        //                 }
        //               },
        //               child: const Text('play')),
        //           // Container(
        //           //   margin: const EdgeInsets.only(bottom: 5),
        //           //   child: GestureDetector(
        //           //     onTap: () {},
        //           //     child: const Text(
        //           //       'created by アラキホシノスケ',
        //           //       style: TextStyle(fontSize: 12),
        //           //     ),
        //           //   ),
        //           // ),
        //         ],
        //       ),
        //     ),
        //   ),
        // );
      } else {
        return const Scaffold(
          body: Center(
            child: Text('ネットワーク接続の確認をお願いします!!'),
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
