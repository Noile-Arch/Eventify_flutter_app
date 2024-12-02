import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/colors.dart';
import '../../../controllers/event_controller.dart';
import '../../../models/event.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditEventView extends GetView<EventController> {
  final Event event;

  EditEventView({super.key, required this.event}) {
    // Initialize controllers in constructor
    nameController.text = event.name;
    descriptionController.text = event.description;
    venueController.text = event.venue;
    dateController.text = event.rawDate;
    categoryController.text = event.category ?? '';
    capacityController.text = event.capacity?.toString() ?? '';
  }

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final venueController = TextEditingController();
  final dateController = TextEditingController();
  final categoryController = TextEditingController();
  final capacityController = TextEditingController();
  final selectedImage = Rxn<File>();

  final categories = [
    'Technology',
    'Business',
    'Entertainment',
    'Education',
    'Sports',
    'Food',
    'Arts',
    'Music',
    'Networking',
    'Health',
    'Community',
    'Charity'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: text1),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit Event', style: TextStyle(color: text1)),
        actions: [
          TextButton(
            onPressed: _updateEvent,
            child: Text('Save', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker with optimized loading
              Obx(() => GestureDetector(
                onTap: _pickImage,
                child: Hero(
                  tag: 'eventImage${event.id}',
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: cardFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: selectedImage.value != null
                        ? Image.file(
                            selectedImage.value!,
                            fit: BoxFit.cover,
                          )
                        : event.image != null
                            ? Image.network(
                                event.image!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              )
                            : Icon(Icons.add_photo_alternate, size: 50, color: text2),
                  ),
                ),
              )),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name*',
                  hintText: 'Min 3 characters',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  hintText: 'Min 10 characters',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: event.category,
                decoration: const InputDecoration(labelText: 'Category*'),
                items: categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  categoryController.text = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: venueController,
                decoration: const InputDecoration(
                  labelText: 'Venue*',
                  hintText: 'Event location',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dateController,
                decoration: InputDecoration(
                  labelText: 'Date & Time*',
                  hintText: 'Select date and time',
                ),
                readOnly: true,
                onTap: () async {
                  final now = DateTime.now();
                  final initialDate = DateTime.parse(event.rawDate).toLocal();

                  final effectiveInitialDate = initialDate.isBefore(now)
                      ? now.add(const Duration(days: 1))
                      : initialDate;

                  final date = await showDatePicker(
                    context: context,
                    initialDate: effectiveInitialDate,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final currentTime = TimeOfDay.fromDateTime(initialDate);
                    final time = await showTimePicker(
                      context: context,
                      initialTime: currentTime,
                    );
                    if (time != null) {
                      final localDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      final utcDateTime = localDateTime.toUtc();
                      dateController.text = utcDateTime.toIso8601String();
                    }
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacity*',
                  hintText: 'Between 1-1000',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  void _updateEvent() async {
    if (_validateData()) {
      try {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );

        final formData = {
          'title': nameController.text,
          'description': descriptionController.text,
          'category': categoryController.text,
          'location': venueController.text,
          'date': dateController.text,
          'capacity': int.parse(capacityController.text),
          'price': 0,
          'isFree': true,
        };

        await controller.updateEvent(
          event.id,
          formData,
          imageFile: selectedImage.value,
        );

        Get.back(); // Close loading dialog
        Get.back(); // Return to previous screen

        Get.snackbar(
          'Success',
          'Event updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Failed to update event: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  bool _validateData() {
    if (nameController.text.length < 3) {
      Get.snackbar('Error', 'Name must be at least 3 characters');
      return false;
    }
    if (descriptionController.text.length < 10) {
      Get.snackbar('Error', 'Description must be at least 10 characters');
      return false;
    }
    if (categoryController.text.isEmpty) {
      Get.snackbar('Error', 'Please select a category');
      return false;
    }
    if (venueController.text.length < 3) {
      Get.snackbar('Error', 'Venue must be at least 3 characters');
      return false;
    }
    if (dateController.text.isEmpty) {
      Get.snackbar('Error', 'Please select a date');
      return false;
    }
    try {
      final cap = int.parse(capacityController.text);
      if (cap < 1 || cap > 1000) {
        Get.snackbar('Error', 'Capacity must be between 1 and 1000');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Please enter a valid capacity number');
      return false;
    }
    return true;
  }
}
