import 'dart:io';
import 'package:akinatorquiz/view/play_view.dart';
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
  // bool _isAdLoaded = false;

  void loadAd() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: <SystemUiOverlay>[],
    );
    AppOpenAd.load(
      adUnitId: getAppOpenAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          // _isAdLoaded = true;
          _appOpenAd?.show();
        },
        onAdFailedToLoad: (error) {
          // print('App open ad failed to load: $error');
        },
      ),
    );
    isAppOpenAdShowing = true;
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
  // TODO: implement onAdFailedToLoad
  FullScreenAdLoadErrorCallback get onAdFailedToLoad =>
      throw UnimplementedError();

  @override
  // TODO: implement onAdLoaded
  GenericAdEventCallback<AppOpenAd> get onAdLoaded =>
      throw UnimplementedError();
}
