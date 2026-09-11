import 'package:get/get.dart';

import '../controllers/seller_profile_controller.dart';
import '../../../../modules/product_details/repositories/product_details_repository.dart';

class SellerProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductDetailsRepository>()) {
      Get.lazyPut<ProductDetailsRepository>(
        () => ProductDetailsRepository(),
        fenix: true,
      );
    }

    Get.lazyPut<SellerProfileController>(
      () => SellerProfileController(Get.find<ProductDetailsRepository>()),
      fenix: true,
    );
  }
}