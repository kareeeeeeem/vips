import 'package:get/get.dart';

import '../controllers/inventory_controller.dart';
import '../controllers/inventory_movements_controller.dart';
import '../controllers/inventory_transfers_controller.dart';
import '../controllers/low_stock_controller.dart';

class AdminInventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminInventoryController>(() => AdminInventoryController());
  }
}

class AdminInventoryMovementsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryMovementsController>(() => InventoryMovementsController());
  }
}

class AdminInventoryTransfersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InventoryTransfersController>(() => InventoryTransfersController());
  }
}

class AdminLowStockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LowStockController>(() => LowStockController());
  }
}
