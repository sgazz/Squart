# 🚀 Squart Launcher Skripte

Ove skripte omogućavaju brzo pokretanje različitih verzija Squart aplikacije za testiranje.

## 📁 Dostupne skripte

### 1. `run_squart.command` ⭐ (Preporučeno)
**Glavni launcher sa menijom**

- **Kako koristiti:** Dupli klik na fajl u Finder-u
- **Šta radi:** Prikazuje meni gde možeš izabrati koju verziju želiš da pokreneš
  - Option 1: macOS verzija
  - Option 2: Web verzija (Safari)
  - Option 3: **OBE verzije istovremeno** 🚀
  - Option 4: Izlaz

### 2. `run_macos.command`
**Direktno pokreni macOS verziju**

- **Kako koristiti:** Dupli klik na fajl u Finder-u
- **Šta radi:** Odmah pokreće macOS desktop verziju aplikacije
- **Ideal za:** Brzo testiranje desktop verzije

### 3. `run_web.command`
**Direktno pokreni Web verziju**

- **Kako koristiti:** Dupli klik na fajl u Finder-u
- **Šta radi:** 
  - Pokreće Flutter web server na `http://localhost:8080`
  - Automatski otvara Safari browser
- **Za zaustavljanje:** Pritisni `q` u terminal prozoru
- **Ideal za:** Testiranje web verzije aplikacije

## 🔧 Prvo pokretanje

Ako dobiješ grešku "Permission denied" pri prvom pokretanju:

1. Otvori Terminal
2. Navigiraj do Squart foldera:
   ```bash
   cd "/Volumes/External2TB/Flutter projects/Squart"
   ```
3. Daj izvršne dozvole:
   ```bash
   chmod +x run_squart.command run_macos.command run_web.command
   ```

## ⚠️ macOS Security

Pri prvom pokretanju, macOS može pokazati security upozorenje:

1. Klikni desni klik (right-click) na `.command` fajl
2. Izaberi "Open"
3. Klikni "Open" ponovo u security dijalogu
4. Nakon toga, možeš koristiti dupli klik

## 🚀 Pokretanje OBE verzije istovremeno (Option 3)

**Nova funkcionalnost!** Možeš pokrenuti macOS i Web verziju istovremeno za lakše poređenje:

1. Izaberi **Option 3** iz glavnog menija
2. **macOS verzija** će se otvoriti u novom Terminal prozoru
3. **Web verzija** će se otvoriti u Safari browseru
4. Za testiranje Tutorial ekrana u obe verzije uporedo:
   - Otvori Tutorial (❓ ikona) u macOS verziji
   - Otvori Tutorial (❓ ikona) u Web verziji
   - Uporedi navigaciju, UI, i responzivnost

### Zaustavljanje:
- **Web server:** Pritisni `q` u originalnom Terminal prozoru
- **macOS app:** Pritisni `q` u novom Terminal prozoru
- **Brzo:** Zatvori oba Terminal prozora

## 🎯 Testiranje Tutorial ekrana

Nakon pokretanja aplikacije:

1. Klikni na **❓ ikonu** (How to Play) u gornjem desnom uglu
2. **macOS/Web verzija:** Koristi dugmad **Back** i **Next** za navigaciju
3. **Mobile verzija:** Swipe left/right za navigaciju između slajdova

## 📋 Karakteristike Tutorial ekrana

- ✅ Gradijent pozadina prema temi (Dark/Light)
- ✅ 5×5 tabla sa crnim poljima (realistični primeri)
- ✅ Platform-specific navigacija:
  - **Desktop/Web:** Dugmad za navigaciju
  - **Mobile:** Swipe gestures
- ✅ 4 interaktivna slajda sa vizuelnim primerima

## 🛠️ Troubleshooting

### Web verzija ne radi
- Proveri da li je port 8080 slobodan
- Zatvori sve prethodne instance Flutter web servera
- Restartuj launcher skriptu

### macOS verzija ne radi
- Proveri da Flutter i Xcode tools su instalirani
- Pokreni `flutter doctor` da vidiš potencijalne probleme

### Terminal ostaje otvoren
- Ovo je normalno! Terminal mora ostati otvoren dok aplikacija radi
- Za zatvaranje: pritisni `q` ili zatvori terminal prozor

---

**Napomena:** Sve skripte automatski pozicioniraju se u Squart projekat folder, tako da možeš pokrenuti ih iz bilo kog lokacije.

