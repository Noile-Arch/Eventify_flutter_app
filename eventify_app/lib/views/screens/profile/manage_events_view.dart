import 'package:eventify_app/config/routes.dart';
import 'package:eventify_app/views/screens/profile/create_event_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/colors.dart';
import '../../../controllers/event_controller.dart';
import '../../../models/event.dart';
import '../../../utils/date_formatter.dart';

class ManageEventsView extends StatelessWidget {
  const ManageEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    final eventController = Get.find<EventController>();
    
    // Fetch user events when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.fetchUserEvents();
    });

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: text1),
          onPressed: () => Get.back(),
        ),
        title: Text('My Events', style: TextStyle(color: text1)),
      ),
      body: Obx(() {
        if (eventController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final userEvents = eventController.userEvents;
        
        if (userEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: text2),
                const SizedBox(height: 16),
                Text(
                  'No events created yet',
                  style: TextStyle(color: text2, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => eventController.fetchUserEvents(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userEvents.length,
            itemBuilder: (context, index) {
              final event = userEvents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.editEvent,
                    arguments: event,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Event Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: event.image != null
                                  ? NetworkImage(event.image!)
                                  : const AssetImage('assets/images/placeholder.png') 
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Event Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: TextStyle(
                                  color: text1,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormatter.format(event.date),
                                style: TextStyle(color: text2),
                              ),
                              Text(
                                event.venue,
                                style: TextStyle(color: text2),
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: primaryColor),
                              onPressed: () => Get.toNamed(
                                AppRoutes.editEvent,
                                arguments: event,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: errorColor),
                              onPressed: () => _showDeleteDialog(context, event),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => CreateEventView()),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, Event event) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final eventController = Get.find<EventController>();
              eventController.deleteEvent(event.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 