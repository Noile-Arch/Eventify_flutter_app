import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/colors.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final authController = Get.find<AuthController>();
  final profileImage = Rxn<File>();

  @override
  Widget build(BuildContext context) {
    // Initialize controllers with current user data
    final user = authController.user.value;
    if (user != null) {
      nameController.text = user['name'] ?? '';
      emailController.text = user['email'] ?? '';
      phoneController.text = user['phone'] ?? '';
      locationController.text = user['location'] ?? '';
    }

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: text1),
          onPressed: () => Get.back(),
        ),
        title: Text('Edit Profile', style: TextStyle(color: text1)),
        actions: [
          TextButton(
            onPressed: () => _saveProfile(),
            child: Text(
              'Save',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Obx(() {
              final user = authController.user.value;
              return Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: cardFill,
                    backgroundImage: _getProfileImage(user),
                    child: user?['profileImage'] == null && profileImage.value == null
                        ? Icon(Icons.person, size: 50, color: text2)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 32),
            _buildTextField('Full Name', nameController),
            const SizedBox(height: 16),
            _buildTextField('Email', emailController, enabled: false),
            const SizedBox(height: 16),
            _buildTextField('Phone (Optional)', phoneController),
            const SizedBox(height: 16),
            _buildTextField('Location (Optional)', locationController),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage(Map<String, dynamic>? user) {
    if (profileImage.value != null) {
      return FileImage(profileImage.value!);
    }
    if (user?['profileImage'] != null) {
      return NetworkImage(ApiService.getImageUrl(user!['profileImage']));
    }
    return null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> _saveProfile() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final Map<String, dynamic> updates = {
        'name': nameController.text,
        'phone': phoneController.text,
        'location': locationController.text,
      };

      await ApiService.updateProfile(
        updates,
        imageFile: profileImage.value,  // Pass the image file if selected
      );
      
      await authController.checkAuth(); // Refresh user data

      Get.back(); // Close loading dialog
      Get.back(); // Return to profile screen

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: text2),
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
} 