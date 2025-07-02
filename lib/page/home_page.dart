// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_styled_toast/flutter_styled_toast.dart';

// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// import '../constants/constants.dart';
// import '../services/login_service.dart';
// import '../services/permission_services.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<StatefulWidget> createState() => HomePageState();
// }

// class HomePageState extends State<HomePage> {
//   final TextEditingController singleInviteeUserIDTextCtrl =
//       TextEditingController();
//   final TextEditingController groupInviteeUserIDsTextCtrl =
//       TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _checkAndRequestPermissions();
//   }

//   Future<void> _checkAndRequestPermissions() async {
//     bool permissionsGranted = await PermissionService.requestCallPermissions();

//     if (!permissionsGranted) {
//       // Show dialog to user about required permissions
//       _showPermissionDialog();
//     }
//   }

//   void _showPermissionDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Permissions Required'),
//           content: Text(
//             'This app needs camera, microphone, and system alert window permissions to work properly with background calling. Please grant these permissions in settings.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 PermissionService.openSystemSettings();
//               },
//               child: Text('Open Settings'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Rest of your HomePage code remains the same...
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Video Call Flutter',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Color.fromARGB(255, 5, 204, 108),
//               )),
//           actions: [
//             logoutButton(),
//           ],
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Welcome, To Video Call Flutter application plase enter the user id and group id to make a call",
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Your User Id: ${currentUser.id}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 30),
//                 inviteeInputRow(
//                   title: 'Invitee name',
//                   description:
//                       "Please enter the user id of the invitee to make a call with the user",
//                   textController: singleInviteeUserIDTextCtrl,
//                 ),
//                 const Divider(height: 20, color: Colors.grey),
//                 inviteeInputRow(
//                   title: 'Group name',
//                   description:
//                       "Please enter the user id of the invitee to make a call with the group",
//                   textController: groupInviteeUserIDsTextCtrl,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Your existing widget methods remain the same...
//   Widget logoutButton() {
//     return Ink(
//       child: IconButton(
//         icon: const Icon(Icons.logout),
//         iconSize: 24,
//         color: Colors.red,
//         onPressed: () {
//           logout().then((value) {
//             onUserLogout();
//             Navigator.pushNamed(
//               context,
//               PageRouteNames.login,
//             );
//           });
//         },
//       ),
//     );
//   }

