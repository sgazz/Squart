// Notification Service for PWA
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class NotificationService {
  static bool _isSupported = false;
  static bool _isSubscribed = false;
  String? _subscriptionEndpoint;
  
  // Initialize notification service
  static Future<void> initialize() async {
    if (kIsWeb) {
      _isSupported = await _checkNotificationSupport();
      if (_isSupported) {
        await _requestPermission();
        await _subscribeToNotifications();
      }
    }
  }
  
  // Check if notifications are supported
  static Future<bool> _checkNotificationSupport() async {
    if (kIsWeb) {
      return js.context.hasProperty('Notification');
    }
    return false;
  }
  
  // Request notification permission
  static Future<void> _requestPermission() async {
    if (kIsWeb) {
      final permission = await js.context.callMethod('Notification', ['requestPermission']);
      _isSubscribed = permission == 'granted';
    }
  }
  
  // Subscribe to push notifications
  static Future<void> _subscribeToNotifications() async {
    if (kIsWeb && _isSubscribed) {
      try {
        final registration = await js.context.callMethod('navigator.serviceWorker.ready');
        final subscription = await registration.callMethod('pushManager.subscribe', [
          {
            'userVisibleOnly': true,
            'applicationServerKey': _getVapidPublicKey(),
          }
        ]);
        
        _subscriptionEndpoint = subscription['endpoint'];
        await _sendSubscriptionToServer();
      } catch (e) {
        print('Push subscription failed: $e');
      }
    }
  }
  
  // Get VAPID public key
  static String _getVapidPublicKey() {
    // This should be your VAPID public key
    return 'BEl62iUYgUivxIkv69yViEuiBIa40HIePvX8QyK3x63Lg3K8lX3YzXh4vLQz8Xh4vLQz8Xh4vLQz8Xh4vLQz8';
  }
  
  // Send subscription to server
  static Future<void> _sendSubscriptionToServer() async {
    if (_subscriptionEndpoint != null) {
      // Send subscription endpoint to your backend
      print('Subscription endpoint: $_subscriptionEndpoint');
    }
  }
  
  // Show notification
  static Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    Map<String, dynamic>? data,
  }) async {
    if (kIsWeb && _isSupported && _isSubscribed) {
      await js.context.callMethod('new Notification', [
        title,
        {
          'body': body,
          'icon': icon ?? '/icons/Icon-192.png',
          'data': data,
          'tag': 'squart-notification',
        }
      ]);
    }
  }
  
  // Show game invite notification
  static Future<void> showGameInviteNotification({
    required String playerName,
    required String roomId,
  }) async {
    await showNotification(
      title: 'Game Invite from $playerName',
      body: 'Join the game to play Squart!',
      data: {
        'type': 'game_invite',
        'roomId': roomId,
        'playerName': playerName,
      },
    );
  }
  
  // Check if notifications are supported
  static bool get isSupported => _isSupported;
  
  // Check if subscribed to notifications
  static bool get isSubscribed => _isSubscribed;
}
