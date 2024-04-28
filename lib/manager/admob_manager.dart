import 'dart:io';
// import 'package:akinatorquiz/view/play_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdManager {
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

class AppOpenAdManager implements AppOpenAdLoadCallback {
  AppOpenAd? _appOpenAd;

  Future<void> loadAd() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[],
    );
    await Future.delayed(const Duration(milliseconds: 1));
    AppOpenAd.load(
      adUnitId: getAppOpenAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenAd?.show().then((value) {
            SystemChrome.setEnabledSystemUIMode(
              SystemUiMode.manual,
              overlays: SystemUiOverlay.values,
            );
          });
        },
        onAdFailedToLoad: (error) {
          // print('App open ad failed to load: $error');
        },
      ),
    );
  }

  String getAppOpenAdUnitId() {
    String bannerUnitId = "";
    if (Platform.isAndroid) {
      // Android のとき
      bannerUnitId = kDebugMode
          ? "ca-app-pub-3940256099942544/5575463023" // Androidのデモ用アプリ起動広告ID
          : "ca-app-pub-3489903136230422/6498119184";
    } else if (Platform.isIOS) {
      // iOSのとき
      bannerUnitId = kDebugMode
          ? "ca-app-pub-3940256099942544/9257395921" // iOSのデモ用アプリ起動広告ID
          : "ca-app-pub-3489903136230422/5231137537";
    }
    return bannerUnitId;
  }

  // void showAdIfLoaded() {
  //   if (_isAdLoaded) {
  //     _appOpenAd?.show();
  //   } else {
  //     loadAd();
  //   }
  // }

  // void onAppOpenAdLoaded(AppOpenAd ad) {
  //   _appOpenAd = ad;
  //   _isAdLoaded = true;
  //   showAdIfLoaded();
  // }

  // void onAppOpenAdFailedToLoad(LoadAdError error) {
  //   print('App open ad failed to load: $error');
  // }

  // @override
  // void onAdClosed() {
  //   _appOpenAd?.dispose();
  //   _isAdLoaded = false;
  //   loadAd();
  // }

  void dispose() {
    _appOpenAd?.dispose();
  }

  @override
  FullScreenAdLoadErrorCallback get onAdFailedToLoad =>
      throw UnimplementedError();

  @override
  GenericAdEventCallback<AppOpenAd> get onAdLoaded =>
      throw UnimplementedError();
}
