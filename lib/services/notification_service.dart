import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(initSettings);
  }

  Future<void> showSuccessNotification(String title, String message) async {
    const androidDetails = AndroidNotificationDetails(
      'success_channel',
      'Notificações de Sucesso',
      channelDescription: 'Notificações para operações bem-sucedidas',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.green,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      message,
      details,
    );
  }

  Future<void> showErrorNotification(String title, String message) async {
    const androidDetails = AndroidNotificationDetails(
      'error_channel',
      'Notificações de Erro',
      channelDescription: 'Notificações para erros e avisos',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.red,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      title,
      message,
      details,
    );
  }
}
