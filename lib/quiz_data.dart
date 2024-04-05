class QuizData {
  const QuizData({required this.city});
  // シングルトンインスタンスを保持する静的な変数
  // static final QuizData instance = QuizData._internal();

  // インスタンスを取得するためのファクトリコンストラクタ
  // 常に同じインスタンスを返す
  // factory QuizData() {
  //   return instance;
  // }

  // インスタンス生成時に使用されるプライベートな名前付きコンストラクタ
  // QuizData._internal();

  final String city;
}
