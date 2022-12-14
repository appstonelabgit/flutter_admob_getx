import 'package:code/ad_manager/dv_banner_ad_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_manager/google_ads_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MobileAds.instance.initialize().then((value) {
    debugPrint("Initialisation done: ${value.adapterStatuses}");
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        testDeviceIds: [
          "602F36D0DCA0B61F0D7B2E932FD7347C",
        ],
      ),
    );
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Get.put<GoogleAdsController>(GoogleAdsController());
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter AdMob',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter AdMob Home Page'),
      // initialBinding: InitialBindings(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _googleAdsController = Get.find<GoogleAdsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _googleAdsController.showInterstitial(
                        successCallBack: () {
                          debugPrint("Interstitial displayed successfully");
                        },
                        adLoadErrorCallBack: () {
                          Get.showSnackbar(
                            const GetSnackBar(
                              titleText: Text("Ad not loaded"),
                              messageText: Text("Please try again later!!!!"),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Show Interstitial"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _googleAdsController.showRewardedAd(
                        successCallBack: () {
                          debugPrint("Interstitial displayed successfully");
                        },
                        adLoadErrorCallBack: () {
                          Get.showSnackbar(
                            const GetSnackBar(
                              titleText: Text("Ad not loaded"),
                              messageText: Text("Please try again later!!!!"),
                            ),
                          );
                        },
                        rewardCallBack: () {
                          debugPrint("Reward earned successfully");
                        },
                      );
                    },
                    child: const Text("Show Rewarded"),
                  )
                ],
              ),
            ),
            const Positioned(
              // bottom: 0,
              child: DvBannerAdWidget(),
            )
          ],
        ),
      ),
    );
  }
}
