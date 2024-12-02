import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/colors.dart';
import '../../../controllers/event_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateEventView extends GetView<EventController> {
  CreateEventView({super.key}) {
    // Initialize controllers
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    venueController = TextEditingController();
    dateController = TextEditingController();
    categoryController = TextEditingController();
    capacityController = TextEditingController();

    // Clean up when view is closed
    Get.delete<CreateEventView>(force: true);
  }

  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController venueController;
  late final TextEditingController dateController;
  late final TextEditingController categoryController;
  late final TextEditingController capacityController;
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
        title: Text('Create Event', style: TextStyle(color: text1)),
        actions: [
          TextButton(
            onPressed: _createEvent,
            child: Text('Create', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Picker
            Obx(() => GestureDetector(
                  onTap: _pickImage,
                  child: Hero(
                    tag: 'eventImage',
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: cardFill,
                        borderRadius: BorderRadius.circular(12),
                        image: selectedImage.value != null
                            ? DecorationImage(
                                image: FileImage(selectedImage.value!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: selectedImage.value == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate,
                                    size: 50, color: text2),
                                const SizedBox(height: 8),
                                Text('Add Event Image',
                                    style: TextStyle(color: text2)),
                              ],
                            )
                          : null,
                    ),
                  ),
                )),
            const SizedBox(height: 24),
            // Event Name
            TextField(
              controller: nameController,
              style: TextStyle(color: text1),
              decoration: InputDecoration(
                labelText: 'Event Name*',
                hintText: 'Min 3 characters',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cardFill,
              ),
            ),
            const SizedBox(height: 16),
            // Description
            TextField(
              controller: descriptionController,
              style: TextStyle(color: text1),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description*',
                hintText: 'Min 10 characters',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cardFill,
              ),
            ),
            const SizedBox(height: 16),
            // Category
            DropdownButtonFormField<String>(
              value: categories.first,
              decoration: InputDecoration(
                labelText: 'Category*',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cardFill,
              ),
              items: categories.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category, style: TextStyle(color: text1)),
                );
              }).toList(),
              onChanged: (String? value) {
                categoryController.text = value ?? '';
              },
            ),
            const SizedBox(height: 16),
            // Venue
            TextField(
              controller: venueController,
              style: TextStyle(color: text1),
              decoration: InputDecoration(
                labelText: 'Venue*',
                hintText: 'Event location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cardFill,
              ),
            ),
            const SizedBox(height: 16),
            // Date
            TextField(
              controller: dateController,
              style: TextStyle(color: text1),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    final dateTime = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                    dateController.text = dateTime.toIso8601String();
                  }
                }
              },
              decoration: InputDecoration(
                labelText: 'Date*',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cardFill,
                suffixIcon: Icon(Icons.calendar_today, color: text2),
              ),
            ),
            const SizedBox(height: 16),
            // Capacity
            TextField(
              controller: capacityController,
              style: TextStyle(color: text1),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Capacity*',
                hintText: 'Between 1-1000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: cardFill,
              ),
            ),
            const SizedBox(height: 24),
          ],
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

  void _createEvent() async {
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

        await controller.createEvent(
          formData,
          imageFile: selectedImage.value, // Pass the image file
        );

        Get.back(); // Close loading dialog
        Get.back(); // Return to previous screen

        Get.snackbar(
          'Success',
          'Event created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Failed to create event: $e',
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
