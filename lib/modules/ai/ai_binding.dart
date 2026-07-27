import 'package:get/get.dart';

import 'ai_controller.dart';
import 'ai_repository.dart';

class AIBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AIRepository>(
          () => AIRepository(),
      fenix: true,
    );

    Get.lazyPut<AIController>(
          () => AIController(Get.find<AIRepository>()),
      fenix: true,
    );
  }
}