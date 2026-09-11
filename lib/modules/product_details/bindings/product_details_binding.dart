import 'package:get/get.dart';

import '../controllers/product_details_controller.dart';
import '../repositories/product_details_repository.dart';
import '../../home/controllers/home_controller.dart';

class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailsRepository>(
      () => ProductDetailsRepository(),
      fenix: true,
    );

    // Tagged by productId — this is the actual fix. Without a tag,
    // every push of this page (product -> seller profile -> another
    // product -> ...) found the SAME controller instance instead of
    // a fresh one, since Get.lazyPut/Get.find are keyed by type only
    // by default. That meant onInit() never re-ran for a second
    // product, and the page kept showing whatever loaded first.
    final args = Get.arguments;
    final productId =
        (args is Map && args["id"] != null) ? args["id"].toString() : null;

    Get.put<ProductDetailsController>(
      ProductDetailsController(
        Get.find<ProductDetailsRepository>(),
        Get.find<HomeController>(),
      ),
      tag: productId,
    );
  }
}