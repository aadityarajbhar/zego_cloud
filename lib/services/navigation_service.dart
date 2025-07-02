// navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState>? _navigatorKey;

  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static BuildContext? get context => _navigatorKey?.currentContext;

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return _navigatorKey!.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToReplacement(String routeName,
      {Object? arguments}) {
    return _navigatorKey!.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    return _navigatorKey!.currentState!.pop();
  }

  static Future<dynamic> navigateToCall(Map<String, dynamic> callData) {
    // Navigate to call screen with call data
    return navigateTo('/call_page', arguments: callData);
  }
}
