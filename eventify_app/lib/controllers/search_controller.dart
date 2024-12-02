import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class UseSearchController extends GetxController {
  // Define the TextEditingController
  TextEditingController mySearchController = TextEditingController();
  var searchText = ''.obs;

  void search() {
    final text = mySearchController.text;
    searchText.value = text;

    if (text.isNotEmpty) {
      Get.snackbar("Searching", text);
    }
  }
}
