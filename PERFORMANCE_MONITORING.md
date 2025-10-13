# 📊 Performance Monitoring System - Debug & Tracking

**Datum**: 13. oktobar 2025.  
**Status**: ✅ IMPLEMENTIRANO  
**Svrha**: Tracking resursa i performansi tokom app lifecycle-a

---

## 🎯 Problem:

iOS verzija ima **crash pri ponovnom pokretanju** na fizičkom uređaju.  
Potreban je **detaljni monitoring** da vidimo:
- Šta se dešava tokom startup-a
- Koliko memorije se koristi
- Koje operacije traju dugo
- Gde dolazi do problema

---

## 🔧 Rešenje: PerformanceMonitor

Kreiran je **centralizovani monitoring sistem** koji prati:

### **1. Startup Tracking**
- Vreme svakog koraka tokom pokretanja
- Redosled operacija
- Trajanje svake operacije

### **2. Memory Tracking**
- Initial memory usage
- Current memory usage
- Memory delta (promena)
- Memory snapshots na key points

### **3. Lifecycle Tracking**
- Widget initState/dispose
- App lifecycle events (paused/resumed)
- Service creation (lazy load tracking)

### **4. Error Tracking**
- Catch-uje sve greške
- Loguje stack trace
- Pokazuje gde je fail-ovalo

---

## 📁 Implementacija:

### **Novi Fajl: `lib/core/utils/performance_monitor.dart`**

```dart
/// Performance monitor za tracking startup i runtime performance
class PerformanceMonitor {
  static final PerformanceMonitor instance = PerformanceMonitor._();
  
  // Tracking methods
  void init();                           // Initialize monitoring
  void log(String message, [Map<String, dynamic>? metadata]);
  void startTracking(String operation);
  void endTracking(String operation);
  void logMemory(String label);
  void logLifecycle(String widget, String event);
  void logError(String operation, Object error);
  void printReport();                    // Print complete report
}
```

### **Easy-to-use Extension:**

```dart
'OperationName'.startTracking();
// ... do work ...
'OperationName'.endTracking({'result': 'success'});
```

---

## 🔌 Integracije:

### **1. main.dart - App Startup**

```dart
void main() async {
  // Start monitoring FIRST
  PerformanceMonitor.instance.init();
  PerformanceMonitor.instance.log('🎯 main() started');
  
  'WidgetsFlutterBinding'.startTracking();
  WidgetsFlutterBinding.ensureInitialized();
  'WidgetsFlutterBinding'.endTracking();
  
  'HapticManager.init'.startTracking();
  await HapticManager.instance.init();
  'HapticManager.init'.endTracking();
  
  // ... više tracking-a
  
  PerformanceMonitor.instance.logMemory('Before runApp');
  runApp(const SquartApp());
}
```

### **2. SquartApp - Lifecycle & First Frame**

```dart
@override
void initState() {
  super.initState();
  PerformanceMonitor.instance.logLifecycle('SquartApp', 'initState');
  
  // Log first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    PerformanceMonitor.instance.log('🎨 First frame rendered');
    PerformanceMonitor.instance.logMemory('After first frame');
    PerformanceMonitor.instance.printReport();  // 📊 PRINT FULL REPORT
  });
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  PerformanceMonitor.instance.log('🔄 Lifecycle: ${state.name}');
  PerformanceMonitor.instance.logMemory('Lifecycle: ${state.name}');
  
  if (state == AppLifecycleState.paused) {
    PerformanceMonitor.instance.log('⏸️  App paused');
  } else if (state == AppLifecycleState.resumed) {
    PerformanceMonitor.instance.log('▶️  App resumed');
    PerformanceMonitor.instance.logMemory('After resume');
  }
}
```

### **3. ThemeProvider - SharedPreferences Tracking**

