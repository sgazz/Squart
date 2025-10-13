# 🎮 Squart

Squart je strategijska logička igra za dva igrača inspirisana igrom Domineering, ali sa izmenjenim pravilima.

## 📖 O igri

U igri Squart, dva igrača naizmenično postavljaju žetone na tablu. **Plavi igrač** postavlja horizontalne žetone (dva polja širine), a **crveni igrač** postavlja vertikalne žetone (dva polja visine). Cilj igre je prisiliti protivnika da ostane bez validnih poteza. Pobednik je igrač koji je odigrao poslednji validni potez.

## ✨ Funkcionalnosti

### 🎯 Gameplay
- ✅ **Tabla različitih veličina** (od 5×5 do 20×20, podrazumevano 7×7)
- ✅ **Crna polja** koja se ne mogu koristiti (17-19% od ukupnih polja)
- ✅ **Player vs Player** - igraj sa prijateljem
- ✅ **Player vs AI** - igraj protiv računara sa 4 nivoa težine:
  - Easy - Slučajni potezi
  - Medium - Osnovne strategije
  - Hard - Napredniji AI
  - Expert - Minimax algoritam sa alpha-beta pruning
- ✅ **Šahovski tajmer** (1-10 minuta po igraču ili neograničeno)

### 🎨 UI/UX
- ✅ **Dark & Light teme** sa lepim gradijent pozadinama
- ✅ **Glassmorphism dizajn** - moderni UI
- ✅ **Interaktivni tutorial** - 4 slajda sa vizuelnim primerima
- ✅ **Platform-specific navigacija** - dugmad za desktop/web, swipe za mobilne
- ✅ **Hints sistem** - prikazuje validne poteze (opciono)
- ✅ **Animacije** za postavljanje žetona
- ✅ **Zvučni efekti** - token place, win, lose, tick, invalid
- ✅ **Haptički feedback** (vibracija na mobilnim uređajima)

### 💾 Persistence
- ✅ **Auto-save** tekuće partije
- ✅ **Tutorial state** - prikazuje se samo pri prvom pokretanju
- ✅ **Settings** - čuvaju se preko SharedPreferences

## 🎮 Kako igrati

### 🎯 Osnovna Pravila

- **Plavi igrač** postavlja žeton **horizontalno** (polje na koje klikne i polje desno od njega)
- **Crveni igrač** postavlja žeton **vertikalno** (polje na koje klikne i polje ispod njega)
- **Crna polja** se ne mogu koristiti - nasumično raspodeljena na tabli (17-19%)
- Igra se završava kada igrač na potezu nema validni potez ili kada mu istekne vreme
- **Pobednik** je igrač koji je odigrao poslednji validni potez

### 👤 Ko Igra Prvi?

#### **Player vs Player Mode:**

Pre pokretanja nove igre, možeš izabrati ko će igrati prvi:
- **Plavi igra prvi** (podrazumevano) - plavi odigrava prvi potez
- **Crveni igra prvi** - crveni odigrava prvi potez

**Napomena**: U PvP modu, **plavi UVEK igra horizontalne žetone** i **crveni UVEK igra vertikalne žetone**, bez obzira ko igra prvi. Ovo znači:
- Ako plavi igra prvi → plavi postavlja horizontalni žeton
- Ako crveni igra prvi → crveni postavlja vertikalni žeton

#### **Player vs AI Mode:**

U AI modu imaš **potpunu kontrolu** nad postavkama:

1. **Ko si ti (boja)**:
   - Možeš izabrati da budeš **plavi** ili **crveni**
   - Ako si plavi → igraš horizontalne žetone
   - Ako si crveni → igraš vertikalne žetone

2. **Ko igra prvi**:
   - **Ti (human)** - ti počinješ partiju
   - **AI** - računar odigrava prvi potez

3. **Kombinacije** (4 moguće):
   - Ti si plavi + igraš prvi → plavi (ti) otvara igru horizontalnim žetonom
   - Ti si plavi + AI igra prvi → crveni (AI) otvara igru vertikalnim žetonom
   - Ti si crveni + igraš prvi → crveni (ti) otvara igru vertikalnim žetonom
   - Ti si crveni + AI igra prvi → plavi (AI) otvara igru horizontalnim žetonom

**Važno**: Boja određuje **orijentaciju žetona**, a izbor "ko igra prvi" određuje **redosled poteza**.

### 🎲 Zašto je Važno Ko Igra Prvi?

Igrati prvi može biti **prednost** ili **mana** zavisno od:
- Veličine table (manje table → veća prednost prvog igrača)
- Rasporeda crnih polja (više crnih polja u centru → može pomoći ili smetati)
- Strategije koju igrač koristi

