// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

import 'dto/app_data.dart';
import 'manager/firestore_manager.dart';
import 'manager/sqlite_util.dart';
import 'view/play_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  prefs = await SharedPreferences.getInstance();
  // TODO あとでSplashScreen→起動画面の時の処理に移行する
  await fetchMstFromFirestore();

  runApp(const MyApp());

  await sqliteInitialize();
}

/* SharedPreferencesのinstance */
late SharedPreferences prefs;
/* Firebase.Firestoreのinstance */
final firestore = FirebaseFirestore.instance;
/* SQLiteのインスタンス */
Database? sqliteDb;
/* gitに公開するので実際のトークンは伏せておきます。 */
const token = 'Actual TOKEN is supposed to be written here';
final openAI = OpenAI.instance.build(
  token: token,
  baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 20)),
);

Future<void> fetchMstFromFirestore() async {
  AppData.instance.typos = await FirestoreManager.getTypos();
  AppData.instance.dictMap = await FirestoreManager.getDictionary();
  AppData.instance.genreMap = await FirestoreManager.getGenreMap();
  AppData.instance.itemMap =
      await FirestoreManager.getItemMap(genreMap: AppData.instance.genreMap);
}

Future<void> sqliteInitialize() async {
  // テーブル作成
  sqliteDb = await SqliteManager.createTables(sqls: {
    // 'assets/sql/CREATE_CITIES.sql',
    'assets/sql/CREATE_POSTS.sql',
  });

  // // 開発用にいつでも消せるような処理を入れておく
  // await AppData.instance.sDb!.execute("DROP TABLE IF EXISTS cities");
  // await AppData.instance.sDb!.execute("DROP TABLE IF EXISTS posts");
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
    //TODO AnimatedSplashScreenで実装する
    return Scaffold(
      appBar: AppBar(
        title: const Text('テスト'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => const PlayView(),
              ),
            );
          },
          child: const Text('ホーム画面へ遷移'),
        ),
      ),
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