```dart
ThemeProvider() {
  PerformanceMonitor.instance.log('🎨 ThemeProvider created');
  _loadPreferences();
}

Future<void> _loadPreferences() async {
  'ThemeProvider.loadPreferences'.startTracking();
  
  try {
    'SharedPreferences.getInstance'.startTracking();
    final prefs = await SharedPreferences.getInstance();
    'SharedPreferences.getInstance'.endTracking();
    
    // ... load settings ...
    
    'ThemeProvider.loadPreferences'.endTracking({'theme': 'dark'});
  } catch (e) {
    PerformanceMonitor.instance.logError('ThemeProvider.loadPreferences', e);
  }
}
```

### **4. GameProvider - Lazy Service Creation**

```dart
GameLogicService get _gameLogic {
  if (__gameLogic == null) {
    PerformanceMonitor.instance.log('🎮 Creating GameLogicService (lazy)');
    __gameLogic = GameLogicService();
  }
  return __gameLogic!;
}
```

### **5. AudioManager - Audio Load Tracking**

```dart
Future<void> init() async {
  PerformanceMonitor.instance.log('🔊 AudioManager.init started');
  'AudioManager.createPlayers'.startTracking();
  
  // Create players...
  'AudioManager.createPlayers'.endTracking();
  
  'AudioManager.loadAssets'.startTracking();
  await Future.wait([...setAsset calls...]);
  'AudioManager.loadAssets'.endTracking();
  
  PerformanceMonitor.instance.log('✅ AudioManager initialized');
  PerformanceMonitor.instance.logMemory('After AudioManager init');
}
```

---

## 📊 Output Example:

Kada pokreneš app, u **Xcode Console** ćeš videti:

```
📊 [+0ms] 🚀 App Started memory=45.2MB
📊 [+2ms] 🎯 main() started
📊 [+3ms] ⏱️  START: WidgetsFlutterBinding
📊 [+8ms] ✅ END: WidgetsFlutterBinding duration=5ms
📊 [+9ms] ⏱️  START: HapticManager.init
📊 [+10ms] ✅ END: HapticManager.init duration=1ms
📊 [+12ms] ⏱️  START: AudioManager.init
📊 [+13ms] 🔊 AudioManager.init started
📊 [+14ms] ⏱️  START: AudioManager.createPlayers
📊 [+18ms] ✅ END: AudioManager.createPlayers duration=4ms
📊 [+19ms] ⏱️  START: AudioManager.loadAssets
📊 [+245ms] ✅ END: AudioManager.loadAssets duration=226ms
📊 [+246ms] ✅ AudioManager initialized
📊 [+247ms] 💾 MEMORY: After AudioManager init current=52.1MB, delta=+6.9MB
📊 [+248ms] 🚀 Launching app...
📊 [+249ms] 💾 MEMORY: Before runApp current=52.3MB, delta=+7.1MB
📊 [+255ms] 🎨 ThemeProvider created
📊 [+256ms] ⏱️  START: ThemeProvider.loadPreferences
📊 [+257ms] ⏱️  START: SharedPreferences.getInstance
📊 [+289ms] ✅ END: SharedPreferences.getInstance duration=32ms
📊 [+290ms] ✅ END: ThemeProvider.loadPreferences duration=34ms, theme=dark
📊 [+293ms] 🎮 GameProvider created
📊 [+312ms] 🔄 LIFECYCLE: SquartApp.initState
📊 [+425ms] 🎨 First frame rendered
📊 [+426ms] 💾 MEMORY: After first frame current=58.7MB, delta=+13.5MB

╔══════════════════════════════════════════════════════════════╗
║                 📊 PERFORMANCE REPORT                        ║
╚══════════════════════════════════════════════════════════════╝

⏱️  TIMING SUMMARY:
  • WidgetsFlutterBinding: 5ms
  • HapticManager.init: 1ms
  • AudioManager.createPlayers: 4ms
  • AudioManager.loadAssets: 226ms
  • ThemeProvider.loadPreferences: 34ms
  • SharedPreferences.getInstance: 32ms

💾 MEMORY SUMMARY:
  • initial: 45.2MB
  • current: 58.7MB
  • delta: +13.5MB

📝 DETAILED LOG:
  [+0ms] 🚀 App Started memory=45.2MB
  [+2ms] 🎯 main() started
  ... (full log)
```

---

## 🔍 Kako Koristiti Za Debug:

