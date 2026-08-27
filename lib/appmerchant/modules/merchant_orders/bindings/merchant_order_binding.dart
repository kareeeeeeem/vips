import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vip/appmerchant/core/api/api_client.dart';
import 'package:vip/core/services/api_service.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/repositories/merchant_order_repository_interface.dart';
import 'package:vip/appmerchant/modules/merchant_orders/domain/services/merchant_order_service_interface.dart';

import '../controllers/merchant_order_controller.dart';
import '../data/repositories/merchant_order_repository.dart';
import '../data/services/merchant_order_service.dart';

class MerchantOrderBinding extends Bindings {
  @override
  void dependencies() {
    // Get the existing ApiClient and SharedPreferences from the global binding
    // or create them if they don't exist
    // The Orders module talks through its own ApiClient, which used to be
    // pinned to AppConstants.baseUrl — a hardcoded production host. Every
    // other merchant screen goes through ApiService, so Orders was the one
    // screen that ignored whichever backend the rest of the app was pointed
    // at. Derive it from the same source of truth (ApiService.baseUrl ends in
    // /api, and this client's URIs already carry their own /api prefix).
    Get.lazyPut<ApiClient>(
      () => ApiClient(
        appBaseUrl: ApiService.baseUrl.replaceFirst(RegExp(r'/api/?$'), ''),
        sharedPreferences: Get.find<SharedPreferences>(),
      ),
    );

    // Repository and Service
    Get.lazyPut<MerchantOrderRepositoryInterface>(
      () => MerchantOrderRepository(
        apiClient: Get.find<ApiClient>(),
        sharedPreferences: Get.find<SharedPreferences>(),
      ),
    );

    Get.lazyPut<MerchantOrderServiceInterface>(
      () => MerchantOrderService(
        orderRepositoryInterface: Get.find<MerchantOrderRepositoryInterface>(),
      ),
    );

    // Controller
    Get.lazyPut<MerchantOrderController>(
      () => MerchantOrderController(
        orderService: Get.find<MerchantOrderServiceInterface>(),
      ),
    );
  }
}
