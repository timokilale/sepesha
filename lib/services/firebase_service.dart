// lib/services/firebase_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _messaging.getToken();
    // print('FCM Token: $token'); // TODO: Use proper logging
    
    // Store token locally for future backend integration
    await _storeTokenLocally(token);

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showLocalNotification(message);
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sepesha_channel',
      'Sepesha Notifications',
      channelDescription: 'Notifications for Sepesha app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Sepesha',
      message.notification?.body ?? 'You have a new notification',
      details,
      payload: message.data.toString(),
    );
  }

  // Missing methods
  static Future<void> _storeTokenLocally(String? token) async {
    if (token != null) {
      // Store FCM token in shared preferences for future backend integration
      // print('Storing FCM token locally: $token'); // TODO: Use proper logging
      // TODO: Implement actual storage when needed
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('fcm_token', token);
    }
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(initializationSettings);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // print('Handling background message: ${message.messageId}'); // TODO: Use proper logging
    // Background messages are automatically displayed by the system
  }

  static Future<void> showCustomNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    List<dynamic>? actions, // Simplified for now
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'sepesha_channel',
      'Sepesha Notifications',
      channelDescription: 'Notifications for Sepesha app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: data?.toString(),
    );
  }
}