// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:new_zego_cloud/firebase_options.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
// import 'constants/constants.dart';
// import 'services/login_service.dart';
// import 'services/permission_services.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(
// //     options: DefaultFirebaseOptions.currentPlatform,
// //   );

// //   final prefs = await SharedPreferences.getInstance();
// //   final cacheUserID = prefs.get(cacheUserIDKey) as String? ?? '';
// //   if (cacheUserID.isNotEmpty) {
// //     currentUser.id = cacheUserID;
// //     currentUser.name = 'user_$cacheUserID';
// //   }

// //   final navigatorKey = GlobalKey<NavigatorState>();
// //   ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

// //   ZegoUIKit().initLog().then((value) {
// //     // CORRECTED: Use the correct parameter names
// //     ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
// //       [ZegoUIKitSignalingPlugin()],
// //     );

// //     runApp(MyApp(navigatorKey: navigatorKey));
// //   });
// // }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Load user data
//   final prefs = await SharedPreferences.getInstance();
//   final cacheUserID = prefs.get(cacheUserIDKey) as String? ?? '';
//   if (cacheUserID.isNotEmpty) {
//     currentUser.id = cacheUserID;
//     currentUser.name = 'user_$cacheUserID';
//   }

//   final navigatorKey = GlobalKey<NavigatorState>();

//   // CRITICAL: Set navigator key before any ZegoUIKit initialization
//   ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

//   runApp(MyApp(navigatorKey: navigatorKey));
// }

// // Rest of MyApp class remains the same...
// class MyApp extends StatefulWidget {
//   final GlobalKey<NavigatorState> navigatorKey;

//   const MyApp({
//     required this.navigatorKey,
//     Key? key,
//   }) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => MyAppState();
// }

// class MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();

//     if (currentUser.id.isNotEmpty) {
//       onUserLogin();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       routes: routes,
//       initialRoute:
//           currentUser.id.isEmpty ? PageRouteNames.login : PageRouteNames.home,
//       theme: ThemeData(
//         fontFamily: GoogleFonts.poppins().fontFamily,
//       ),
//       navigatorKey: widget.navigatorKey,
//       builder: (BuildContext context, Widget? child) {
//         return Stack(
//           children: [
//             child!,
//             ZegoUIKitPrebuiltCallMiniOverlayPage(
//               contextQuery: () {
//                 return widget.navigatorKey.currentState!.context;
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/constants.dart';
import 'firebase_options.dart';
import 'page/home_page.dart';
import 'page/login_page.dart';
import 'services/fcm_service.dart';
import 'services/login_service.dart';
import 'services/navigation_service.dart';

// Initialize the FlutterLocalNotificationsPlugin globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ZPNs push notification configuration (removed invalid ZPNsConfig/zpnsManager usage)
void configureZPNsPush() {
  // No-op: ZPNsConfig and zpnsManager are not defined in the current SDKs.
}

// Global background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the plugin for background (required for background isolates)
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  print('Handling background message: ${message.messageId}');

  if (message.data['type'] == 'call_invitation') {
    // Handle background call invitation
    await _handleBackgroundCallInvitation(message);

    // Display notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'call_channel_id',
      'Call Notifications',
      channelDescription: 'Channel for call invitations',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Incoming Call',
      '${message.data['caller_name'] ?? 'Someone'} is calling you',
      platformChannelSpecifics,
      payload: message.data['call_id'],
    );
  }
}

Future<void> _handleBackgroundCallInvitation(RemoteMessage message) async {
  print('Background call invitation received: ${message.data}');

  // Extract call details from the message
  final callId = message.data['call_id'] ?? '';
  final callerUserId = message.data['caller_user_id'] ?? '';
  final callerName = message.data['caller_name'] ?? 'Unknown';
  final callType = message.data['call_type'] ?? 'voice';

  // Optionally, save call info to local storage for later retrieval
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('pending_call_id', callId);
  await prefs.setString('pending_caller_user_id', callerUserId);
  await prefs.setString('pending_caller_name', callerName);
  await prefs.setString('pending_call_type', callType);

  // Optionally, you can trigger analytics or other background logic here

  // (Optional) If you want to show a notification, it's already handled in the background handler above
}

