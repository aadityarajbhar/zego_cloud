import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../constants/common.dart';
import '../constants/constants.dart';
import '../constants/secrets.example.dart';

Future<void> login({
  required String userID,
  required String userName,
}) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(cacheUserIDKey, userID);

  currentUser.id = userID;
  currentUser.name = 'user_$userID';
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(cacheUserIDKey);
}

// void onUserLogin() {
//   ZegoUIKitPrebuiltCallInvitationService().init(
//     appID: AppSecrets.apiKey,
//     appSign: AppSecrets.apiSecret,
//     userID: currentUser.id,
//     userName: currentUser.name,
//     plugins: [
//       ZegoUIKitSignalingPlugin(),
//     ],
//     notificationConfig: ZegoCallInvitationNotificationConfig(
//       androidNotificationConfig: ZegoCallAndroidNotificationConfig(
//         channelID: "ZegoUIKit",
//         channelName: "Call Notifications",
//         sound: "call",
//         icon: "call",
//       ),
//       iOSNotificationConfig: ZegoCallIOSNotificationConfig(
//         systemCallingIconName: 'CallKitIcon',
//       ),
//     ),
//     uiConfig: ZegoCallInvitationUIConfig(),
//     requireConfig: (ZegoCallInvitationData data) {
//       final config = (data.invitees.length > 1)
//           ? ZegoCallInvitationType.videoCall == data.type
//               ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
//               : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
//           : ZegoCallInvitationType.videoCall == data.type
//               ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
//               : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

//       config.avatarBuilder = customAvatarBuilder;
//       config.topMenuBar.isVisible = true;
//       config.topMenuBar.buttons
//           .insert(0, ZegoCallMenuBarButtonName.minimizingButton);
//       config.topMenuBar.buttons
//           .insert(1, ZegoCallMenuBarButtonName.soundEffectButton);

//       return config;
//     },
//   );
// }

void onUserLogin() {
  ZegoUIKitPrebuiltCallInvitationService().init(
    appID: AppSecrets.apiKey,
    appSign: AppSecrets.apiSecret,
    userID: currentUser.id,
    userName: currentUser.name,
    plugins: [
      ZegoUIKitSignalingPlugin(),
    ],
    notificationConfig: ZegoCallInvitationNotificationConfig(
      androidNotificationConfig: ZegoCallAndroidNotificationConfig(
        channelID: "ZegoUIKit",
        channelName: "Call Notifications",
        sound: "call",
        icon: "call",
      ),
      iOSNotificationConfig: ZegoCallIOSNotificationConfig(
        systemCallingIconName: 'CallKitIcon',
      ),
    ),
    uiConfig: ZegoCallInvitationUIConfig(
      invitee: ZegoCallInvitationInviteeUIConfig(
        backgroundBuilder: (
          BuildContext context,
          Size size,
          ZegoCallingBuilderInfo info,
        ) {
          return Container();
        },
      ),
    ),
    requireConfig: (ZegoCallInvitationData data) {
      final config = (data.invitees.length > 1)
          ? ZegoCallInvitationType.videoCall == data.type
              ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
              : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
          : ZegoCallInvitationType.videoCall == data.type
              ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

      config.avatarBuilder = customAvatarBuilder;
      config.topMenuBar.isVisible = true;
      config.topMenuBar.buttons
          .insert(0, ZegoCallMenuBarButtonName.minimizingButton);
      config.topMenuBar.buttons
          .insert(1, ZegoCallMenuBarButtonName.soundEffectButton);

      return config;
    },
  );
}

void onUserLogout() {
  ZegoUIKitPrebuiltCallInvitationService().uninit();
}

class ZegoCallingBackgroundBuilderInfo {
  ZegoCallingBackgroundBuilderInfo({
    required this.inviter,
    required this.invitees,
    required this.callType,
  });

  final ZegoUIKitUser inviter;
  final List<ZegoUIKitUser> invitees;
  final ZegoCallType callType;
}
