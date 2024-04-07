// // ignore_for_file: non_constant_identifier_names, no_leading_underscores_for_local_identifiers, unnecessary_this

// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:provider/provider.dart';

// import '../dto/app_data.dart';
// import '../model/post.dart';
// import '../util/dev_util.dart';

// // TextFormField側から更新をかけるために、
// // ChangeNotifierを使うことにした。
// class StateController with ChangeNotifier {
//   void setStateNotify() {
//     notifyListeners();
//   }
// }

// class Home2 extends StatefulWidget {
//   const Home2({super.key});

//   @override
//   State<Home2> createState() => _Home2State();
// }

// class _Home2State extends State<Home2> {
//   final ScrollController _scrollController = ScrollController();
//   Stream<String>? _data;
//   // 一度だけ最下部までいくようにフラグを用意
//   bool _toLastIndex = false;
//   // 初回起動時にボタンを押す用
//   bool _isPlaying = false;

//   @override
//   void initState() {
//     super.initState();
//     // 前回のデータは削除しておこうかな
//     AppData.instance.posts = [];
//   }

//   @override
//   void dispose() {
//     // scrollControllerの破棄を忘れない。
//     _scrollController.dispose();
//     super.dispose();
//   }

//   // Streamの取得メソッド
//   void _getStream() {
//     _data = DevUtil.getFakeChatGptResponse().asBroadcastStream();
//   }

//   // キーボードを出している都合上、
//   // 新しいTileが画面外にいってしまうので、
//   // 若干のラグを持たせて最下部までスクロールさせる
//   void _goToLast() async {
//     if (_toLastIndex) {
//       _toLastIndex = false;
//       await Future.delayed(const Duration(milliseconds: 200));
//       _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // アイコンのサイズ
//     double radius = 30;
//     // 条件分岐の基準値を0にするとキーボードが閉じ切ってからレイアウトが調整され
//     // ガタンとなってしまうので、基準値を50に設定しておく
//     bool isKeyboardShown = (MediaQuery.of(context).viewInsets.bottom > 50);

//     // ユーザーのアイコン（カスタマイズとかダルいから固定にしたいな・・）
//     Container yourIcon() => Container(
//           width: radius,
//           height: radius,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(15),
//             child: Image.asset(
//               'assets/file/test_photo.JPG',
//               fit: BoxFit.fill,
//             ),
//           ),
//         );

//     // こっちは固定
//     Container chatGptIcon() => Container(
//           width: radius,
//           height: radius,
//           padding: const EdgeInsets.all(6),
//           decoration: const BoxDecoration(
//             color: Colors.black,
//             shape: BoxShape.circle,
//           ),
//           child: Image.asset(
//             'assets/file/openai-white-logomark.png',
//             fit: BoxFit.fill,
//           ),
//         );

//     // 1回の質問or解答のタイル
//     Widget _Tile({required bool isChatGpt, required String message}) =>
//         Container(
//           margin: const EdgeInsets.only(bottom: 20),
//           child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 // アイコン
//                 isChatGpt ? chatGptIcon() : yourIcon(),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // 名前
//                       Text(
//                         isChatGpt ? 'ChatGPT' : 'You',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       // 内容
//                       Text(
//                         message,
//                         overflow: TextOverflow.visible,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           height: 1.6,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ]),
//         );

//     return ChangeNotifierProvider<StateController>(
//       create: (_) => StateController(),
//       child: GestureDetector(
//         // キーボード外をタップしたらキーボードを閉じる
//         onTap: () => primaryFocus?.unfocus(),
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('ホーム'),
//           ),
//           body: Consumer<StateController>(builder: (context, ctrl, child) {
//             if (_isPlaying || AppData.instance.posts.isNotEmpty) {
//               _toLastIndex = true;
//               _goToLast();
//             }
//             return (!_isPlaying && AppData.instance.posts.isEmpty)
//                 ? ElevatedButton(
//                     onPressed: () async {
//                       // ランダムに都市を選択し、dtoに格納
//                       int i = Random().nextInt(AppData.instance.cities.length);
//                       AppData.instance.city = AppData.instance.cities[i];

