import 'package:eventify_app/config/colors.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';

import 'package:eventify_app/views/widgets/event_card.dart';
import 'package:eventify_app/views/widgets/featured_slider.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final eventController = Get.put(EventController());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.fetchEvents();
    });
    
    return Scaffold(
      extendBody: true,
      backgroundColor: mainColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: mainColor,
              elevation: 0,
              title: Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 40,
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                  
                    Text(
                      "Discover Events",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: text1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Find the perfect event for you",
                      style: TextStyle(
                        fontSize: 16,
                        color: text2,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Categories
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(() => Row(
                        children: [
                          _buildCategoryChip(
                            'All',
                            Icons.grid_view_rounded,
                            eventController.selectedCategory.value == 'All',
                            eventController,
                          ),
                          _buildCategoryChip(
                            'Technology',
                            Icons.computer,
                            eventController.selectedCategory.value == 'Technology',
                            eventController,
                          ),
                          _buildCategoryChip(
                            'Music',
                            Icons.music_note,
                            eventController.selectedCategory.value == 'Music',
                            eventController,
                          ),
                          _buildCategoryChip(
                            'Art',
                            Icons.palette,
                            eventController.selectedCategory.value == 'Art',
                            eventController,
                          ),
                          _buildCategoryChip(
                            'Sports',
                            Icons.sports_soccer,
                            eventController.selectedCategory.value == 'Sports',
                            eventController,
                          ),
                          _buildCategoryChip(
                            'Food',
                            Icons.restaurant,
                            eventController.selectedCategory.value == 'Food',
                            eventController,
                          ),
                        ],
                      )),
                    ),

                    const SizedBox(height: 32),

                    // Featured Events
                    _sectionHeader("Featured Events", "See all"),
                    const SizedBox(height: 16),
                    featuredSlider(),

                    const SizedBox(height: 32),

                    // Popular Events
                    _sectionHeader("Popular Events", "See all"),
                    const SizedBox(height: 16),

                    // Events List
                    Obx(() {
                      if (eventController.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (eventController.events.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy, size: 64, color: text2),
                              const SizedBox(height: 16),
                              Text(
                                'No events available',
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
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: eventController.events.length,
                        itemBuilder: (context, index) {
                          final event = eventController.events[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: EventCard(
                              event: event,
                              onTap: () {
                                print('Event ID: ${event.id}');
                                Get.toNamed(
                                  '/event-detail/${event.id}',
                                  arguments: event,
                                  preventDuplicates: false,
                                );
                              },
                            ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon, bool isSelected, EventController controller) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        label: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : text1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: inputFill,
        selectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onSelected: (bool selected) {
          if (selected) {
            controller.updateCategory(label);
          }
        },
      ),
    );
  }

  Widget _sectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: text1,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
          child: Row(
            children: [
              Text(
                actionText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ],
    );
  }
}
