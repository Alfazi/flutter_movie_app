import 'package:get/get.dart';

class UiHelper {
  static void showSnackbar(String title, String message,
      {SnackPosition? position}) {
    try {
      if (Get.context != null) {
        Get.snackbar(
          title,
          message,
          snackPosition: position ?? SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('[UI_HELPER] Could not show snackbar: $title - $message');
    }
  }
}
