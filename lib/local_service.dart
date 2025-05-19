// Import Dart's developer tools for logging
import 'dart:async';
import 'dart:developer';
// Import Flutter's material design components
import 'package:flutter/material.dart';
// Import local notifications package
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Import timezone handling package
import 'package:flutter_timezone/flutter_timezone.dart';
// Import timezone database initialization
import 'package:timezone/data/latest.dart' as tz;
// Import timezone location handling
import 'package:timezone/timezone.dart' as tz;

class LocalService {
  static   StreamController<NotificationResponse> streamController = StreamController();
  static onTap (NotificationResponse response){
    // log(response.id.toString());
    // log(response.payload.toString());
    streamController.add(response);
  }
  // Initialize the notifications plugin instance
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Main notification channel configuration (high priority)
  static const AndroidNotificationChannel _mainChannel = AndroidNotificationChannel(
    'high_importance_channel', // Unique channel identifier
    'High Importance Notifications', // User-visible channel name
    description: 'This channel is used for important notifications.', // Channel description
    importance: Importance.max, // Maximum notification priority (heads-up display)
    playSound: true, // Enable sound for this channel
    sound: RawResourceAndroidNotificationSound('sound2'), // Android sound resource from raw folder
  );

  // Dedicated channel for repeated notifications
  static const AndroidNotificationChannel _repeatedChannel = AndroidNotificationChannel(
    'repeated_channel', // Unique channel identifier
    'Repeated Notifications', // User-visible channel name
    description: 'This channel is used for repeated notifications.', // Channel description
    importance: Importance.high, // High priority (not heads-up)
    playSound: true, // Enable sound for this channel
    sound: RawResourceAndroidNotificationSound('sondfor'), // Sound resource (potential typo in name)
  );

  static Future<void> init() async {
    // Clean up existing notification channels to prevent conflicts
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(_mainChannel.id);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(_repeatedChannel.id);

    // Request notification permissions on Android 13+ devices
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Configure platform-specific initialization settings
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'), // Default app icon for notifications
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true, // Request display permission on iOS
        requestBadgePermission: true, // Request app badge modification permission
        requestSoundPermission: true, // Request sound playback permission
      ),
    );

    // Initialize the notifications plugin with settings
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse:onTap,

    );

    // Create Android notification channels
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_mainChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_repeatedChannel);
  }

  // Display a basic notification with default sound
  static Future<void> showBasicNotification() async {
    // Android-specific configuration
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Channel ID to use
      'High Importance Notifications', // Channel name
      channelDescription: 'This channel is used for important notifications.', // Channel description
      importance: Importance.max, // Maximum priority
      priority: Priority.high, // High priority level
      sound: RawResourceAndroidNotificationSound("sound2"), // Sound resource
      playSound: true, // Enable sound playback
      enableVibration: true, // Enable vibration
      color: Colors.blue, // Notification accent color
      ledColor: Colors.red, // LED indicator color
      ledOnMs: 1000, // LED on duration in milliseconds
      ledOffMs: 500, // LED off duration in milliseconds

    );

    // Platform-independent notification configuration
    const NotificationDetails details = NotificationDetails(
      android: androidDetails, // Android-specific settings
      iOS: DarwinNotificationDetails(
        presentAlert: true, // Show alert on iOS
        presentBadge: true, // Update app badge
        presentSound: true, // Play sound on iOS
        sound: 'sound2.caf', // iOS sound file (Core Audio Format)
      ),
    );

    // Display the notification
    await flutterLocalNotificationsPlugin.show(
      0, // Unique notification ID
      'Hello!', // Notification title
      'This is a notification from Flutter', // Notification body
      details, // Notification configuration
      payload: 'notification_payload', // Optional data payload

    );
  }

  // Display a recurring notification with custom sound
  static Future<void> showRepeatedNotification() async {
    // Android-specific configuration
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'repeated_channel', // Channel ID for repeated notifications
      'Repeated Notifications', // Channel name

      channelDescription: 'This channel is used for repeated notifications.', // Channel description
      importance: Importance.high, // Notification priority
      priority: Priority.high, // System priority level
      sound: UriAndroidNotificationSound('sondfor'), // Potential issue: Should use RawResource instead
      playSound: true, // Enable sound playback
    );

    // Platform-independent configuration
    const NotificationDetails details = NotificationDetails(
      android: androidDetails, // Android settings
      iOS: DarwinNotificationDetails(
        presentAlert: true, // Show iOS alert
        presentBadge: true, // Update app badge
        presentSound: true, // Enable sound
        sound: 'soundfor.caf', // Potential typo mismatch with 'sondfor'
      ),
    );

    // Schedule recurring notification
    await flutterLocalNotificationsPlugin.periodicallyShow(
      1, // Unique notification ID
      'Hello , this is Repeated', // Title
      'This is a Repeated notification from Flutter', // Body
      RepeatInterval.everyMinute, // Repeat every 60 seconds
      details, // Notification settings
      payload: 'notification_payload Repeated', // Data payload
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Schedule a one-time notification
  static Future<void> showScheduleNotification() async {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Get device's local timezone
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Schedule notification 10 seconds from now
    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    // Android-specific configuration
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max, // Maximum priority
      sound: RawResourceAndroidNotificationSound("sound2"), // Sound resource
      playSound: true, // Enable sound
    );

    // Platform-independent configuration
    const NotificationDetails details = NotificationDetails(
      android: androidDetails, // Android settings
      iOS: DarwinNotificationDetails(
        presentAlert: true, // Show iOS alert
        presentBadge: true, // Update badge
        presentSound: true, // Play sound
        sound: 'sound2.caf', // iOS sound file
      ),
    );

    // Schedule timezone-aware notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      2, // Unique notification ID
      'Hello , this is schedule', // Title
      'This is a schedule notification from Flutter', // Body
      scheduledTime, // Scheduled delivery time
      details, // Notification settings
      payload: 'notification_payload', // Data payload
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // iOS time handling mode
      matchDateTimeComponents: DateTimeComponents.time
    );
  }

  // Cancel specific notification by ID
  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Cancel all active notifications
  static Future<void> cancelAllNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}