import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';


Future<dynamic> _backgroundMessageHandler(Map<String, dynamic> message) async{
  print('backkfrrrrrrrorunbf');
  PushNotificationService pushNotificationService = PushNotificationService();
  await pushNotificationService.myBackgroundMessageHandler(message);
  return Future<void>.value();
}


class PushNotificationService {
  //singleton
  static final PushNotificationService _pushNotificationService = PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initializationSettings;
  final BehaviorSubject<ReceivedNotification> didReceivedLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

  factory PushNotificationService()=>_pushNotificationService;
  PushNotificationService._internal (){
    initFcm();
    initLocalPushPlugin();
    setOnNotificationClick();
    setListenerForLowerVersions();
  }

  initFcm() async{
   if (Platform.isIOS) {
     _fcm.requestNotificationPermissions(IosNotificationSettings());
   }

   _fcm.configure(
     onBackgroundMessage: _backgroundMessageHandler,
     onMessage: (Map<String, dynamic> message) async {
       print('on message called');
       await myBackgroundMessageHandler(message);
     },
     onLaunch: (Map<String, dynamic> message) async {
//       adwait myBackgroundMessageHandler(message);
       print("onLaunch: $message");
     },
     onResume: (Map<String, dynamic> message) async {
//       await myBackgroundMessageHandler(message);
       print("onResume: $message");
     },

   );
   _fcm.getToken().then((token) {
     print('token: $token');
     Firestore.instance
         .collection('user')
         .document('2D6QKiRYGRySe6tRhuI2')
         .updateData({'pushToken': token});
   }).catchError((err) {
     print(err.message.toString());
   });
 }

  initLocalPushPlugin() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    //requesting Ios perm.
    if (Platform.isIOS) {
      _requestIOSPermission();
    }
    initializePlatformSpecifics();
  }

  _requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
      alert: false,
      badge: true,
      sound: true,
    );
  }

  initializePlatformSpecifics() async{
    var initializationSettingsAndroid = AndroidInitializationSettings('app_notf_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        ReceivedNotification receivedNotification = ReceivedNotification(
            id: id.toString(), title: title, body: body);
        didReceivedLocalNotificationSubject.add(receivedNotification);
      },
    );

    initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
  }

  // for Ios versions < 10 .
  // behavioural subject works like a stream but it keeps the last valued stored ..blah blah
  setListenerForLowerVersions() {
    didReceivedLocalNotificationSubject.listen((receivedNotification) {
      print(receivedNotification);
    });
  }
  setOnNotificationClick() async {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String id) async {
          notifications.remove(id);
        });
  }

  Map<String, List<ReceivedNotification>> notifications = {};
  Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async{
    print("i was called");
    ReceivedNotification receivedNotification = ReceivedNotification.getNotification(message);

    String groupKey = 'com.android.example.CK_PUSH';
    String groupChannelId = 'default_notification_channel_id';
    String groupChannelName = 'grouped channel name';
    String groupChannelDescription = 'grouped channel description';

    List<String> lines = [];
    if(notifications.containsKey(receivedNotification.id)){
      notifications[receivedNotification.id].add(receivedNotification);
    }else{
      notifications[receivedNotification.id] = [receivedNotification];
    }
    notifications[receivedNotification.id].forEach((notif) {
      lines.add(notif.body);
    });

    InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
        lines,
        contentTitle: '${lines.length} new messages',
        summaryText: 'zayyad sani');

    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        groupChannelId, groupChannelName, groupChannelDescription,
        importance: Importance.Max,
        styleInformation:  lines.length > 1 ? inboxStyleInformation : DefaultStyleInformation(false, false),
        priority: Priority.Default,
        groupKey: groupKey);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics,
        iOSPlatformChannelSpecifics);

    int localID = notifications.keys.toList().indexOf(receivedNotification.id);
    await flutterLocalNotificationsPlugin.show(
        localID,
        receivedNotification.title,
        receivedNotification.title, platformChannelSpecifics,
        payload: receivedNotification.id
    );
    return Future<void>.value();
  }
}


class ReceivedNotification {
  final String id;
  final String title;
  final String body;
  final Map payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    this.payload,
  });

  factory ReceivedNotification.getNotification(Map<String, dynamic> message){
    return ReceivedNotification(
      id: message["data"]["messageID"],
      title: message["notification"]["title"],
      body: message["notification"]["body"],
      payload: message["data"]
    );
  }
}