//   Widget inviteeInputRow({
//     required String title,
//     required String description,
//     required TextEditingController textController,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 20),
//         Text(
//           description,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(height: 10),
//         inviteeIDFormField(
//           textCtrl: textController,
//           formatters: [
//             FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
//           ],
//           labelText: 'Invitee ID',
//           hintText: 'Please enter invitee ID',
//         ),
//         const SizedBox(height: 10),
//         Row(
//           children: [
//             sendCallButton(
//               isVideoCall: false,
//               inviteeUsersIDTextCtrl: textController,
//               onCallFinished: onSendCallInvitationFinished,
//             ),
//             const SizedBox(width: 10),
//             sendCallButton(
//               isVideoCall: true,
//               inviteeUsersIDTextCtrl: textController,
//               onCallFinished: onSendCallInvitationFinished,
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget inviteeIDFormField({
//     required TextEditingController textCtrl,
//     List<TextInputFormatter>? formatters,
//     String hintText = '',
//     String labelText = '',
//   }) {
//     const textStyle = TextStyle(fontSize: 12.0);
//     return TextFormField(
//       style: textStyle,
//       controller: textCtrl,
//       inputFormatters: formatters,
//       decoration: InputDecoration(
//         isDense: true,
//         hintText: hintText,
//         hintStyle: textStyle,
//         labelText: labelText,
//         labelStyle: textStyle,
//         border: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//         ),
//         filled: true,
//         contentPadding:
//             const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
//       ),
//     );
//   }

//   Widget sendCallButton({
//     required bool isVideoCall,
//     required TextEditingController inviteeUsersIDTextCtrl,
//     void Function(String code, String message, List<String>)? onCallFinished,
//   }) {
//     return ValueListenableBuilder<TextEditingValue>(
//       valueListenable: inviteeUsersIDTextCtrl,
//       builder: (context, inviteeUserID, _) {
//         final invitees =
//             getInvitesFromTextCtrl(inviteeUsersIDTextCtrl.text.trim());

//         return ZegoSendCallInvitationButton(
//           isVideoCall: isVideoCall,
//           invitees: invitees,
//           resourceID: 'zego_data',
//           iconSize: const Size(40, 40),
//           buttonSize: const Size(50, 50),
//           onPressed: onCallFinished,
//         );
//       },
//     );
//   }

//   void onSendCallInvitationFinished(
//     String code,
//     String message,
//     List<String> errorInvitees,
//   ) {
//     if (errorInvitees.isNotEmpty) {
//       var userIDs = '';
//       for (var index = 0; index < errorInvitees.length; index++) {
//         if (index >= 5) {
//           userIDs += '... ';
//           break;
//         }
//         final userID = errorInvitees.elementAt(index);
//         userIDs += '$userID ';
//       }
//       if (userIDs.isNotEmpty) {
//         userIDs = userIDs.substring(0, userIDs.length - 1);
//       }

//       var errorMessage = "User doesn't exist or is offline: $userIDs";
//       if (code.isNotEmpty) {
//         errorMessage += ', code: $code, message:$message';
//       }
//       showToast(
//         errorMessage,
//         position: StyledToastPosition.top,
//         context: context,
//       );
//     } else if (code.isNotEmpty) {
//       showToast(
//         'code: $code, message:$message',
//         position: StyledToastPosition.top,
//         context: context,
//       );
//     }
//   }
// }
// // function parses the invitee IDs from the input and creates user objects for the call invitation.ZegoUIKitUser is a class that represents a user in the ZegoUIKit SDK. The function creates a list of ZegoUIKitUser objects from the invitee IDs entered in the text field. The function splits the invitee IDs by commas and creates a ZegoUIKitUser object for each ID. The function then adds the ZegoUIKitUser objects to a list and returns the list.

// List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
//   final invitees = <ZegoUIKitUser>[];
//   final inviteeIDs = textCtrlText.trim().replaceAll('，', '');
//   inviteeIDs.split(',').forEach((inviteeUserID) {
//     if (inviteeUserID.isEmpty) return;

//     invitees.add(ZegoUIKitUser(
//       id: inviteeUserID,
//       name: 'user_$inviteeUserID',
//     ));
//   });
//   return invitees;
// }

// Updated HomePage with FCM integration
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:uuid/uuid.dart';

import '../constants/constants.dart';
import '../services/fcm_service.dart';
import '../services/login_service.dart';
import '../services/permission_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController singleInviteeUserIDTextCtrl =
      TextEditingController();
  final TextEditingController groupInviteeUserIDsTextCtrl =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
    _displayFCMToken();
  }

  Future<void> _checkAndRequestPermissions() async {
    bool permissionsGranted = await PermissionService.requestCallPermissions();

    // if (!permissionsGranted) {
    //   _showPermissionDialog();
    // }
  }

  Future<void> _displayFCMToken() async {
    String? fcmToken = await FCMService.getFCMToken();
    if (fcmToken != null) {
      print('Current FCM Token: $fcmToken');
    }
  }

  // void _showPermissionDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Permissions Required'),
  //         content: const Text(
  //           'This app needs camera, microphone, notification, and system alert window permissions to work properly with background calling. Please grant these permissions in settings.',
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               PermissionService.openSystemSettings();
  //             },
  //             child: const Text('Open Settings'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video Call Flutter',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 5, 204, 108),
              )),
          actions: [
            logoutButton(),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to Video Call Flutter application. Please enter the user id to make a call. Background calling is now supported with FCM notifications.",
                ),
                const SizedBox(height: 10),
                Text(
                  'Your User Id: ${currentUser.id}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                FutureBuilder<String?>(
                  future: FCMService.getFCMToken(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'FCM Token: ${snapshot.data!.substring(0, 20)}...',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      );
                    }
                    return const Text('Loading FCM token...');
                  },
                ),
                const SizedBox(height: 30),
                inviteeInputRow(
                  title: 'Invitee name',
                  description:
                      "Please enter the user id of the invitee to make a call with the user",
                  textController: singleInviteeUserIDTextCtrl,
                ),
                const Divider(height: 20, color: Colors.grey),
                inviteeInputRow(
                  title: 'Group name',
                  description:
                      "Please enter the user ids (comma separated) to make a group call",
                  textController: groupInviteeUserIDsTextCtrl,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logoutButton() {
    return Ink(
      child: IconButton(
        icon: const Icon(Icons.logout),
        iconSize: 24,
        color: Colors.red,
        onPressed: () {
          logout().then((value) {
            onUserLogout();
            Navigator.pushNamed(
              context,
              PageRouteNames.login,
            );
          });
        },
      ),
    );
  }

  Widget inviteeInputRow({
    required String title,
    required String description,
    required TextEditingController textController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        inviteeIDFormField(
          textCtrl: textController,
          formatters: [
            FilteringTextInputFormatter.allow(RegExp('[0-9,]')),
          ],
          labelText: 'Invitee ID',
          hintText: 'Please enter invitee ID',
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            sendCallButton(
              isVideoCall: false,
              inviteeUsersIDTextCtrl: textController,
              onCallFinished: onSendCallInvitationFinished,
            ),
            const SizedBox(width: 10),
            sendCallButton(
              isVideoCall: true,
              inviteeUsersIDTextCtrl: textController,
              onCallFinished: onSendCallInvitationFinished,
            ),
            const SizedBox(width: 10),
            // FCM Call Button
            fcmCallButton(
              isVideoCall: false,
              inviteeUsersIDTextCtrl: textController,
            ),
            const SizedBox(width: 10),
            fcmCallButton(
              isVideoCall: true,
              inviteeUsersIDTextCtrl: textController,
            ),
          ],
        ),
      ],
    );
  }

  Widget inviteeIDFormField({
    required TextEditingController textCtrl,
    List<TextInputFormatter>? formatters,
    String hintText = '',
    String labelText = '',
  }) {
    const textStyle = TextStyle(fontSize: 12.0);
    return TextFormField(
      style: textStyle,
      controller: textCtrl,
      inputFormatters: formatters,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: textStyle,
        labelText: labelText,
        labelStyle: textStyle,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      ),
    );
  }

  Widget sendCallButton({
    required bool isVideoCall,
    required TextEditingController inviteeUsersIDTextCtrl,
    void Function(String code, String message, List<String>)? onCallFinished,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: inviteeUsersIDTextCtrl,
      builder: (context, inviteeUserID, _) {
        final invitees =
            getInvitesFromTextCtrl(inviteeUsersIDTextCtrl.text.trim());

        return ZegoSendCallInvitationButton(
          isVideoCall: isVideoCall,
          invitees: invitees,
          resourceID: 'zego_call',
          iconSize: const Size(40, 40),
          buttonSize: const Size(50, 50),
          onPressed: onCallFinished,
        );
      },
    );
  }

  // New FCM Call Button
  Widget fcmCallButton({
    required bool isVideoCall,
    required TextEditingController inviteeUsersIDTextCtrl,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: inviteeUsersIDTextCtrl,
      builder: (context, inviteeUserID, _) {
        final invitees = inviteeUsersIDTextCtrl.text.trim();
        final isEnabled = invitees.isNotEmpty;

        return Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isEnabled
                ? (isVideoCall ? Colors.blue : Colors.green)
                : Colors.grey,
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            icon: Icon(
              isVideoCall ? Icons.videocam : Icons.call,
              color: Colors.white,
              size: 24,
            ),
            onPressed: isEnabled
                ? () => _sendFCMCallInvitation(invitees, isVideoCall)
                : null,
          ),
        );
      },
    );
  }

  // Send FCM call invitation
  Future<void> _sendFCMCallInvitation(
      String inviteeIds, bool isVideoCall) async {
    final inviteeList = inviteeIds
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();

    if (inviteeList.isEmpty) {
      showToast(
        'Please enter valid invitee IDs',
        position: StyledToastPosition.top,
        context: context,
      );
      return;
    }

    final callId = const Uuid().v4();
    final callType = isVideoCall ? 'video' : 'voice';

    try {
      // Send FCM call invitation to each invitee
      for (String inviteeId in inviteeList) {
        await FCMService.sendCallInvitation(
          receiverUserId: inviteeId,
          callerName: currentUser.name,
          callType: callType,
          callId: callId,
        );
      }

      showToast(
        'FCM Call invitation sent successfully',
        position: StyledToastPosition.top,
        context: context,
      );
    } catch (e) {
      showToast(
        'Failed to send FCM call invitation: $e',
        position: StyledToastPosition.top,
        context: context,
      );
    }
  }

  void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvitees,
  ) {
    if (errorInvitees.isNotEmpty) {
      var userIDs = '';
      for (var index = 0; index < errorInvitees.length; index++) {
        if (index >= 5) {
          userIDs += '... ';
          break;
        }
        final userID = errorInvitees.elementAt(index);
        userIDs += '$userID ';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }

      var errorMessage = "User doesn't exist or is offline: $userIDs";
      if (code.isNotEmpty) {
        errorMessage += ', code: $code, message:$message';
      }
      showToast(
        errorMessage,
        position: StyledToastPosition.top,
        context: context,
      );
    } else if (code.isNotEmpty) {
      showToast(
        'code: $code, message:$message',
        position: StyledToastPosition.top,
        context: context,
      );
    }
  }
}

// Updated function to parse invitee IDs
List<ZegoUIKitUser> getInvitesFromTextCtrl(String textCtrlText) {
  final invitees = <ZegoUIKitUser>[];
  final inviteeIDs = textCtrlText.trim().replaceAll('，', '');
  inviteeIDs.split(',').forEach((inviteeUserID) {
    if (inviteeUserID.isEmpty) return;

    invitees.add(ZegoUIKitUser(
      id: inviteeUserID,
      name: 'user_$inviteeUserID',
    ));
  });
  return invitees;
}