### **1. Pronađi Slow Operations:**

Gledaj **TIMING SUMMARY** - sve što je > 100ms je potencijalni problem:

```
⏱️  TIMING SUMMARY:
  • AudioManager.loadAssets: 226ms  ← Slow!
  • SharedPreferences.getInstance: 32ms  ← OK
```

### **2. Tracking Memory Leaks:**

Gledaj **MEMORY SUMMARY** delta:

```
💾 MEMORY SUMMARY:
  • initial: 45.2MB
  • current: 150.7MB  ← Previše!
  • delta: +105.5MB  ← Memory leak!
```

### **3. Find Crash Location:**

Gledaj poslednji log pre crash-a u DETAILED LOG:

```
[+312ms] 🎮 GameProvider created
[+425ms] 🎨 First frame rendered
[+1250ms] 🔄 Lifecycle: paused       ← Last log
[+1255ms] ❌ ERROR: AudioManager.dispose  ← CRASH!
```

### **4. Lifecycle Issues:**

Prati lifecycle events:

```
[+1250ms] 🔄 Lifecycle: paused
[+1251ms] ⏸️  App paused
[+1252ms] 💾 MEMORY: Lifecycle: paused current=58.7MB
[+2350ms] 🔄 Lifecycle: resumed
[+2351ms] ▶️  App resumed
[+2352ms] 💾 MEMORY: After resume current=92.1MB  ← Memory spike!
```

---

## 🧪 Testing Steps:

### **1. Cold Start Test:**

```bash
# Kill app completely
# Launch from icon
# Check Xcode console for report
```

**Look for:**
- First frame time (should be < 500ms)
- Memory after first frame (should be < 100MB)
- Any errors during startup

### **2. Resume Test (KRITIČAN za tvoj problem):**

```bash
# Launch app
# Swipe to background
# Wait 5 seconds
# Swipe back to app
# Check console
```

**Look for:**
- Memory before pause
- Memory after resume
- Any errors during resume
- Lifecycle events order

### **3. Repeated Launches:**

```bash
# Launch app → background → kill → repeat 5x
# Check if memory grows each time
```

**Look for:**
- Consistent memory usage
- No memory leaks between launches
- No errors accumulating

---

## 📱 Kako Videti Output na iOS:

### **Metod 1: Xcode Console**

1. Open **Xcode**
2. Window → Devices and Simulators
3. Select your iPhone
4. Click **Open Console** (bottom left)
5. Launch app
6. Filter by "📊" emoji da vidiš samo performance logs

### **Metod 2: Terminal (Real-time)**

```bash
# macOS
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"'

# ili
idevicesyslog | grep "📊"
```

---

## 🎯 Što Očekivati:

### **Normalan Startup:**

```
Total time to first frame: 400-500ms
Memory after first frame: 50-80MB
No errors
SharedPreferences: 20-50ms
AudioManager.loadAssets: 200-300ms
```

### **Problem Indicators:**

- ❌ First frame > 1000ms
- ❌ Memory > 150MB after startup
- ❌ Any ❌ ERROR logs
- ❌ Memory spike na resume > +50MB
- ❌ Repeated crashes na isti način

---

## 🔧 Built Status:

```
✅ PerformanceMonitor created
✅ Integrated in main.dart
✅ Integrated in providers
✅ Integrated in AudioManager
✅ flutter build ios: SUCCESS (24.0s)
✅ App size: 16.7MB
```

---

## 📝 Files Modified (5):

1. ✅ `lib/core/utils/performance_monitor.dart` (NEW)
2. ✅ `lib/main.dart`
3. ✅ `lib/providers/theme_provider.dart`
4. ✅ `lib/providers/game_provider.dart`
5. ✅ `lib/core/utils/audio_manager.dart`

---

## 🚀 Next Steps:

1. **Deploy na iPhone**
2. **Pokreni app i pročitaj report**
3. **Swipe to background i back** (repeat crash scenario)
4. **Screenshot console output**
5. **Analiziraj gde je problem**

---

**Monitoring je spreman! Deploy na iPhone i prati konzolu.** 📊🔍

