import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'google_ads_controller.dart';

class DvNativeAdWidget extends StatefulWidget {
  final double bottomPadding;
  const DvNativeAdWidget({this.bottomPadding = 8, super.key});

  @override
  State<DvNativeAdWidget> createState() => _DvNativeAdWidgetState();
}

class _DvNativeAdWidgetState extends State<DvNativeAdWidget> {
  final _googleAdsController = Get.find<GoogleAdsController>();

  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();

    _loadNativeAd();
  }

  @override
  void dispose() {
    super.dispose();

    _nativeAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded ? _nativeAdTile() : Container();
  }

  Widget _nativeAdTile() {
    return Padding(
      padding: EdgeInsets.only(
          top: 8.0, bottom: widget.bottomPadding, right: 15, left: 15),
      child: Container(
        padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 1.0,
              spreadRadius: 1,
              offset: const Offset(0.0, 0),
            )
          ],
        ),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }

  //------------------------------------ Create Native Ad ------------------------ //
  void _loadNativeAd() {
    if (!_isAdLoaded) {
      _nativeAd = NativeAd(
        adUnitId: _googleAdsController.getNativeId(),
        factoryId: "nativeAdLarge",
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isAdLoaded = true;
              _nativeAd = ad as NativeAd;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            _isAdLoaded = false;
            ad.dispose();
            debugPrint(
                'Native Ad: Ad load failed (code=${error.code} message=${error.message})');
            Future.delayed(
                Duration(
                    milliseconds: _googleAdsController.retryDelayInMiliSec),
                () {
              _loadNativeAd();
            });
          },
        ),
      );

      _nativeAd?.load();
    }
  }
}
