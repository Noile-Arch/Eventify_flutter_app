import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/colors.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

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
        title: Text('Notifications', style: TextStyle(color: text1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationTile(
            'Event Reminders',
            'Get notified about upcoming events',
            true,
          ),
          _buildNotificationTile(
            'Messages',
            'Receive message notifications',
            true,
          ),
          _buildNotificationTile(
            'New Events',
            'Get notified about new events in your area',
            false,
          ),
          _buildNotificationTile(
            'Promotions',
            'Receive promotional offers and discounts',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(String title, String subtitle, bool initialValue) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        value: initialValue,
        onChanged: (value) {},
        title: Text(
          title,
          style: TextStyle(
            color: text1,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: text2),
        ),
        activeColor: primaryColor,
      ),
    );
  }
} 