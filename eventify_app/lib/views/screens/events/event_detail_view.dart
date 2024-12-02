import 'package:eventify_app/config/routes.dart';
import 'package:eventify_app/controllers/event_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/colors.dart';
import '../../../models/event.dart';
import '../../../services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/date_formatter.dart';

class EventDetailView extends GetView<EventController> {
  final isRegistered = false.obs;
  final authController = Get.find<AuthController>();

  EventDetailView({super.key}) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   authController.checkAuth();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(
      init: authController,
      initState: (_) {
        authController.checkAuth();
      },
      builder: (auth) {
        if (auth.isLoading.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (Get.arguments == null) {
          final eventId = Get.parameters['id'];
          return FutureBuilder<Event>(
            future: ApiService.getEventById(eventId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              return _buildEventDetail(snapshot.data!);
            },
          );
        }

        return _buildEventDetail(Get.arguments);
      },
    );
  }

  Widget _buildEventDetail(Event event) {
    return Scaffold(
      backgroundColor: mainColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color.fromARGB(255, 0, 0, 0),
            size: 28,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Hero image with gradient
          if (event.image != null)
            SizedBox(
              height: Get.height * 0.45,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: event.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                    errorWidget: (_, __, ___) => Image.asset(
                      'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          mainColor.withOpacity(0.5),
                          mainColor.withOpacity(0.8),
                          mainColor,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: Get.height * 0.35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.name,
                        style: TextStyle(
                          color: text1,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          _buildInfoChip(Icons.location_on, event.venue),
                          _buildInfoChip(Icons.calendar_today,
                              DateFormatter.format(event.date)),
                          if (!event.isFree)
                            _buildInfoChip(
                              Icons.attach_money,
                              'Ksh ${event.price ?? 0}',
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'About',
                        style: TextStyle(
                          color: text1,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description,
                        style: TextStyle(
                          color: text2,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Host',
                        style: TextStyle(
                          color: text1,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardFill,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: primaryColor.withOpacity(0.1),
                              child: Icon(Icons.person, color: primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Builder(builder: (_) {
                                    print(
                                        'Creator Details: ${event.creatorDetails}');
                                    return Text(
                                      event.creatorDetails?['name'] ??
                                          'Anonymous',
                                      style: TextStyle(
                                        color: text1,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }),
                                  if (event.creatorDetails?['email'] !=
                                      null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      event.creatorDetails!['email'],
                                      style: TextStyle(color: text2),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Action bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardFill,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: GetX<AuthController>(
                init: authController,
                builder: (auth) {
                  if (auth.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final currentUser = auth.user.value;
                  final isCreator = currentUser?['_id'] == event.creator;

                  return FutureBuilder<bool>(
                    future: _checkRegistrationStatus(event.id, event),
                    builder: (context, snapshot) {
                      final isRegistered = snapshot.data ?? false;

                      // Determine button state
                      String buttonText;
                      bool isDisabled = false;

                      if (isCreator) {
                        buttonText = 'You created this event';
                        isDisabled = true;
                      } else if (isRegistered) {
                        buttonText = 'Already Registered';
                        isDisabled = true;
                      } else {
                        buttonText = 'Register Now';
                      }

                      return Row(
                        children: [
                          if (!event.isFree) ...[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Price', style: TextStyle(color: text2)),
                                  Text(
                                    'Ksh ${event.price ?? 0}',
                                    style: TextStyle(
                                      color: text1,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isDisabled
                                  ? null
                                  : () => _handleRegistration(event),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                disabledBackgroundColor:
                                    Colors.grey.withOpacity(0.3),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                buttonText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDisabled ? text2 : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegistration(Event event) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        Get.toNamed(AppRoutes.login);
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await ApiService.registerForEvent(event.id);
      Get.back();

      Get.snackbar(
        'Success',
        'Successfully registered for ${event.name}',
        backgroundColor: primaryColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      if (Get.previousRoute.isEmpty) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.back();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Error',
        'Failed to register: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primaryColor, size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: text2)),
        ],
      ),
    );
  }

  Future<bool> _checkRegistrationStatus(String eventId, Event event) async {
    try {
      if (authController.user.value == null) {
        await authController.checkAuth();
      }

      final currentUser = authController.user.value;
      if (currentUser == null) return false;

      // Check if user is creator
      if (currentUser['_id'] == event.creator) return true;

      // Check registration status
      final response = await ApiService.checkEventRegistration(eventId);
      return response['isRegistered'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
