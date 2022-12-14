import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DvInterstitialAds {
  InterstitialAd? _interstitialAd;
  String _interstitialId = "";
  int _retryDelayInMiliSec = 0;

  //---------------------------CreateInterstitial Ad-------------------------//
  void loadInterstitialAd(String interstitialId, int retryDelayInMiliSec) {
    _interstitialId = interstitialId;
    _retryDelayInMiliSec = retryDelayInMiliSec;

    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('==================$ad loaded================');
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint(
              'Interstitial: Ad load failed (code=${error.code} message=${error.message})');
          _interstitialAd = null;
          Future.delayed(Duration(milliseconds: _retryDelayInMiliSec), () {
            loadInterstitialAd(_interstitialId, _retryDelayInMiliSec);
          });
        },
      ),
    );
  }

  //----------------------------------------Show ads after every 3rd tap------------------------------//
  void showInterstitialAd({
    required Function successCallBack,
    required Function adLoadErrorCallBack,
  }) {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      adLoadErrorCallBack();
      return;
    }
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        //! On successfully dismissed
        debugPrint(
            "******************** onAdDismissedFullScreenContent *******************************");
        debugPrint('$ad onAdDismissedFullScreenContent.');

        successCallBack();

        ad.dispose();
        loadInterstitialAd(_interstitialId, _retryDelayInMiliSec);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        //! On Failed to show
        adLoadErrorCallBack();
        ad.dispose();
        debugPrint(
            'Interstitial: Ad load failed (code=${error.code} message=${error.message})');
        Future.delayed(Duration(milliseconds: _retryDelayInMiliSec), () {
          loadInterstitialAd(_interstitialId, _retryDelayInMiliSec);
        });
      },
    );

    _interstitialAd?.show();
    _interstitialAd = null;
  }
}
