# 📱 PWA Implementation - Squart Web Edition

Detaljna implementacija Progressive Web App funkcionalnosti za Squart.

**Datum:** Oktobar 2025  
**Status:** 🚧 Implementation Ready

---

## 🎯 PWA Features Overview

### Core PWA Features
- ✅ **Installable** - Add to Home Screen
- ✅ **Offline Support** - Cached gameplay
- ✅ **Push Notifications** - Game invites
- ✅ **App-like Experience** - Fullscreen, no browser UI
- ✅ **Fast Loading** - Optimized assets
- ✅ **Responsive** - Works on all devices

---

## 📋 Implementation Plan

## 🚀 FAZA 1: Service Worker Implementation (1 dan)

### 1.1 Service Worker Setup

```javascript
// web/sw.js
const CACHE_NAME = 'squart-v1.0.0';
const CACHE_URLS = [
  '/',
  '/main.dart.js',
  '/assets/',
  '/icons/',
  '/manifest.json'
];

// Install event - cache resources
self.addEventListener('install', (event) => {
  console.log('Service Worker installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Caching app shell');
        return cache.addAll(CACHE_URLS);
      })
      .then(() => {
        console.log('Service Worker installed');
        return self.skipWaiting();
      })
  );
});

// Activate event - clean old caches
self.addEventListener('activate', (event) => {
  console.log('Service Worker activating...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('Service Worker activated');
      return self.clients.claim();
    })
  );
});

// Fetch event - serve from cache
self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request)
      .then((response) => {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
  );
});
```

### 1.2 Cache Strategies

```javascript
// Advanced caching strategies
const CACHE_STRATEGIES = {
  // Static assets - cache first
  STATIC_ASSETS: {
    pattern: /\.(js|css|png|jpg|jpeg|gif|svg|woff|woff2)$/,
    strategy: 'cache-first'
  },
  
  // API calls - network first
  API_CALLS: {
    pattern: /\/api\//,
    strategy: 'network-first'
  },
  
  // Game data - cache first with fallback
  GAME_DATA: {
    pattern: /\/game\//,
    strategy: 'cache-first'
  }
};

// Implement caching strategy
const getCachingStrategy = (request) => {
  const url = request.url;
  
  if (CACHE_STRATEGIES.STATIC_ASSETS.pattern.test(url)) {
    return 'cache-first';
  } else if (CACHE_STRATEGIES.API_CALLS.pattern.test(url)) {
    return 'network-first';
  } else if (CACHE_STRATEGIES.GAME_DATA.pattern.test(url)) {
    return 'cache-first';
  }
  
  return 'network-first';
};
```

---

## 📱 FAZA 2: PWA Manifest Enhancement (1 dan)

### 2.1 Enhanced Manifest

```json
// web/manifest.json
{
  "name": "Squart - Logic Board Game",
  "short_name": "Squart",
  "description": "A strategic board game for two players inspired by Domineering",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#1a1a2e",
  "theme_color": "#4A90E2",
  "orientation": "portrait-primary",
  "scope": "/",
  "lang": "en",
  "dir": "ltr",
  
  "icons": [
    {
      "src": "icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-384x384.png",
      "sizes": "384x384",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  
  "categories": ["games", "entertainment"],
  "screenshots": [
    {
      "src": "screenshots/desktop-1.png",
      "sizes": "1280x720",
      "type": "image/png",
      "form_factor": "wide"
    },
    {
      "src": "screenshots/mobile-1.png",
      "sizes": "360x640",
      "type": "image/png",
      "form_factor": "narrow"
    }
  ],
  
  "shortcuts": [
    {
      "name": "New Game",
      "short_name": "New Game",
      "description": "Start a new game",
      "url": "/?action=new-game",
      "icons": [
        {
          "src": "icons/shortcut-new-game.png",
          "sizes": "96x96"
        }
      ]
    },
    {
      "name": "Multiplayer",
      "short_name": "Multiplayer",
      "description": "Play with friends",
      "url": "/?action=multiplayer",
      "icons": [
        {
          "src": "icons/shortcut-multiplayer.png",
          "sizes": "96x96"
        }
      ]
    }
  ],
  
  "related_applications": [],
  "prefer_related_applications": false
}
```

