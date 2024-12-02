import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../config/routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final currentRoute = route.currentPage?.name ?? '';
    print('Middleware checking route: $currentRoute');

    if ([AppRoutes.login, AppRoutes.signup].contains(currentRoute)) {
      return null;
    }

    final token = await ApiService.getToken();
    print('Middleware token check: $token');

    if (token == null) {
      print('No token, redirecting to login');
      return GetNavConfig.fromRoute(AppRoutes.login);
    }

    print('Token found, allowing navigation to: $currentRoute');
    return null;
  }

  @override
  RouteSettings? redirect(String? route) => null;
}
