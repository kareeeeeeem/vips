import 'package:get/get.dart';

import '../controllers/q_r_scanner_controller.dart';

class QRScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QRScannerController>(
      () => QRScannerController(),
    );
  }
}
