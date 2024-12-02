import 'package:eventify_app/views/screens/profile/edit_profile_view.dart';
import 'package:eventify_app/views/screens/profile/manage_events_view.dart';
import 'package:eventify_app/views/screens/profile/notifications_view.dart';
import 'package:eventify_app/views/screens/profile/payment_methods_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/colors.dart';
import '../../controllers/auth_controller.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: mainColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        elevation: 0,
        leading: BackButton(color: text1),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: text1),
            onPressed: () {},
          ),
        ],
        title: Text(
          "Profile",
          style: TextStyle(color: text1),
        ),
      ),
      body: Obx(() {
        final user = authController.user.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Please login to view your profile',
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

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: cardFill,
                  backgroundImage: user['profileImage'] != null
                      ? NetworkImage(ApiService.getImageUrl(user['profileImage']))
                      : null,
                  child: user['profileImage'] == null
                      ? Icon(Icons.person, size: 50, color: text2)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user['name'] ?? 'No Name',
                  style: TextStyle(
                    color: text1,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user['email'] ?? 'No Email',
                  style: TextStyle(color: text2),
                ),
                if (user['phone']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(
                    user['phone'] ?? '',
                    style: TextStyle(color: text2),
                  ),
                ],
                if (user['location']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(
                    user['location'] ?? '',
                    style: TextStyle(color: text2),
                  ),
                ],
                const SizedBox(height: 24),
                _menuItem(
                  Icons.event,
                  "Manage Events",
                  onTap: () => Get.to(() => const ManageEventsView()),
                ),
                _menuItem(
                  Icons.edit,
                  "Edit Profile",
                  onTap: () => Get.to(() => EditProfileView()),
                ),
                _menuItem(
                  Icons.notifications,
                  "Notification Settings",
                  onTap: () => Get.to(() => const NotificationsView()),
                ),
                _menuItem(
                  Icons.payment,
                  "Payment Methods",
                  onTap: () => Get.to(() => const PaymentMethodsView()),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Logout'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _menuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardFill,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: text1.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: text1,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: text3),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final authController = Get.find<AuthController>();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: text2),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authController.logout();
                Get.offAllNamed('/'); // Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: text1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: text2,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
