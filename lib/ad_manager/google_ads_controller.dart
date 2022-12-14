import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './dv_app_open_ad.dart';
import '../ad_manager/dv_interstitial_ad.dart';
import '../ad_manager/dv_rewarded_ad.dart';
import 'dv_app_lifecycle.dart';

enum AdType {
  banner,
  native,
  inter,
  rewarded,
  appOpen,
}

class GoogleAdsController extends GetxController {
  String _bannerAndroid = "";
  String _interAndroid = "";
  String _nativeAndroid = "";
  String _appOpenAndroid = "";
  String _rewardedAdAndroid = "";

  final _banneriOS = "";
  final _interiOS = "";
  final _nativeiOS = "";
  final _appOpeniOS = "";
  final _rewardedAdiOS = "";

  final int retryDelayInMiliSec = 10000;

  bool _showNavigationAds = false;
  int _navigationAdsCount = 1;
  int _navigationAdsShownCount = 0;

  late DvInterstitialAds _dvInterstitialAds;
  late DvRewardedAd _dvRewardedAd;

  late AppLifecycle _appLifecycleReactor;

  @override
  void onInit() {
    super.onInit();
    FirebaseDatabase database = FirebaseDatabase.instance;
    _firebaseSetup(database);
  }

  Future<void> _firebaseSetup(FirebaseDatabase database) async {
    await _fetchNavVariablesFromFirebase(database);

    await _fetAdIdFromFirebase(AdType.native, database);
    await _fetAdIdFromFirebase(AdType.appOpen, database);
    await _fetAdIdFromFirebase(AdType.inter, database);
    await _fetAdIdFromFirebase(AdType.rewarded, database);
    await _fetAdIdFromFirebase(AdType.banner, database);

    _dvInterstitialAds = DvInterstitialAds()
      ..loadInterstitialAd(getInterId(), retryDelayInMiliSec);
    _dvRewardedAd = DvRewardedAd()
      ..loadRewardedAd(getRewardedAdId(), retryDelayInMiliSec);

    //! AppOpen -----------------------------
    DvAppOpenAd appOpenAdManager = DvAppOpenAd()
      ..loadAdAppOpen(getAppOpenId(), retryDelayInMiliSec);

    _appLifecycleReactor = AppLifecycle(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
    //! AppOpen -----------------------------
  }

  //! ---------------------- Ads Methods Start ----------------------

  // ---------------------- Rewarded ----------------------

  void showRewardedAd({
    required Function successCallBack,
    required Function adLoadErrorCallBack,
    required Function rewardCallBack,
  }) {
    _dvRewardedAd.showRewardedAd(
      successCallBack: successCallBack,
      rewardedCallBack: rewardCallBack,
      adLoadErrorCallBack: adLoadErrorCallBack,
    );
  }

  // ---------------------- Interstitial ----------------------

  void showInterstitial({
    required Function successCallBack,
    required Function adLoadErrorCallBack,
  }) {
    _dvInterstitialAds.showInterstitialAd(
      successCallBack: successCallBack,
      adLoadErrorCallBack: adLoadErrorCallBack,
    );
  }

  //---------------------------------------- Show Ads on transition ---------------------------------//
  void showAdOnNavigation() {
    _navigationAdsShownCount++;
    if (_showNavigationAds &&
        _navigationAdsShownCount % _navigationAdsCount == 0) {
      _dvInterstitialAds.showInterstitialAd(
        successCallBack: () {},
        adLoadErrorCallBack: () {},
      );
    }
  }

  //! ---------------------- Firebase Methods Starts ----------------------
  Future<void> _fetchNavVariablesFromFirebase(FirebaseDatabase database) async {
    final navigationAdsRef = database.ref("showNavigationAds");
    final navigationAdsSnap = await navigationAdsRef.get();
    if (navigationAdsSnap.exists) {
      _showNavigationAds = navigationAdsSnap.value as bool;
    }

    navigationAdsRef.onValue.listen((DatabaseEvent event) {
      _showNavigationAds = event.snapshot.value as bool;
    });

    final navigationAdsCountRef = database.ref("navigationAdsCount");
    final navigationAdsCountSnap = await navigationAdsCountRef.get();
    if (navigationAdsSnap.exists) {
      _navigationAdsCount = int.parse("${navigationAdsCountSnap.value ?? 1}");
    }

    navigationAdsCountRef.onValue.listen((DatabaseEvent event) {
      _navigationAdsCount = int.parse("${event.snapshot.value ?? 1}");
    });
  }

  Future<void> _fetAdIdFromFirebase(
      AdType adType, FirebaseDatabase database) async {
    final appOpenRef = database.ref(adType.name);
    final appOpenSnap = await appOpenRef.get();
    if (appOpenSnap.exists) {
      _setAdIds(adType, "${appOpenSnap.value ?? ""}");
    }
    appOpenRef.onValue.listen((DatabaseEvent event) {
      _setAdIds(adType, "${event.snapshot.value ?? ""}");
    });
  }

  //! ---------------------- Firebase Methods Ends ----------------------

  void _setAdIds(AdType adType, String value) {
    debugPrint("adType name is ${adType.name}, and it's value $value");
    switch (adType) {
      case AdType.banner:
        _bannerAndroid = value;
        break;
      case AdType.native:
        _nativeAndroid = value;
        break;
      case AdType.inter:
        _interAndroid = value;
        break;
      case AdType.rewarded:
        _rewardedAdAndroid = value;
        break;
      case AdType.appOpen:
        _appOpenAndroid = value;
        break;
      default:
    }
  }

  // Helper methods
  String getBannerId() {
    return Platform.isAndroid ? _bannerAndroid : _banneriOS;
  }

  String getInterId() {
    return Platform.isAndroid ? _interAndroid : _interiOS;
  }

  String getNativeId() {
    return Platform.isAndroid ? _nativeAndroid : _nativeiOS;
  }

  String getAppOpenId() {
    return Platform.isAndroid ? _appOpenAndroid : _appOpeniOS;
  }

  String getRewardedAdId() {
    return Platform.isAndroid ? _rewardedAdAndroid : _rewardedAdiOS;
  }
}
