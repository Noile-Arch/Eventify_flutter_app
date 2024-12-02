import 'package:eventify_app/views/auth/signup_view.dart';
import 'package:eventify_app/views/screens/dashboard.dart';
import 'package:eventify_app/views/screens/profile/edit_profile_view.dart';
import 'package:eventify_app/views/screens/profile/manage_events_view.dart';
import 'package:eventify_app/views/screens/profile/notifications_view.dart';
import 'package:eventify_app/views/screens/profile/payment_methods_view.dart';
import 'package:get/get.dart';

import '../views/auth/login_view.dart';
import '../middleware/auth_middleware.dart';
import '../views/screens/events/event_detail_view.dart';
import '../views/screens/profile/edit_event_view.dart';
import '../views/screens/profile/create_event_view.dart';

class AppRoutes {
  static const login = '/';
  static const signup = '/signup';
  static const events = '/events';
  static const dashboard = '/dashboard';
  static const eventDetail = '/event-detail/:id';
  static const createEvent = '/create-event';
  static const editEvent = '/edit-event';
  static const adminDashboard = '/admin-dashboard';
  
  // Profile routes
  static const editProfile = '/edit-profile';
  static const notifications = '/notifications';
  static const payments = '/payments';

  static final routes = [
    GetPage(
      name: login, 
      page: () => const LoginView(),
    ),
    GetPage(
      name: signup, 
      page: () => const SignupView(),
    ),
    GetPage(
      name: createEvent,
      page: () => CreateEventView(),
    ),
    GetPage(
      name: eventDetail, 
      page: () => EventDetailView(),
      transition: Transition.rightToLeft,
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: dashboard, 
      page: () => const Dashboard(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: events, 
      page: () => const ManageEventsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editProfile, 
      page: () => EditProfileView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: notifications, 
      page: () => const NotificationsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: payments, 
      page: () => const PaymentMethodsView(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: editEvent,
      page: () => EditEventView(event: Get.arguments),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
