import 'package:eventify_app/config/colors.dart';
import 'package:eventify_app/controllers/bottomnav_controller.dart';
import 'package:eventify_app/views/screens/favourites_screen.dart';
import 'package:eventify_app/views/screens/profile_screen.dart';
import 'package:eventify_app/views/screens/search_screen.dart';
import 'package:eventify_app/views/screens/tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'home_screen.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const SearchScreen(),
      const TicketsScreen(),
      const FavouritesScreen(),
      const ProfileScreen(),
    ];

    final BottomNavController bottomNavController =
        Get.put(BottomNavController());

    return Scaffold(
      backgroundColor: mainColor,
      body: Obx(
        () => pages[bottomNavController.selectedIndex.value],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBackground,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Obx(
              () => BottomNavigationBar(
                currentIndex: bottomNavController.selectedIndex.value,
                selectedItemColor: navSelected,
                unselectedItemColor: navUnselected,
                backgroundColor: Colors.transparent,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                elevation: 0,
                enableFeedback: true,
                onTap: (index) => bottomNavController.updateSelectedIndex(index),
                items: [
                  _navItem(Icons.home_rounded, "Home"),
                  _navItem(Icons.search_rounded, "Search"),
                  _navItem(Icons.confirmation_number_rounded, "Tickets"),
                  _navItem(Icons.favorite_rounded, "Favorites"),
                  _navItem(Icons.person_rounded, "Profile"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      activeIcon: Icon(icon, size: 24),
      label: label,
    );
  }
}
