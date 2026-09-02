import 'package:get/get.dart';

import '../controllers/reward_action_controller.dart';

class RewardActionBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => RewardActionController());
}