//                       // 最初の1行目だけこちらで生成し、dtoに格納
//                       Post post = Post(
//                         post: '都市を選択しました。',
//                         isChatGpt: true,
//                       );
//                       AppData.instance.posts.add(post);
//                       // ゲームスタート
//                       _isPlaying = true;
//                       // 画面の再描画
//                       context.read<StateController>().setStateNotify();
//                     },
//                     child: const Text('Game Start'),
//                   )
//                 : Column(children: [
//                     Expanded(
//                       child: Scrollbar(
//                         // Scrollbar側にもcontrollerを設定する必要あり
//                         controller: _scrollController,
//                         child: SingleChildScrollView(
//                           // controllerを設定
//                           controller: _scrollController,
//                           child: StreamBuilder(
//                               stream: _data,
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.done) {
//                                   if (snapshot.hasData) {
//                                     // 取得が終わってから格納する
//                                     // 何度も追加してしまわないように、フラグを見る
//                                     if (!AppData.instance.alreadyLoaded) {
//                                       String str = snapshot.data!;
//                                       // 取得したデータをもとにインスタンスを作成し、dtoに格納
//                                       Post post =
//                                           Post(post: str, isChatGpt: true);
//                                       AppData.instance.posts.add(post);
//                                       // 追加が完了したのでフラグを立てる
//                                       AppData.instance.alreadyLoaded = true;
//                                     }

//                                     return Column(
//                                       children: [
//                                         for (Post p in AppData.instance.posts)
//                                           _Tile(
//                                               isChatGpt: p.isChatGpt,
//                                               message: p.post),
//                                       ],
//                                     );
//                                   } else {
//                                     return Column(
//                                       children: [
//                                         for (Post p in AppData.instance.posts)
//                                           _Tile(
//                                               isChatGpt: p.isChatGpt,
//                                               message: p.post),
//                                       ],
//                                     );
//                                   }
//                                 } else if (snapshot.connectionState ==
//                                     ConnectionState.active) {
//                                   // 取得中のデータ
//                                   String chatGptAnswer = snapshot.data!;
//                                   return Column(
//                                     children: [
//                                       for (Post p in AppData.instance.posts)
//                                         _Tile(
//                                             isChatGpt: p.isChatGpt,
//                                             message: p.post),
//                                       Column(
//                                         children: [
//                                           _Tile(
//                                               isChatGpt: true,
//                                               message: chatGptAnswer),
//                                         ],
//                                       ),
//                                     ],
//                                   );
//                                 } else {
//                                   return Column(
//                                     children: [
//                                       for (Post p in AppData.instance.posts)
//                                         _Tile(
//                                             isChatGpt: p.isChatGpt,
//                                             message: p.post),
//                                     ],
//                                   );
//                                 }
//                               }),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.only(
//                         top: 10,
//                         bottom: isKeyboardShown ? 10 : 30,
//                       ),
//                       child: TextInputWidget(getStream: _getStream),
//                     ),
//                   ]);
//           }),
//         ),
//       ),
//     );
//   }
// }

// /// TextFormField側のウィジェット
// // 画面全体を再描画しないように分ける
// class TextInputWidget extends HookWidget {
//   const TextInputWidget({super.key, required this.getStream});
//   // こちらからStreamメソッドを呼び出せるよう、関数をパラメータで渡す
//   final Function getStream;

//   @override
//   Widget build(BuildContext context) {
//     final controller = useTextEditingController();
//     // 空文字で送れないようにフラグを用意
//     final canSend = useState<bool>(false);
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: MediaQuery.of(context).size.width * 0.8,
//           child: TextFormField(
//             onChanged: (value) {
//               // 空文字以外なら送信可能とする
//               if (value.isEmpty) {
//                 canSend.value = false;
//               } else {
//                 canSend.value = true;
//               }
//             },
//             controller: controller,
//             maxLines: 10,
//             minLines: 1,
//             decoration: InputDecoration(
//               suffixIcon: controller.text.isEmpty
//                   ? IconButton(
//                       onPressed: () async {},
//                       icon: Icon(
//                         Icons.mic,
//                         color: Colors.grey[800],
//                       ),
//                     )
//                   : null,
//               hintText: 'Message',
//               hintStyle: const TextStyle(color: Colors.grey),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//               border: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(20),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         // 余白
//         const SizedBox(
//           width: 10,
//         ),
//         // 送信ボタン
//         Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: controller.text.isEmpty ? Colors.grey[400] : Colors.black,
//           ),
//           child: IconButton(
//             onPressed: () {
//               // 質問のインスタンスを生成し、dtoに格納
//               Post yourPost = Post(
//                 post: controller.text,
//                 isChatGpt: false,
//               );
//               AppData.instance.posts.add(yourPost);
//               // dtoに格納したのでTextEditingControllerの中身を空にする
//               controller.clear();
//               // 送信ボタンを非活性にする
//               canSend.value = false;
//               // 再描画の際にデータを再取得できるよう、フラグを下ろす
//               AppData.instance.alreadyLoaded = false;
//               // setStateNotifierを呼び出す
//               context.read<StateController>().setStateNotify();
//               // Streamメソッドを呼び出す
//               getStream();
//             },
//             icon: const Icon(
//               Icons.arrow_upward,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
