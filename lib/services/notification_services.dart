import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class RemoteNotificationService {
  final FirebaseMessaging _firebaseMessaging;
  final FirebaseFirestore _firestore;
  final String _serverKey; // Firebase server key

  RemoteNotificationService(
    this._firebaseMessaging,
    this._firestore,
    this._serverKey,
  );

  Future<void> initNotificationService() async {
    await requestPermission();
    await getToken();
  }

  Future<void> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
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

  Future<String?> getToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _saveToken(token);
      return token;
    }
    return null;
  }

  Future<void> _saveToken(String token) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .set({'token': token}, SetOptions(merge: true));
    }
  }

  Future<String?> getReceiverToken(String receiverId) async {
    final getToken = await _firestore.collection('users').doc(receiverId).get();
    return getToken.data()?['token'];
  }

  Future<void> sendNotification({
    required String body,
    required String senderId,
    required String receiverToken,
  }) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            "to": receiverToken,
            "priority": "high",
            "notification": <String, dynamic>{
              "body": body,
              "title": "New Message",
            },
            "data": <String, String>{
              "click_action": "FLUTTER_NOTIFICATION_CLICK",
              "status": "done",
              "senderId": senderId,
            }
          },
        ),
      );
      // Handle success or use a callback to handle it in the UI
    } catch (e) {
      debugPrint(e.toString());
      // Handle failure or use a callback to handle it in the UI
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
