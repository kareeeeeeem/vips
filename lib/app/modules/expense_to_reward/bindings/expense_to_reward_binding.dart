import 'package:get/get.dart';

import '../controllers/expense_to_reward_controller.dart';

class ExpenseToRewardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseToRewardController>(
      () => ExpenseToRewardController(),
    );
  }
}
