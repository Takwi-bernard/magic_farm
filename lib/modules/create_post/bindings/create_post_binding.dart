import 'package:get/get.dart';

import '../controllers/create_post_controller.dart';
import '../repositories/create_post_repository.dart';
import '../../home/controllers/home_controller.dart';
import '../../ai/ai_repository.dart';

class CreatePostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreatePostRepository>(
          () => CreatePostRepository(),
      fenix: true,
    );

    // A farmer can land on Create Post without ever opening the AI
    // tab first, so AIRepository isn't guaranteed to already be
    // registered the way it would be if AIBinding had already run.
    // Guarded rather than unconditional lazyPut, since calling
    // lazyPut twice for the same type can throw.
    if (!Get.isRegistered<AIRepository>()) {
      Get.lazyPut<AIRepository>(() => AIRepository(), fenix: true);
    }

    Get.lazyPut<CreatePostController>(
          () => CreatePostController(
        Get.find<CreatePostRepository>(),
        Get.find<HomeController>(),
        Get.find<AIRepository>(),
      ),
      fenix: true,
    );
  }
}