### 2.2 Dynamic Manifest Generation

```dart
// lib/services/manifest_service.dart
class ManifestService {
  static const String manifestTemplate = '''
{
  "name": "Squart - Logic Board Game",
  "short_name": "Squart",
  "description": "A strategic board game for two players",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#1a1a2e",
  "theme_color": "#4A90E2",
  "orientation": "portrait-primary",
  "scope": "/",
  "lang": "en",
  "dir": "ltr",
  "icons": [
    {
      "src": "icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
''';

  static String generateManifest({
    required String themeColor,
    required String backgroundColor,
  }) {
    return manifestTemplate
        .replaceAll('#4A90E2', themeColor)
        .replaceAll('#1a1a2e', backgroundColor);
  }
}
```

---

## 🔔 FAZA 3: Push Notifications (1 dan)

### 3.1 Notification Service

```dart
// lib/services/notification_service.dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isSupported = false;
  bool _isSubscribed = false;
  String? _subscriptionEndpoint;

  Future<void> initialize() async {
    if (kIsWeb) {
      _isSupported = await _checkNotificationSupport();
      if (_isSupported) {
        await _requestPermission();
        await _subscribeToNotifications();
      }
    }
  }

  Future<bool> _checkNotificationSupport() async {
    // Check if browser supports notifications
    return js.context.hasProperty('Notification');
  }

  Future<void> _requestPermission() async {
    final permission = await js.context.callMethod('Notification', ['requestPermission']);
    _isSubscribed = permission == 'granted';
  }

  Future<void> _subscribeToNotifications() async {
    if (_isSubscribed) {
      // Subscribe to push notifications
      final registration = await js.context.callMethod('navigator.serviceWorker.ready');
      final subscription = await registration.callMethod('pushManager.subscribe', [
        {
          'userVisibleOnly': true,
          'applicationServerKey': _getVapidPublicKey(),
        }
      ]);
      
      _subscriptionEndpoint = subscription['endpoint'];
      await _sendSubscriptionToServer();
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    Map<String, dynamic>? data,
  }) async {
    if (_isSupported && _isSubscribed) {
      await js.context.callMethod('new Notification', [
        title,
        {
          'body': body,
          'icon': icon ?? '/icons/icon-192x192.png',
          'data': data,
          'tag': 'squart-notification',
        }
      ]);
    }
  }

  Future<void> showGameInviteNotification({
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
}
```

### 3.2 Background Sync

```javascript
// web/sw.js - Background sync for offline actions
self.addEventListener('sync', (event) => {
  if (event.tag === 'game-sync') {
    event.waitUntil(syncGameData());
  }
});

const syncGameData = async () => {
  try {
    // Get pending game actions from IndexedDB
    const pendingActions = await getPendingActions();
    
    // Send to server
    for (const action of pendingActions) {
      await fetch('/api/games/sync', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(action),
      });
    }
    
    // Clear pending actions
    await clearPendingActions();
  } catch (error) {
    console.error('Background sync failed:', error);
  }
};
```

---

## 💾 FAZA 4: Offline Support (1 dan)

### 4.1 Offline Game Storage

