import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../ad_manager/google_ads_controller.dart';

class DvBannerAdWidget extends StatefulWidget {
  const DvBannerAdWidget({super.key});

  @override
  State<DvBannerAdWidget> createState() => _DvBannerAdWidgetState();
}

class _DvBannerAdWidgetState extends State<DvBannerAdWidget> {
  final _googleAdsController = Get.find<GoogleAdsController>();

  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    _loadBanner();
  }

  void _loadBanner() {
    final adId = _googleAdsController.getBannerId();
    BannerAd(
      adUnitId: adId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
          _bannerAd = null;
          Future.delayed(
              Duration(milliseconds: _googleAdsController.retryDelayInMiliSec),
              () {
            _loadBanner();
          });
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    return _bannerAd != null
        ? Container(
            padding: const EdgeInsets.only(top: 8),
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          )
        : Container();
  }
}
