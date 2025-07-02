// fcm_service.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _fcmTokenKey = 'fcm_token';
  static const String _serverUrl =
      'YOUR_SERVER_URL'; // Replace with your server URL

  // Initialize FCM service
  static Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
      return;
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveFCMToken(token);
      log('FCM Token kkkkkkkkkkkkkkkkk: $token');
    }

    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _saveFCMToken(newToken);
      _sendTokenToServer(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle app launch from terminated state
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  // Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'call_channel',
      'Call Notifications',
      description: 'Notifications for incoming calls',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('call_sound'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Handling foreground message: ${message.messageId}');

    if (message.data['type'] == 'call_invitation') {
      await _showCallNotification(message);
    }
  }

  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');

    if (message.data['type'] == 'call_invitation') {
      // Navigate to call screen or handle call invitation
      _handleIncomingCall(message.data);
    }
  }

  // Handle local notification tap
  static void _onNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');

    if (response.payload != null) {
      final data = jsonDecode(response.payload!);
      if (data['type'] == 'call_invitation') {
        _handleIncomingCall(data);
      }
    }
  }

  // Show call notification
  static Future<void> _showCallNotification(RemoteMessage message) async {
    final data = message.data;
    final callerName = data['caller_name'] ?? 'Unknown';
    final callType = data['call_type'] ?? 'voice';
    final callId = data['call_id'] ?? '';

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'call_channel',
      'Call Notifications',
      channelDescription: 'Notifications for incoming calls',
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.call,
      fullScreenIntent: true,
      autoCancel: false,
      ongoing: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('call_sound'),
      actions: [
        AndroidNotificationAction(
          'accept',
          'Accept',
          icon: DrawableResourceAndroidBitmap('ic_call_accept'),
        ),
        AndroidNotificationAction(
          'decline',
          'Decline',
          icon: DrawableResourceAndroidBitmap('ic_call_decline'),
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'call_category',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      int.parse(callId.hashCode.toString().substring(0, 8)),
      'Incoming ${callType == 'video' ? 'Video' : 'Voice'} Call',
      'From: $callerName',
      notificationDetails,
      payload: jsonEncode(data),
    );
  }

  // Handle incoming call
  static void _handleIncomingCall(Map<String, dynamic> data) {
    // This will be called when user taps the notification
    // You can navigate to your call screen here
    print('Handling incoming call: $data');

    // Example: Navigate to call screen
    // NavigationService.navigateToCall(data);
  }

  // Save FCM token
  static Future<void> _saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
    await _sendTokenToServer(token);
  }

  // Get FCM token
  static Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  // Send token to your server
  static Future<void> _sendTokenToServer(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/api/fcm/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': currentUser.id,
          'fcm_token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        print('FCM token sent to server successfully');
      } else {
        print('Failed to send FCM token to server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending FCM token to server: $e');
    }
  }

  // Send call invitation
  static Future<void> sendCallInvitation({
    required String receiverUserId,
    required String callerName,
    required String callType, // 'voice' or 'video'
    required String callId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/api/call/invite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'receiver_user_id': receiverUserId,
          'caller_user_id': currentUser.id,
          'caller_name': callerName,
          'call_type': callType,
          'call_id': callId,
        }),
      );

      if (response.statusCode == 200) {
        print('Call invitation sent successfully');
      } else {
        print('Failed to send call invitation: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending call invitation: $e');
    }
  }

  // Cancel call notification
  static Future<void> cancelCallNotification(String callId) async {
    await _localNotifications.cancel(
      int.parse(callId.hashCode.toString().substring(0, 8)),
    );
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');

  if (message.data['type'] == 'call_invitation') {
    // Show local notification for incoming call
    await FCMService._showCallNotification(message);
  }
}
