class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeRepository>(
      () => HomeRepository(),
    );

    Get.lazyPut<HomeController>(
      () => HomeController(
        Get.find<HomeRepository>(),
      ),
    );
  }
}