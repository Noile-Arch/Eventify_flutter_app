import 'package:eventify_app/config/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/colors.dart';
import '../widgets/event_card.dart';
import '../../controllers/event_controller.dart';

class FavouritesScreen extends StatelessWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Favorites',
          style: TextStyle(
            color: text1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => eventController.fetchFavoriteEvents(),
        child: Obx(() {
          if (eventController.favoriteEvents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 64, color: text2),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite events yet',
                    style: TextStyle(
                      color: text2,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: eventController.favoriteEvents.length,
            itemBuilder: (context, index) {
              final event = eventController.favoriteEvents[index];
              return EventCard(
                event: event,
                onTap: () => Get.toNamed(
                  AppRoutes.eventDetail,
                  arguments: event,
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
