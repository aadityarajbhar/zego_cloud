import 'dart:async';
import 'package:flutter/services.dart';

class BackgroundService {
  static const MethodChannel _channel = MethodChannel('background_service');

  static Future<void> initializeBackgroundService() async {
    try {
      await _channel.invokeMethod('initializeBackgroundService');
    } on PlatformException catch (e) {
      print("Failed to initialize background service: '${e.message}'.");
    }
  }

  static Future<void> startBackgroundService() async {
    try {
      await _channel.invokeMethod('startBackgroundService');
    } on PlatformException catch (e) {
      print("Failed to start background service: '${e.message}'.");
    }
  }

  static Future<void> stopBackgroundService() async {
    try {
      await _channel.invokeMethod('stopBackgroundService');
    } on PlatformException catch (e) {
      print("Failed to stop background service: '${e.message}'.");
    }
  }
}
