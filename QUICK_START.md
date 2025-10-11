# ⚡ Squart - Quick Start Guide

Brzi vodič za pokretanje i distribuciju Squart aplikacije.

## 🎮 Za Developere

### Pokretanje za testiranje:

```bash
# 1. Dupli klik na:
run_squart.command

# 2. Izaberi opciju:
# → 1 za macOS
# → 2 za Web
# → 3 za OBE istovremeno
```

### Hot reload (za development):

```bash
# macOS verzija
flutter run -d macos
# Pritisni 'r' za hot reload

# Web verzija
flutter run -d web-server --web-port 8080
# Otvori: http://localhost:8080
# Pritisni 'r' za hot reload
```

---

## 📦 Za Distribuciju

### Kreiraj fajl za deljenje:

```bash
# Dupli klik na:
build_release.command  # → Kreira DMG na Desktop-u
# ili
build_zip.command      # → Kreira ZIP na Desktop-u
```

### Podeli sa korisnicima:

1. **Upload fajl** (DMG ili ZIP) na:
   - Google Drive
   - Dropbox
   - WeTransfer
   - GitHub Releases

2. **Pošalji INSTALLATION.md** sa linkom za download

3. **Objasni korisnicima:**
   - Download fajl
   - Right-click → Open (prvi put)
   - Enjoy!

---

## 🎯 Tutorial Testiranje

1. Pokreni aplikaciju
2. Klikni **❓ ikonu** (How to Play)
3. Testiranje:
   - Swipe left/right (ili Back/Next dugmad)
   - Proveri da li su sva 4 slajda vidljiva
   - Proveri 5×5 table sa crnim poljima
   - Proveri gradijent pozadinu

---

## 🐛 Debug

```bash
# Proveri greške
flutter analyze

# Proveri dependencies
flutter doctor

# Clean & rebuild
flutter clean && flutter pub get && flutter run -d macos
```

---

## 📁 Važni Fajlovi

| Fajl | Svrha |
|------|-------|
| `run_squart.command` | Launcher za dev testiranje |
| `build_release.command` | Kreira DMG za distribuciju |
| `build_zip.command` | Kreira ZIP za distribuciju |
| `INSTALLATION.md` | Uputstva za korisnike |
| `BUILD_DISTRIBUTION_README.md` | Detaljna dokumentacija za build |
| `LAUNCHER_README.md` | Detaljna dokumentacija za launcher |

---

## 🚀 All-in-One Command

```bash
# Build, kreiraj DMG, i otvori Desktop folder
./build_release.command
# → Izaberi 'y' na kraju da otvori Desktop
# → Podeli Squart-macOS-v1.0.dmg fajl
```

---

**Brz start u 3 koraka:**

1. `./run_squart.command` → Testiranje
2. `./build_release.command` → Kreiranje distribucije
3. Upload + podeli `INSTALLATION.md` → Distribucija

✅ Gotovo!

