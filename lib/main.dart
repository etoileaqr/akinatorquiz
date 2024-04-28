import 'dart:io';
import 'package:akinatorquiz/dto/app_data.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'env/env.dart';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'manager/sqlite_manager.dart';
import 'view/start_up.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebaseの初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // SharedPreferencesのインスタンスを取得
  prefs = await SharedPreferences.getInstance();
  // エミュレーターかどうか
  isEmulator = await distinguishIfIsEmulator();
  runApp(const MyApp());
  // SQLiteDBのインスタンスを取得
  sqliteDb = await SqliteManager.openAndGetDbInstance();
  // テーブル作成
  await SqliteManager.createTables();

  MobileAds.instance.initialize();

  // 開発用
  // List<List<String>> li = await FileUtil.loadCsv('assets/dev/cities.csv');
  // List<Content> cList = [];
  // for (var v in li) {
  //   Content c = Content(doc: v[0], scope: v[1], name: v[2]);
  //   cList.add(c);
  // }
  // await DevUtil().insertMstToDb(
  //   docName: 'subjects',
  //   collectionName: 'world_cities',
  //   list: cList,
  // );

  AppData.instance.isOpeningSettings = false;
}

/* SharedPreferencesのinstance */
late SharedPreferences prefs;
/* Firebase.Firestoreのinstance */
final firestore = FirebaseFirestore.instance;
/* SQLiteのインスタンス */
late Database sqliteDb;
/* gitに公開するので実際のトークンは伏せておきます。 */
// const token = 'Actual TOKEN is supposed to be written here';
final openAI = OpenAI.instance.build(
  token: Env.chatGptToken,
  baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
);
// 開発用: エミュレータかどうか
bool isEmulator = false;

// Future<void> sqliteInitialize() async {
//   // テーブル作成
//   sqliteDb = await SqliteManager.createTables(sqls: {
//     // 'assets/sql/CREATE_CITIES.sql',
//     'assets/sql/CREATE_POSTS.sql',
//   });

//   // // 開発用にいつでも消せるような処理を入れておく
//   // await AppData.instance.sDb!.execute("DROP TABLE IF EXISTS cities");
//   // await sqliteDb!.execute("DROP TABLE IF EXISTS posts");
// }

Future<bool> distinguishIfIsEmulator() async {
  if (Platform.isIOS) {
    final deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo info = await deviceInfo.iosInfo;
    return !info.isPhysicalDevice;
  } else if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    return !info.isPhysicalDevice;
  } else {
    return true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      backgroundColor: Colors.black,
      // splashIconSize: MediaQuery.of(context).size.width * 0.5,
      splash: SizedBox(
        // color: Colors.blue,
        width: MediaQuery.of(context).size.width * 0.5,
        height: double.infinity,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(
              'assets/file/powered-by-openai-badge-outlined-on-dark.png'),
        ),
      ),
      duration: 5000,
      animationDuration: const Duration(milliseconds: 2500),
      nextScreen: const StartUp(),
    );
  }
}


// speech to text をテキトーに調べたときの残骸
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   SpeechToText _speechToText = SpeechToText();
//   bool _speechEnabled = false;
//   String _lastWords = '';

//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }

//   /// This has to happen only once per app
//   void _initSpeech() async {
//     _speechEnabled = await _speechToText.initialize();
//     setState(() {});
//   }

//   /// Each time to start a speech recognition session
//   void _startListening() async {
//     await _speechToText.listen(onResult: _onSpeechResult);
//     setState(() {});
//   }

//   /// Manually stop the active speech recognition session
//   /// Note that there are also timeouts that each platform enforces
//   /// and the SpeechToText plugin supports setting timeouts on the
//   /// listen method.
//   void _stopListening() async {
//     await _speechToText.stop();
//     setState(() {});
//   }

//   /// This is the callback that the SpeechToText plugin calls when
//   /// the platform returns recognized words.
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _lastWords = result.recognizedWords;
//     });
//   }

//   Future<String> _getChatGptResponse() async {
//     String content = 'こんにちは';

//     // try{}
//     // final response = await openAI.onChatCompletion(
//     //   request: ChatCompleteText(
//     //     model: GptTurboChatModel(),
//     //     messages: [
//     //       Messages(
//     //         role: Role.system,
//     //         content: content,
//     //       )
//     //     ],
//     //     maxToken: 100,
//     //   ),
//     // );

//     // String text1 = response?.choices.last.message?.content ?? '';

//     return content;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text('世界地図アキネーター'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               'aaa',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             Text(
//               // If listening is active show the recognized words
//               _speechToText.isListening
//                   ? '$_lastWords'
//                   // If listening isn't active but could be tell the user
//                   // how to start it, otherwise indicate that speech
//                   // recognition is not yet ready or not supported on
//                   // the target device
//                   : _speechEnabled
//                       ? 'Tap the microphone to start listening...'
//                       : 'Speech not available',
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed:
//             // If not yet listening for speech start, otherwise stop
//             _speechToText.isNotListening ? _startListening : _stopListening,
//         tooltip: 'Listen',
//         child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   onPressed: () {},
//       //   tooltip: 'Increment',
//       //   child: const Icon(Icons.add),
//       // ),
//     );
//   }
// }