```dart
// lib/services/offline_storage_service.dart
class OfflineStorageService {
  static const String _gameDataKey = 'squart_game_data';
  static const String _userPreferencesKey = 'squart_user_preferences';
  
  // Save game state for offline play
  Future<void> saveGameState(GameState gameState) async {
    final prefs = await SharedPreferences.getInstance();
    final gameData = {
      'board': gameState.board,
      'currentPlayer': gameState.currentPlayer,
      'timer': gameState.timer,
      'gameSettings': gameState.settings.toJson(),
      'moves': gameState.moves.map((move) => move.toJson()).toList(),
      'savedAt': DateTime.now().toIso8601String(),
    };
    
    await prefs.setString(_gameDataKey, jsonEncode(gameData));
  }
  
  // Load saved game state
  Future<GameState?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final gameDataString = prefs.getString(_gameDataKey);
    
    if (gameDataString != null) {
      final gameData = jsonDecode(gameDataString);
      return GameState.fromJson(gameData);
    }
    
    return null;
  }
  
  // Clear saved game
  Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameDataKey);
  }
  
  // Save user preferences
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPreferencesKey, jsonEncode(preferences.toJson()));
  }
  
  // Load user preferences
  Future<UserPreferences> loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesString = prefs.getString(_userPreferencesKey);
    
    if (preferencesString != null) {
      final preferencesData = jsonDecode(preferencesString);
      return UserPreferences.fromJson(preferencesData);
    }
    
    return UserPreferences.defaultPreferences();
  }
}
```

### 4.2 Offline Game Logic

```dart
// lib/services/offline_game_service.dart
class OfflineGameService {
  final OfflineStorageService _storageService;
  
  OfflineGameService(this._storageService);
  
  // Start offline game
  Future<void> startOfflineGame(GameSettings settings) async {
    final gameState = GameState(
      board: _generateBoard(settings.boardSize),
      currentPlayer: 'blue',
      timer: settings.timeLimit,
      settings: settings,
      moves: [],
    );
    
    await _storageService.saveGameState(gameState);
  }
  
  // Make move in offline game
  Future<bool> makeOfflineMove(int row, int col) async {
    final gameState = await _storageService.loadGameState();
    if (gameState == null) return false;
    
    // Validate move
    if (!_isValidMove(gameState, row, col)) return false;
    
    // Make move
    final newGameState = gameState.copyWith(
      board: _updateBoard(gameState.board, row, col, gameState.currentPlayer),
      currentPlayer: gameState.currentPlayer == 'blue' ? 'red' : 'blue',
      moves: [...gameState.moves, Move(row: row, col: col, player: gameState.currentPlayer)],
    );
    
    await _storageService.saveGameState(newGameState);
    return true;
  }
  
  // Check if game is finished
  Future<bool> isGameFinished() async {
    final gameState = await _storageService.loadGameState();
    if (gameState == null) return false;
    
    return _checkGameEnd(gameState);
  }
  
  // Get game result
  Future<GameResult?> getGameResult() async {
    final gameState = await _storageService.loadGameState();
    if (gameState == null) return null;
    
    if (_checkGameEnd(gameState)) {
      return GameResult(
        winner: gameState.currentPlayer == 'blue' ? 'red' : 'blue',
        moves: gameState.moves,
        duration: DateTime.now().difference(gameState.createdAt),
      );
    }
    
    return null;
  }
}
```

---

## 🎨 FAZA 5: Install Prompts & UX (1 dan)

### 5.1 Install Prompt Widget

