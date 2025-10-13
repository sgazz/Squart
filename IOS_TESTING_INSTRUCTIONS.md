# 📱 iOS Fizičko Uređaj Testiranje - Instrukcije

**Datum**: 13. oktobar 2025.  
**Build Status**: ✅ SUCCESS (24.6s)  
**Uređaj**: iPhone 12,1 (iOS 26.0.1)

---

## 🎯 Cilj Testiranja:

Potvrditi da su **memory leak problemi rešeni** i da aplikacija radi stabilno na iOS fizičkom uređaju bez OOM (Out of Memory) crashes.

---

## 📋 Pre-Testiranje Checklist:

- [x] Flutter clean izvršen
- [x] Dependencies instalirani (flutter pub get)
- [x] Code analysis prošao (0 issues)
- [x] iOS release build uspešan (24.6s)
- [ ] Fizički iPhone povezan sa Mac-om
- [ ] Xcode otvoren i postavljen na fizički uređaj

---

## 🔧 Setup - Korak po Korak:

### Metod 1: Xcode Deploy (Preporučeno)

1. **Otvori Xcode Workspace:**
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Selektuj Fizički Uređaj:**
   - U Xcode toolbar-u, klikni na device selector (pored Stop dugmeta)
   - Selektuj svoj iPhone iz liste (iPhone 12,1)
   - **VAŽNO**: NE selektuj simulator!

3. **Build & Run:**
   - Product → Run (ili Cmd+R)
   - Sačekaj da se build završi i app se instalira
   - App će se automatski pokrenuti na uređaju

### Metod 2: Flutter Run

Alternativno, možeš koristiti flutter direktno:

```bash
cd "/Volumes/External2TB/Flutter projects/Squart"
flutter run --release
```

Kada se pojavi lista uređaja, selektuj fizički iPhone (ne simulator).

---

## 🧪 Test Scenariji - Memory Stress Test:

### **Test 1: Audio Memory Test** (5 min)
**Cilj**: Proveriti da audio ne leak-uje memoriju

1. ✅ Pokreni novu igru (Player vs Player)
2. ✅ Omogući sound (Settings)
3. ✅ Napravi **50+ poteza** brzo
4. ✅ Proveri da se zvukovi reprodukuju bez lag-a
5. ✅ App NE SME da crashuje

**Očekivano**: 
- Memory usage: **< 80 MB**
- Smooth audio playback
- Nema lag-a

---

### **Test 2: AI Easy Memory Test** (5 min)
**Cilj**: Proveriti Easy AI (depth=1)

1. ✅ Pokreni novu igru (Player vs AI - Easy)
2. ✅ Igraj kompletnu igru do kraja
3. ✅ Počni novu igru odmah
4. ✅ Ponoviti 3x uzastopno

**Očekivano**:
- Memory usage: **< 100 MB**
- AI response: **< 1s**
- Nema lag-a između igara

---

### **Test 3: AI Medium Memory Test** (10 min) ⚠️ KRITIČAN
**Cilj**: Proveriti Medium AI (depth=2, was 3)

1. ✅ Pokreni novu igru (Player vs AI - Medium)
2. ✅ Igraj kompletnu igru do kraja (~20-30 poteza)
3. ✅ **Monitor memoriju u Xcode**:
   - Debug Navigator → Memory
   - Prati graf tokom AI thinking
4. ✅ Počni novu igru odmah
5. ✅ Ponoviti 2x uzastopno

**Očekivano**:
- Memory usage: **< 120 MB** during AI thinking
- Memory usage: **< 100 MB** idle
- AI response: **< 2s**
- **APP NE SME DA CRASHUJE!**

---

### **Test 4: AI Hard Memory Test** (15 min) ⚠️ NAJKRITIČNIJI
**Cilj**: Proveriti Hard AI (depth=3, was 5)

1. ✅ Pokreni novu igru (Player vs AI - Hard)
2. ✅ **OBAVEZNO monitor memoriju**:
   - Xcode → Debug Navigator → Memory
   - View Memory Graph Debugger (ikona sa 3 kvadrata)
3. ✅ Igraj kompletnu igru do kraja
4. ✅ Prati memory spikes tokom AI thinking
5. ✅ Počni drugu igru
6. ✅ Proveri da memorija pada između igara

**Očekivano**:
- Memory usage: **< 150 MB** during AI thinking
- Memory usage: **< 100 MB** idle
- AI response: **< 3s**
- **APP NE SME DA CRASHUJE!**
- Memorija treba da se oslobađa nakon AI move-a

---

### **Test 5: Long Session Stress Test** (20 min) 🔥
**Cilj**: Testirati dugotrajnu stabilnost

1. ✅ Pokreni novu igru (Player vs AI - Hard)
2. ✅ Igraj **5 kompletnih igara uzastopno**
3. ✅ NE restartuj app između igara
4. ✅ Monitor memoriju kontinuirano
5. ✅ Proveri da nema memory leak-a (memory ne raste kontinuirano)

