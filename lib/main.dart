import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_zego_cloud/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'constants/constants.dart';
import 'services/login_service.dart';
import 'services/permission_services.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   final prefs = await SharedPreferences.getInstance();
//   final cacheUserID = prefs.get(cacheUserIDKey) as String? ?? '';
//   if (cacheUserID.isNotEmpty) {
//     currentUser.id = cacheUserID;
//     currentUser.name = 'user_$cacheUserID';
//   }

//   final navigatorKey = GlobalKey<NavigatorState>();
//   ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

//   ZegoUIKit().initLog().then((value) {
//     // CORRECTED: Use the correct parameter names
//     ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
//       [ZegoUIKitSignalingPlugin()],
//     );

//     runApp(MyApp(navigatorKey: navigatorKey));
//   });
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load user data
  final prefs = await SharedPreferences.getInstance();
  final cacheUserID = prefs.get(cacheUserIDKey) as String? ?? '';
  if (cacheUserID.isNotEmpty) {
    currentUser.id = cacheUserID;
    currentUser.name = 'user_$cacheUserID';
  }

  final navigatorKey = GlobalKey<NavigatorState>();

  // CRITICAL: Set navigator key before any ZegoUIKit initialization
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  runApp(MyApp(navigatorKey: navigatorKey));
}

// Rest of MyApp class remains the same...
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

// @override
// Widget build(BuildContext context) {
//   return MaterialApp(
//     routes: routes,
//     initialRoute:
//         currentUser.id.isEmpty ? PageRouteNames.login : PageRouteNames.home,
//     theme: ThemeData(
//       fontFamily: GoogleFonts.poppins().fontFamily,
//     ),
//     navigatorKey: widget.navigatorKey,
//     builder: (BuildContext context, Widget? child) {
//       return Stack(
//         children: [
//           child!,
//           ZegoUIKitPrebuiltCallMiniOverlayPage(
//             contextQuery: () {
//               return widget.navigatorKey.currentState!.context;
//             },
//           ),
//         ],
//       );
//     },
//   );
// }
// }

class MyApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeBackgroundServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("App lifecycle state: $state");

    switch (state) {
      case AppLifecycleState.resumed:
        // App is in foreground
        break;
      case AppLifecycleState.paused:
        // App is in background but still running
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      default:
        break;
    }
  }

  Future<void> _initializeBackgroundServices() async {
    try {
      // Initialize ZegoUIKit logging
      await ZegoUIKit().initLog();

      // CRITICAL: Enable system calling UI for background calls
      ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
        [ZegoUIKitSignalingPlugin()],
      );

      print("Background services initialized successfully");
    } catch (e) {
      print("Error initializing background services: $e");
    }
  }

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
