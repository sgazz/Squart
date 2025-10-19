// PWA Service for Squart
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

class PWAService {
  static bool _isSupported = false;
  static bool _isInstalled = false;
  static bool _isOnline = true;
  
  // Initialize PWA service
  static Future<void> initialize() async {
    if (kIsWeb) {
      _isSupported = await _checkPWASupport();
      _isInstalled = await _checkInstallStatus();
      _setupOnlineStatusListener();
      _registerServiceWorker();
    }
  }
  
  // Check if PWA is supported
  static Future<bool> _checkPWASupport() async {
    if (kIsWeb) {
      return js.context.hasProperty('serviceWorker') && 
             js.context.hasProperty('navigator') &&
             js.context['navigator'].hasProperty('serviceWorker');
    }
    return false;
  }
  
  // Check if app is installed
  static Future<bool> _checkInstallStatus() async {
    if (kIsWeb) {
      return js.context['window']['navigator']['standalone'] == true;
    }
    return false;
  }
  
  // Setup online/offline status listener
  static void _setupOnlineStatusListener() {
    if (kIsWeb) {
      js.context['window'].callMethod('addEventListener', [
        'online',
        js.allowInterop(() {
          _isOnline = true;
          _onConnectionStatusChanged(true);
        })
      ]);
      
      js.context['window'].callMethod('addEventListener', [
        'offline',
        js.allowInterop(() {
          _isOnline = false;
          _onConnectionStatusChanged(false);
        })
      ]);
    }
  }
  
  // Register service worker
  static Future<void> _registerServiceWorker() async {
    if (kIsWeb && _isSupported) {
      try {
        final registration = await js.context.callMethod('navigator.serviceWorker.register', ['/sw.js']);
        print('Service Worker registered successfully');
      } catch (e) {
        print('Service Worker registration failed: $e');
      }
    }
  }
  
  // Show install prompt
  static Future<void> showInstallPrompt() async {
    if (kIsWeb && _isSupported && !_isInstalled) {
      // This will be handled by the browser's native install prompt
      // or by our custom install prompt widget
    }
  }
  
  // Check if app can be installed
  static bool get canInstall => _isSupported && !_isInstalled;
  
  // Check if app is installed
  static bool get isInstalled => _isInstalled;
  
  // Check if PWA is supported
  static bool get isSupported => _isSupported;
  
  // Check if online
  static bool get isOnline => _isOnline;
  
  // Connection status changed callback
  static void _onConnectionStatusChanged(bool isOnline) {
    // This can be used to notify the UI about connection changes
    print('Connection status changed: ${isOnline ? 'Online' : 'Offline'}');
  }
}