U nekim partijama prvi potez daje inicijativu, u drugim omogućava protivniku da bolje reaguje.

## 🚀 Pokretanje Aplikacije (Development)

### Launcher Skripte (macOS)

Najlakši način za pokretanje aplikacije:

```bash
# Glavni launcher sa menijom
./run_squart.command

# Opcije:
# 1 - macOS verzija
# 2 - Web verzija (Safari)
# 3 - OBE verzije istovremeno
# 4 - Izlaz
```

Ili direktno:

```bash
# Samo macOS
./run_macos.command

# Samo Web
./run_web.command
```

Više detalja: [LAUNCHER_README.md](LAUNCHER_README.md)

### Ručno pokretanje

```bash
# macOS
flutter run -d macos

# Web (Safari)
flutter run -d web-server --web-port 8080
# Zatim otvori: http://localhost:8080

# iOS
flutter run -d iPhone

# Android
flutter run -d emulator-5554
```

## 📦 Kreiranje Distribucijske Verzije

Za deljenje aplikacije sa drugima (bez Apple Developer naloga):

### Kreiraj DMG fajl (preporučeno)

```bash
./build_release.command
```

Output: `~/Desktop/Squart-macOS-v1.0.dmg`

### Ili kreiraj ZIP arhivu (brže)

```bash
./build_zip.command
```

Output: `~/Desktop/Squart-macOS-v1.0.zip`

**📤 Podeli fajl preko:** Email, Google Drive, Dropbox, WeTransfer, GitHub Releases

**📝 Obavezno pošalji:** `INSTALLATION.md` sa uputstvima za instalaciju

Više detalja: [BUILD_DISTRIBUTION_README.md](BUILD_DISTRIBUTION_README.md)

## 🛠️ Tehnologije

- **Flutter** - UI framework
- **Provider** - State management
- **SharedPreferences** - Lokalno čuvanje podataka
- **just_audio** - Audio playback
- **vibration** - Haptički feedback
- **Dart** - Programski jezik

## 📱 Podržane Platforme

- ✅ **macOS** (Apple Silicon & Intel)
- ✅ **Web** (Safari, Chrome, Firefox, Edge)
- ✅ **iOS** (iPhone & iPad)
- ✅ **Android**
- ✅ **Windows**
- ✅ **Linux**

## 🏗️ Struktura Projekta

```
lib/
├── core/
│   ├── constants/      # App boje, veličine, konstante
│   ├── theme/          # Dark/Light theme konfiguracija
│   └── utils/          # Helper funkcije
├── models/             # Data modeli (Cell, Token, GameState, etc.)
├── providers/          # State management (GameProvider, ThemeProvider)
├── screens/            # Glavni ekrani (Home, Game, Settings, Tutorial)
├── services/           # Business logika (AI, GameLogic, Tutorial)
└── widgets/            # Reusable UI komponente
```

## 📚 Dokumentacija

- 🚀 [LAUNCHER_README.md](LAUNCHER_README.md) - Kako pokrenuti različite verzije
- 📦 [BUILD_DISTRIBUTION_README.md](BUILD_DISTRIBUTION_README.md) - Kako kreirati distribucijske verzije
- 📥 [INSTALLATION.md](INSTALLATION.md) - Uputstva za korisnike (deli sa aplikacijom)
- 📊 Development summaries:
  - [PHASE_0_SUMMARY.md](PHASE_0_SUMMARY.md) - Inicijalni setup
  - [PHASE_1_SUMMARY.md](PHASE_1_SUMMARY.md) - Board & Token sistem
  - [PHASE_2_SUMMARY.md](PHASE_2_SUMMARY.md) - Game logic & Timer
  - [PHASE_4_AI_SUMMARY.md](PHASE_4_AI_SUMMARY.md) - AI opponent
  - [SOUND_FIX_SUMMARY.md](SOUND_FIX_SUMMARY.md) - Audio sistem
  - [IOS_WARNINGS_COMPLETE_FIX.md](IOS_WARNINGS_COMPLETE_FIX.md) - iOS optimizacije

## 🧪 Testing

```bash
# Run tests
flutter test

# Run specific test
flutter test test/game_logic_test.dart
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Stanko Gazza**
- GitHub: [@sgazz](https://github.com/sgazz)
- Project: [Squart](https://github.com/sgazz/Squart)

## 🙏 Acknowledgments

Inspirisano igrom **Domineering** sa modifikovanim pravilima za bolju strategijsku dubinu.

---

**Version:** 1.0.0  
**Last Updated:** October 2025  
**Status:** ✅ Production Ready