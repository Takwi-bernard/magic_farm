import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogService {

  DialogService._();

  static void success({
    required String title,
    required String message,
  }) {

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

  }

  static void error({
    required String title,
    required String message,
  }) {

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );

  }

  static void info({
    required String title,
    required String message,
  }) {

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );

  }

}