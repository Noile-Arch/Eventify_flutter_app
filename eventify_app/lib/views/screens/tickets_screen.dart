import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/colors.dart';
import '../../controllers/event_controller.dart';
import '../../models/event.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/auth_controller.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    final authController = Get.find<AuthController>();

    // Check auth and fetch events when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await authController.checkAuth();
      if (authController.user.value != null) {
        eventController.fetchRegisteredEvents();
      } else {
        Get.offAllNamed('/login'); // Redirect to login if not authenticated
      }
    });

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Tickets',
          style: TextStyle(
            color: text1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GetX<AuthController>(
        init: authController,
        builder: (auth) {
          if (auth.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (auth.user.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Please login to view your tickets',
                    style: TextStyle(color: text2),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.offAllNamed('/login'),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          return Obx(() {
            final registeredEvents = eventController.registeredEvents;

            if (registeredEvents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 64, color: text2),
                    const SizedBox(height: 16),
                    Text(
                      'No tickets yet',
                      style: TextStyle(
                        color: text1,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your purchased tickets will appear here',
                      style: TextStyle(color: text2, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Get.toNamed('/'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Browse Events',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: registeredEvents.length,
              itemBuilder: (context, index) {
                final event = registeredEvents[index];
                return _buildTicketCard(event);
              },
            );
          });
        },
      ),
    );
  }

  Widget _buildTicketCard(Event event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Event Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: event.image ?? '',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: cardFill,
                child: Center(
                    child: CircularProgressIndicator(color: primaryColor)),
              ),
              errorWidget: (_, __, ___) => Image.asset(
                'assets/images/placeholder.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Event Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: TextStyle(
                    color: text1,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      event.date,
                      style: TextStyle(color: text2),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      event.venue,
                      style: TextStyle(color: text2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
