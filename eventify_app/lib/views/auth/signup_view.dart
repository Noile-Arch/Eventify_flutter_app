import 'package:eventify_app/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../config/routes.dart';
import '../widgets/textfield_widget.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return Scaffold(
      backgroundColor: mainColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 220,
                  height: 100,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                    ),
                  ),
                ),
                const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: text1,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Discover events, capture moments and make memories ",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: text1,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                textFieldWidget(
                  controller: authController.firstnameController,
                  hint: "First Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                textFieldWidget(
                  controller: authController.lastnameController,
                  hint: "Last Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                textFieldWidget(
                  controller: authController.phoneController,
                  hint: "Phone",
                  icon: Icons.phone,
                ),
                const SizedBox(height: 20),
                textFieldWidget(
                  controller: authController.emailController,
                  hint: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                textFieldWidget(
                  controller: authController.passwordController,
                  hint: "Password",
                  isPassword: true,
                  icon: Icons.lock,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    authController.signup(
                        email: authController.emailController.text,
                        password: authController.passwordController.text,
                        firstname: authController.firstnameController.text,
                        lastname: authController.lastnameController.text,
                        phonenumber: authController.phoneController.text);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      const Color(0xFF4f43f3),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 140, vertical: 10),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.login);
                      },
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Color(0xFF4f43f3),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
