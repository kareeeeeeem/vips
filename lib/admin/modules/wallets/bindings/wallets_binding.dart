import 'package:get/get.dart';
import '../controllers/wallets_controller.dart';

class AdminWalletsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AdminWalletsController());
}
