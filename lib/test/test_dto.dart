class TestDto {
  // シングルトンインスタンスを保持する静的な変数
  static final TestDto instance = TestDto._internal();

  // インスタンスを取得するためのファクトリコンストラクタ
  // 常に同じインスタンスを返す
  factory TestDto({bool shouldReset = false}) {
    if (shouldReset) {
      return TestDto._reset();
    }
    return instance;
  }

  // インスタンス生成時に使用されるプライベートな名前付きコンストラクタ
  TestDto._internal();
  TestDto._reset();
  String test = '';
}
