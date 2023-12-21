import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_advanced/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

///steps to use remote notification
///1- we need user token to send notification to him so we make a method to get user token
///2- we need to save user token in firestore so we make a method to save user token inside user coll
///so to apply this steps we need to get and save token therfore we go to signup method after
///we create user and then we first request permission then we get token
///now we need to save token on login so user can get notification so we go to login method
///and we request permission then we get token and save it
///3- now we need to send notification to user so we make a method to send notification
///4- now we need to get receiver token to send notification to him so we make a method to get
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message ${message.messageId}');
}

class RemoteNotificationService {
  static const key =
      'AAAAnqzCkZQ:APA91bGVTGo1VqbR5hTDgf0NK9p5sLkkOqDsi9ktY2wPJQSKoBbh5NHO8bWT4_5p4TEfEs8gq7BBU_A9ByCJtTyg-AISQUZJlpPS7iXbfCPjdRFn6bkJAyEuuo3hw7dihTy2n29-VG3Z';
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

   void firebaseNotification() {
    print('firebaseNotification');
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print('onMessageOpenedApp: $message');
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        await LocalNotificationsServices.showText(
          title: message.notification!.title!,
          body: message.notification!.body!,
          fln: flutterLocalNotificationsPlugin,
        );
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> requestPermission() async {
    final message = FirebaseMessaging.instance;
    final settings = await message.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    _saveToken(token!);
  }

  Future<void> _saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'token': token},
            SetOptions(merge: true)); //replace token each time we login
  }

  Future<String> getReceiverToken(String receiverId) async {
    final getToken = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();
    return await getToken.data()!['token'];
  }

  Future<void> sendNotification({
    required String body,
    required String senderId,
    required String receiverToken,
  }) async {
    try {
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

      // Debug log to check if the receiver token is available
      print('Receiver Token: $receiverToken');

      final Map<String, dynamic> payload = {
        'to': receiverToken,
        'priority': 'high',
        'notification': {
          'body': body,
          'title': 'New Message',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
          'senderId': senderId,
        },
      };

      final http.Response response = await http.post(
        Uri.parse(fcmUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$key',
        },
        body: jsonEncode(payload),
      );

      // Debug log to check the HTTP response status code
      print('FCM Response Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Notification sent successfully!');
      } else {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

class LocalNotificationsServices {
  static Future init(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var andriodInitilize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initilizationSettings =
        InitializationSettings(android: andriodInitilize);
    await flutterLocalNotificationsPlugin.initialize(initilizationSettings);
    // Initialize time zones
  }

  static Future showText(
      {var id = 0,
      required String title,
      required String body,
      var payload,
      required FlutterLocalNotificationsPlugin fln}) async {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.high,
    );
    var not = NotificationDetails(android: androidNotificationDetails);
    await fln.show(id, title, body, not);
  }
}