```dart
// lib/widgets/install_prompt_widget.dart
class InstallPromptWidget extends StatefulWidget {
  @override
  _InstallPromptWidgetState createState() => _InstallPromptWidgetState();
}

class _InstallPromptWidgetState extends State<InstallPromptWidget> {
  bool _showPrompt = false;
  bool _isInstalled = false;
  
  @override
  void initState() {
    super.initState();
    _checkInstallStatus();
  }
  
  Future<void> _checkInstallStatus() async {
    if (kIsWeb) {
      // Check if app is already installed
      final isInstalled = await _isAppInstalled();
      setState(() {
        _isInstalled = isInstalled;
        _showPrompt = !isInstalled;
      });
    }
  }
  
  Future<bool> _isAppInstalled() async {
    // Check if app is running in standalone mode
    return js.context['window']['navigator']['standalone'] == true;
  }
  
  Future<void> _installApp() async {
    if (kIsWeb) {
      // Show install prompt
      await js.context.callMethod('navigator.serviceWorker.ready');
      final deferredPrompt = await js.context.callMethod('navigator.serviceWorker.ready');
      
      if (deferredPrompt != null) {
        await deferredPrompt.callMethod('prompt');
        await deferredPrompt.callMethod('userChoice');
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_showPrompt || _isInstalled) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.install_mobile,
            color: Colors.blue,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'Install Squart',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Add to your home screen for a better gaming experience',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showPrompt = false;
                  });
                },
                child: Text('Not now'),
              ),
              ElevatedButton(
                onPressed: _installApp,
                child: Text('Install'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 5.2 PWA Status Indicator

```dart
// lib/widgets/pwa_status_widget.dart
class PWAStatusWidget extends StatefulWidget {
  @override
  _PWAStatusWidgetState createState() => _PWAStatusWidgetState();
}

