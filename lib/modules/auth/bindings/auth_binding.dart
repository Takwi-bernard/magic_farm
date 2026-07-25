import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';

class AuthBinding extends Bindings {
   AuthBinding();

  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(
          () => AuthRepository(),
      fenix: true,
    );

    Get.lazyPut<AuthController>(
          () => AuthController(
        repository: Get.find<AuthRepository>(),
      ),
      fenix: true,
    );
  }
}