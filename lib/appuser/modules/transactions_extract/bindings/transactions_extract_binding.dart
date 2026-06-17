import 'package:get/get.dart';

import '../controllers/transactions_extract_controller.dart';

class TransactionsExtractBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionsExtractController>(
      () => TransactionsExtractController(),
    );
  }
}
