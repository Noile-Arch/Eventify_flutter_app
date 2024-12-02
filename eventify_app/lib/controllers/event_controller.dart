import 'package:eventify_app/config/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import 'dart:io';

class EventController extends GetxController {
  final events = <Event>[].obs;
  final userEvents = <Event>[].obs;
  final favoriteEvents = <Event>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'All'.obs;
  final allEvents = <Event>[].obs;
  final registeredEvents = <Event>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
    fetchUserEvents();
    fetchFavoriteEvents();
    fetchRegisteredEvents();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      allEvents.value = await ApiService.getEvents();
      if (searchQuery.value.isNotEmpty) {
        updateSearchQuery(searchQuery.value);
      } else {
        filterEventsByCategory(selectedCategory.value);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserEvents() async {
    try {
      isLoading.value = true;
      final token = await ApiService.getToken();
      if (token != null) {
        print('Fetching user events...');
        userEvents.value = await ApiService.getUserEvents();
        print('Fetched ${userEvents.length} user events');
      }
    } catch (e) {
      print('Error fetching user events: $e');
      userEvents.value = [];
      Get.snackbar(
        'Error',
        'Failed to load your events',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFavoriteEvents() async {
    try {
      favoriteEvents.value = await ApiService.getFavoriteEvents();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> fetchRegisteredEvents() async {
    try {
      isLoading.value = true;
      registeredEvents.value = await ApiService.getRegisteredEvents();
    } catch (e) {
      print('Error fetching registered events: $e');
      Get.snackbar(
        'Error',
        'Failed to load your tickets',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(String eventId) async {
    try {
      final currentUser = Get.find<AuthController>().user.value;
      if (currentUser == null) {
        Get.toNamed(AppRoutes.login);
        return;
      }

      final wasAlreadyFavorite = isFavorite(eventId);
      print('Was favorite before: $wasAlreadyFavorite');

      await ApiService.toggleFavorite(eventId);
      
      await fetchFavoriteEvents();
      
      await fetchEvents();

      Get.snackbar(
        'Success',
        wasAlreadyFavorite 
            ? 'Removed from favorites'
            : 'Added to favorites',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Toggle favorite error: $e');
      Get.snackbar(
        'Error',
        'Failed to update favorite status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> createEvent(Map<String, dynamic> eventData, {File? imageFile}) async {
    try {
      await ApiService.createEvent(eventData, imageFile: imageFile);
      await fetchUserEvents();
    } catch (e) {
      print('Error in createEvent: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> eventData, {File? imageFile}) async {
    try {
      await ApiService.updateEvent(eventId, eventData, imageFile: imageFile);
      await fetchUserEvents(); // Refresh the events list
    } catch (e) {
      print('Error in updateEvent: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await ApiService.deleteEvent(eventId);
      await fetchUserEvents();
      Get.snackbar('Success', 'Event deleted successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      events.value = allEvents;
    } else {
      events.value = allEvents.where((event) {
        final searchLower = query.toLowerCase();
        return event.name.toLowerCase().contains(searchLower) ||
            event.description.toLowerCase().contains(searchLower) ||
            event.venue.toLowerCase().contains(searchLower) ||
            (event.category?.toLowerCase() ?? '').contains(searchLower);
      }).toList();
    }
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    filterEventsByCategory(category);
  }

  void filterEventsByCategory(String category) {
    try {
      if (category == 'All') {
        events.value = allEvents;
      } else {
        events.value = allEvents.where((event) {
          return event.category?.toLowerCase() == category.toLowerCase();
        }).toList();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  bool isFavorite(String eventId) {
    try {
      final currentUser = Get.find<AuthController>().user.value;
      if (currentUser == null) return false;
      
      return favoriteEvents.any((event) => event.id == eventId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  void clearData() {
    events.clear();
    userEvents.clear();
    favoriteEvents.clear();
    registeredEvents.clear();
    allEvents.clear();
    searchQuery.value = '';
    selectedCategory.value = 'All';
  }
}
