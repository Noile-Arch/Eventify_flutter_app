import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/colors.dart';

class PaymentMethodsView extends StatelessWidget {
  const PaymentMethodsView({super.key});

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
        title: Text('Payment Methods', style: TextStyle(color: text1)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPaymentCard(
            'Mpesa',
            Icons.money,
            true,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaymentCard(String title, IconData icon, bool isDefault) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, color: primaryColor, size: 32),
        title: Text(
          title,
          style: TextStyle(
            color: text1,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: isDefault
            ? Text(
                'Default payment method',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: text2),
          onPressed: () {},
        ),
      ),
    );
  }
}
