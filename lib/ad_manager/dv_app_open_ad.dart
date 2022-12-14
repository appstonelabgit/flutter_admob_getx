import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DvAppOpenAd {
  AppOpenAd? _appOpenAd;
  String _appOpenId = "";
  int _retryDelayInMiliSec = 0;

  bool _isShowingAd = false;

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  /// Load an AppOpenAd.
  void loadAdAppOpen(String appOpenId, int retryDelayInMiliSec) {
    _appOpenId = appOpenId;
    _retryDelayInMiliSec = retryDelayInMiliSec;
    AppOpenAd.load(
      adUnitId: appOpenId,
      orientation: AppOpenAd.orientationPortrait,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("AppOpenAd loaded successfully.");
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint(
              'Ad load app open failed (code=${error.code} message=${error.message})');
          _appOpenAd = null;
          Future.delayed(Duration(milliseconds: retryDelayInMiliSec), () {
            loadAdAppOpen(appOpenId, retryDelayInMiliSec);
          });
        },
      ),
    );
  }

  void showAdIfAvailable() {
    if (!isAdAvailable) {
      debugPrint('Tried to show ad before available.');
      loadAdAppOpen(_appOpenId, _retryDelayInMiliSec);
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAdAppOpen(_appOpenId, _retryDelayInMiliSec);
      },
    );
    _appOpenAd?.show();
  }
}
