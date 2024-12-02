import 'package:eventify_app/controllers/event_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../config/routes.dart';

class AuthController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  var isLoading = false.obs;
  final user = Rxn<Map<String, dynamic>>();
  final redirectUrl = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadLastEmail();
  }

  Future<void> loadLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEmail = prefs.getString('last_email') ?? '';
    emailController.text = lastEmail;
  }

  Future<void> saveLastEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_email', email);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Email and password cannot be empty",
        backgroundColor: const Color(0xFFff0000),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiService.login(email, password);
      await ApiService.setToken(response['token']);
      user.value = response['user'];
      await saveLastEmail(email);

      Get.snackbar(
        "Success",
        "Login successful!",
        backgroundColor: const Color(0xFF4f43f3),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed(AppRoutes.dashboard);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    required String phonenumber,
  }) async {
    if (email.isEmpty || password.isEmpty || firstname.isEmpty || lastname.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final fullName = "$firstname $lastname";
      await ApiService.register(fullName, email, password);
      
      Get.snackbar(
        "Success",
        "Account created successfully!",
        backgroundColor: const Color(0xFF4f43f3),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      Get.toNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.clearToken();
      user.value = null;
      final eventController = Get.find<EventController>();
      eventController.clearData();
      Get.offAllNamed('/');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> setRedirectUrl(String url) async {
    redirectUrl.value = url;
  }

  Future<void> checkAuth() async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      final token = await ApiService.getToken();
      print('Checking auth with token: $token');
      
      if (token != null) {
        final userData = await ApiService.getCurrentUser();
        print('Got user data: $userData');
        if (userData != null) {
          user.value = userData;
        }
      }
    } catch (e) {
      print('Auth check error: $e');
      user.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
