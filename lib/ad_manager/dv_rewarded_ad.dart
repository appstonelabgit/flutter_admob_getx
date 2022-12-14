import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class DvRewardedAd {
  RewardedAd? _rewardedAd;

  String _rewardedAdId = "";
  int _retryDelayInMiliSec = 0;

  //! ----- ------  ------- Create Rewarded Ad ------- -- -- -- -- - -- -- - -- - - --
  void loadRewardedAd(String rewardedAdId, int retryDelayInMiliSec) {
    _rewardedAdId = rewardedAdId;
    _retryDelayInMiliSec = retryDelayInMiliSec;

    RewardedAd.load(
      adUnitId: rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback:
          RewardedAdLoadCallback(onAdLoaded: (RewardedAd ad) {
        debugPrint('==================$ad loaded================');
        _rewardedAd = ad;
        _rewardedAd?.setImmersiveMode(true);
      }, onAdFailedToLoad: (LoadAdError error) {
        debugPrint(
            'Rewarded: Ad load failed (code=${error.code} message=${error.message})');
        Future.delayed(Duration(milliseconds: retryDelayInMiliSec), () {
          loadRewardedAd(_rewardedAdId, _retryDelayInMiliSec);
        });
      }),
    );
  }

  //! ________________________________________ Load Rewarded Ad ________________________________________________________
  void showRewardedAd(
      {required Function successCallBack,
      required Function adLoadErrorCallBack,
      required Function rewardedCallBack}) {
    if (_rewardedAd == null) {
      debugPrint("Warning: attempt to show rewarded before loaded.");
      adLoadErrorCallBack();
      return;
    }
    _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          debugPrint('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        successCallBack();
        ad.dispose();
        loadRewardedAd(_rewardedAdId, _retryDelayInMiliSec);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        adLoadErrorCallBack();
        ad.dispose();
        debugPrint(
            'Rewarded: Ad load failed (code=${error.code} message=${error.message})');
        Future.delayed(Duration(milliseconds: _retryDelayInMiliSec), () {
          loadRewardedAd(_rewardedAdId, _retryDelayInMiliSec);
        });
      },
      onAdImpression: (RewardedAd ad) => debugPrint('$ad impression occurred.'),
    );

    _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
      debugPrint("reward the user for watching an ad");
      rewardedCallBack();
    });
    _rewardedAd = null;
  }
}
