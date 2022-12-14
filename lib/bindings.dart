import 'package:code/ad_manager/google_ads_controller.dart';
import 'package:get/instance_manager.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<GoogleAdsController>(GoogleAdsController());
  }
}
