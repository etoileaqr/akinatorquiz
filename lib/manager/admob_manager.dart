import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobManager {
  BannerAd get bannerAd {
    return BannerAd(
      adUnitId: getAdBannerUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
  }

  String getAdBannerUnitId() {
    String bannerUnitId = "";
    if (Platform.isAndroid) {
      // Android のとき
      bannerUnitId = kDebugMode
          ? "ca-app-pub-3940256099942544/6300978111" // Androidのデモ用バナー広告ID
          : "ca-app-pub-3489903136230422/7032471650";
    } else if (Platform.isIOS) {
      // iOSのとき
      bannerUnitId = kDebugMode
          ? "ca-app-pub-3940256099942544/2934735716" // iOSのデモ用バナー広告ID
          : "ca-app-pub-3489903136230422/8526867794";
    }
    return bannerUnitId;
  }
}
