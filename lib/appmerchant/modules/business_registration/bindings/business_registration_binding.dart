import 'package:get/get.dart';
import '../controllers/business_registration_controller.dart';

class BusinessRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessRegistrationController>(
      () => BusinessRegistrationController(),
    );
  }
}
