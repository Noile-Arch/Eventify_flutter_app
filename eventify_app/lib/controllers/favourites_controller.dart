import 'package:get/get.dart';

class FavouritesController extends GetxController {
  final favorites = <Map<String, dynamic>>[].obs;

  void toggleFavorite(Map<String, dynamic> event) {
    final index = favorites.indexWhere((e) => e['title'] == event['title']);
    if (index >= 0) {
      favorites.removeAt(index);
      Get.snackbar(
        'Removed from favourites',
        '${event['title']} removed from favourites',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      favorites.add(event);
      Get.snackbar(
        'Added to favourites',
        '${event['title']} added to favourites',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool isFavorite(String title) {
    return favorites.any((e) => e['title'] == title);
  }
}