class PageRouteNames {
  static const String login = '/login';
  static const String home = '/home_page';
  static const String call = '/call_page';
}

Map<String, WidgetBuilder> routes = {
  PageRouteNames.login: (context) => const LoginPage(),
  PageRouteNames.home: (context) => const ZegoUIKitPrebuiltCallMiniPopScope(
        child: HomePage(),
      ),
};

class UserInfo {
  String id = '';
  String name = '';

  UserInfo({
    required this.id,
    required this.name,
  });

  bool get isEmpty => id.isEmpty;

  UserInfo.empty();
}

// UserInfo currentUser = UserInfo.empty();
// const String cacheUserIDKey = 'cache_user_id_key';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Permission.notification.request();

  // Configure ZPNs push notification
  configureZPNsPush();
  // Configure ZPNs push notification (no-op)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM service
  await FCMService.initialize();

  // Load user data
  final prefs = await SharedPreferences.getInstance();
  final cacheUserID = prefs.get(cacheUserIDKey) as String? ?? '';
  if (cacheUserID.isNotEmpty) {
    currentUser.id = cacheUserID;
    currentUser.name = 'user_$cacheUserID';
  }

  final navigatorKey = GlobalKey<NavigatorState>();

  // Initialize navigation service
  NavigationService.initialize(navigatorKey);

  // CRITICAL: Set navigator key before any ZegoUIKit initialization
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({
    required this.navigatorKey,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    if (currentUser.id.isNotEmpty) {
      onUserLogin();
    }

    // Listen for FCM messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.data}');
      if (message.data['type'] == 'call_invitation') {
        _handleIncomingCall(message.data);
      }
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.data}');
      if (message.data['type'] == 'call_invitation') {
        _handleIncomingCall(message.data);
      }
    });

    // Check if app was launched from a notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.data['type'] == 'call_invitation') {
        _handleIncomingCall(message.data);
      }
    });
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    // Handle incoming call invitation
    final callId = data['call_id'] ?? '';
    final callerUserId = data['caller_user_id'] ?? '';
    final callerName = data['caller_name'] ?? 'Unknown';
    final callType = data['call_type'] ?? 'voice';

    // You can show a call screen or handle the invitation as needed
    print('Handling incoming call: $callId from $callerName');

    // Example: Show call invitation dialog or navigate to call screen
    if (widget.navigatorKey.currentContext != null) {
      _showIncomingCallDialog(
        context: widget.navigatorKey.currentContext!,
        callerName: callerName,
        callType: callType,
        onAccept: () {
          // Accept call logic
          _acceptCall(callId, callerUserId);
        },
        onDecline: () {
          // Decline call logic
          _declineCall(callId);
        },
      );
    }
  }

  void _showIncomingCallDialog({
    required BuildContext context,
    required String callerName,
    required String callType,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Incoming ${callType == 'video' ? 'Video' : 'Voice'} Calldddddddddddddddd'),
          content: Text('$callerName is calling you...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDecline();
              },
              child: const Text('Decline', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onAccept();
              },
              child:
                  const Text('Accept', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _acceptCall(String callId, String callerUserId) {
    // Implement call acceptance logic
    print('Accepting call: $callId from $callerUserId');
    // You can integrate this with your ZegoUIKit call logic
  }

  void _declineCall(String callId) {
    // Implement call decline logic
    print('Declining call: $callId');
    // Cancel the notification
    FCMService.cancelCallNotification(callId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      initialRoute:
          currentUser.id.isEmpty ? PageRouteNames.login : PageRouteNames.home,
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      navigatorKey: widget.navigatorKey,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          children: [
            child!,
            ZegoUIKitPrebuiltCallMiniOverlayPage(
              contextQuery: () {
                return widget.navigatorKey.currentState!.context;
              },
            ),
          ],
        );
      },
    );
  }
}