class _PWAStatusWidgetState extends State<PWAStatusWidget> {
  bool _isOnline = true;
  bool _isInstalled = false;
  
  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
    _checkInstallStatus();
  }
  
  void _checkConnectionStatus() {
    // Listen to online/offline events
    if (kIsWeb) {
      js.context['window'].callMethod('addEventListener', [
        'online',
        js.allowInterop(() {
          setState(() {
            _isOnline = true;
          });
        })
      ]);
      
      js.context['window'].callMethod('addEventListener', [
        'offline',
        js.allowInterop(() {
          setState(() {
            _isOnline = false;
          });
        })
      ]);
    }
  }
  
  void _checkInstallStatus() {
    if (kIsWeb) {
      final isInstalled = js.context['window']['navigator']['standalone'] == true;
      setState(() {
        _isInstalled = isInstalled;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _isOnline ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isOnline ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: _isOnline ? Colors.green : Colors.red,
          ),
          SizedBox(width: 4),
          Text(
            _isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              color: _isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_isInstalled) ...[
            SizedBox(width: 8),
            Icon(
              Icons.phone_android,
              size: 16,
              color: Colors.blue,
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## 🧪 FAZA 6: Testing & Optimization (1 dan)

### 6.1 PWA Testing Checklist

```dart
// test/pwa_test.dart
void main() {
  group('PWA Functionality Tests', () {
    testWidgets('should show install prompt', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      expect(find.byType(InstallPromptWidget), findsOneWidget);
    });
    
    testWidgets('should cache resources offline', (WidgetTester tester) async {
      // Test offline functionality
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // Simulate offline mode
      // Verify cached resources are available
    });
    
    testWidgets('should show offline indicator', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      expect(find.byType(PWAStatusWidget), findsOneWidget);
    });
  });
}
```

### 6.2 Lighthouse Testing

```bash
# Lighthouse testing script
#!/bin/bash

echo "Running Lighthouse tests..."

# Install Lighthouse
npm install -g lighthouse

# Run Lighthouse audit
lighthouse http://localhost:8080 \
  --output=html \
  --output-path=./lighthouse-report.html \
  --chrome-flags="--headless" \
  --only-categories=pwa,performance,accessibility,best-practices

echo "Lighthouse report generated: ./lighthouse-report.html"
```

### 6.3 Performance Optimization

```dart
// lib/services/performance_service.dart
class PerformanceService {
  static void optimizeForPWA() {
    if (kIsWeb) {
      // Preload critical resources
      _preloadCriticalResources();
      
      // Optimize images
      _optimizeImages();
      
      // Minimize bundle size
      _minimizeBundleSize();
    }
  }
  
  static void _preloadCriticalResources() {
    // Preload main.dart.js
    js.context.callMethod('document.createElement', ['link']).callMethod('setAttribute', ['rel', 'preload']);
    js.context.callMethod('document.createElement', ['link']).callMethod('setAttribute', ['href', '/main.dart.js']);
    js.context.callMethod('document.createElement', ['link']).callMethod('setAttribute', ['as', 'script']);
  }
  
  static void _optimizeImages() {
    // Use WebP format for better compression
    // Implement lazy loading for non-critical images
  }
  
  static void _minimizeBundleSize() {
    // Remove unused code
    // Optimize imports
    // Use tree shaking
  }
}
```

---

## 📊 PWA Metrics & Analytics

### 7.1 PWA Analytics

```dart
// lib/services/pwa_analytics_service.dart
class PWAAnalyticsService {
  static void trackInstallPrompt() {
    // Track when install prompt is shown
    analytics.track('pwa_install_prompt_shown');
  }
  
  static void trackInstallSuccess() {
    // Track successful installation
    analytics.track('pwa_install_success');
  }
  
  static void trackOfflineUsage() {
    // Track offline game sessions
    analytics.track('pwa_offline_game_started');
  }
  
  static void trackPushNotification() {
    // Track push notification interactions
    analytics.track('pwa_push_notification_received');
  }
}
```

### 7.2 Performance Monitoring

```dart
// lib/services/pwa_performance_service.dart
class PWAPerformanceService {
  static void monitorPWAPerformance() {
    if (kIsWeb) {
      // Monitor Core Web Vitals
      _monitorCoreWebVitals();
      
      // Monitor PWA-specific metrics
      _monitorPWAMetrics();
    }
  }
  
  static void _monitorCoreWebVitals() {
    // Largest Contentful Paint (LCP)
    // First Input Delay (FID)
    // Cumulative Layout Shift (CLS)
  }
  
  static void _monitorPWAMetrics() {
    // Time to Interactive (TTI)
    // First Contentful Paint (FCP)
    // Time to First Byte (TTFB)
  }
}
```

---

## 🚀 Deployment Configuration

### 8.1 Firebase Hosting PWA Config

```json
// firebase.json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "/sw.js",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache"
          }
        ]
      },
      {
        "source": "/manifest.json",
        "headers": [
          {
            "key": "Content-Type",
            "value": "application/manifest+json"
          }
        ]
      }
    ]
  }
}
```

### 8.2 Build Script for PWA

```bash
#!/bin/bash
# build_pwa.sh

echo "Building PWA version of Squart..."

# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build for web with PWA optimizations
flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true

# Copy PWA files
cp web/sw.js build/web/
cp web/manifest.json build/web/
cp -r web/icons build/web/

# Optimize assets
cd build/web
find . -name "*.js" -exec gzip -k {} \;
find . -name "*.css" -exec gzip -k {} \;
find . -name "*.html" -exec gzip -k {} \;

echo "PWA build complete!"
echo "Output: build/web/"
```

---

## 📋 PWA Implementation Checklist

### Core PWA Features
- [ ] ✅ Service Worker implemented
- [ ] ✅ Web App Manifest configured
- [ ] ✅ Offline functionality working
- [ ] ✅ Install prompts working
- [ ] ✅ Push notifications working
- [ ] ✅ App-like experience achieved

### Performance
- [ ] ✅ Lighthouse score 90+
- [ ] ✅ Core Web Vitals optimized
- [ ] ✅ Bundle size minimized
- [ ] ✅ Loading time < 3 seconds
- [ ] ✅ Offline functionality tested

### User Experience
- [ ] ✅ Install prompt UX optimized
- [ ] ✅ Offline indicator working
- [ ] ✅ Responsive design maintained
- [ ] ✅ Cross-browser compatibility
- [ ] ✅ Accessibility features

### Deployment
- [ ] ✅ Firebase Hosting configured
- [ ] ✅ PWA headers set
- [ ] ✅ HTTPS enabled
- [ ] ✅ Custom domain configured
- [ ] ✅ Analytics integrated

---

**Napravljeno:** PWA Implementation Plan  
**Datum:** Oktobar 2025  
**Status:** Ready for Implementation 🚀