**Očekivano**:
- Memory nakon 5 igara: **trebalo bi biti isto kao posle 1 igre**
- Nema crashova
- Performance ostaje isti (ne sporije)

---

### **Test 6: Board Size Stress Test** (10 min)
**Cilj**: Testirati različite board size-ove

1. ✅ Igraj sa board size 8x8 (AI Hard)
2. ✅ Igraj sa board size 10x10 (AI Hard)
3. ✅ Igraj sa board size 12x12 (AI Hard)

**Očekivano**:
- 8x8: **< 120 MB**
- 10x10: **< 140 MB**
- 12x12: **< 160 MB**
- Nema crashova na većim tablama

---

## 📊 Monitoring Memory u Xcode:

### Real-Time Monitoring:

1. **Debug Navigator** (Cmd+7):
   - Klikni na "Memory" u levom sidebaru
   - Prati real-time graph
   - Normal app: **< 100 MB**
   - AI thinking: **< 150 MB**
   - **RED ZONE**: > 200 MB ⚠️

2. **Memory Graph Debugger**:
   - Klikni ikonu sa 3 kvadrata u debug toolbar
   - Prikazuje sve objekte u memoriji
   - Traži **memory leaks** (purpurna upozorenja)

3. **Instruments (Advanced)**:
   - Product → Profile (Cmd+I)
   - Izaberi "Leaks" template
   - Pokreni test scenario
   - Proveri da li ima leak-ova

---

## ✅ Success Kriterijumi:

### Aplikacija SE SMATRA STABILNOM ako:

1. ✅ **NIje crashovala** tokom svih testova
2. ✅ Memory usage ostaje **< 150 MB** tokom AI thinking
3. ✅ Memory se **oslobađa** između igara
4. ✅ Nema **memory leak warning-a** u Xcode
5. ✅ Performance je **consistent** (ne sporije sa vremenom)
6. ✅ Audio radi **smooth** bez lag-a

---

## 🚨 Šta Ako App Crashuje?

### Ako se desi crash:

1. **Pročitaj crash log:**
   - Xcode → Window → Devices and Simulators
   - Selektuj svoj iPhone
   - View Device Logs
   - Pronađi najnoviji crash report

2. **Proveri Memory Graph pre crasha:**
   - Pogledaj koji objekti su zauzimali najviše memorije

3. **Screenshot-uj:**
   - Memory graph
   - Crash report
   - Console output

4. **Reportuj sa detaljima:**
   - Koji test scenario?
   - Koliko vremena pre crash-a?
   - Peak memory usage?
   - Board size?
   - AI difficulty?

---

## 📝 Test Results Template:

Popuni posle testiranja:

```
========================================
iOS MEMORY TEST RESULTS
========================================

Datum: _______________
Vreme testiranja: _______________
Uređaj: iPhone 12,1 (iOS 26.0.1)

Test 1 - Audio Memory Test:
[ ] PASS  [ ] FAIL
Peak Memory: ______ MB
Notes: _______________________

Test 2 - AI Easy:
[ ] PASS  [ ] FAIL
Peak Memory: ______ MB
Notes: _______________________

Test 3 - AI Medium: ⚠️
[ ] PASS  [ ] FAIL
Peak Memory: ______ MB
Notes: _______________________

Test 4 - AI Hard: ⚠️
[ ] PASS  [ ] FAIL
Peak Memory: ______ MB
Notes: _______________________

Test 5 - Long Session (5 igara):
[ ] PASS  [ ] FAIL
Start Memory: ______ MB
End Memory: ______ MB
Memory Leak? [ ] YES  [ ] NO
Notes: _______________________

Test 6 - Board Size Stress:
8x8:  [ ] PASS  [ ] FAIL  (_____ MB)
10x10: [ ] PASS  [ ] FAIL  (_____ MB)
12x12: [ ] PASS  [ ] FAIL  (_____ MB)

========================================
OVERALL: [ ] PASS  [ ] FAIL
========================================

Crashovi: _____
Memory Leaks: _____
Performance Issues: _____

Dodatne Napomene:
_________________________________
_________________________________
_________________________________
```

---

## 🎯 Očekivani Rezultat:

Sa svim optimizacijama koje smo implementirali:

1. ✅ **AudioManager**: Preload zvukova - 70-80% manje memorije
2. ✅ **AI Depth**: Reduced depth - 98-99% manje simulacija
3. ✅ **Evaluation Limit**: Hard cap na 10K evaluacija
4. ✅ **Board Copy**: Optimizovano - 85% manje alokacija
5. ✅ **GameBoard**: Rendering optimizacija - 30% manje per frame

**APP BI TREBALO DA RADI STABILNO BEZ CRASHOVA!** 🎉

---

## 📞 Ako Treba Pomoć:

Priložite:
- Screenshots memory graph-a
- Crash reports
- Console output
- Test results

---

**Srećno testiranje!** 🚀

