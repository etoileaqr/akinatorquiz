import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'CHAT_GPT_TOKEN', obfuscate: true)
  static String chatGptToken = _Env.chatGptToken;
}
