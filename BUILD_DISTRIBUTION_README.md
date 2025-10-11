# 🚀 Squart - Distribution Build Guide

Vodič za kreiranje distribucijskih verzija Squart aplikacije za deljenje sa korisnicima.

## 📁 Build Skripte

### 1. `build_release.command` ⭐ (Preporučeno za deljenje)
**Kreira DMG fajl - profesionalna distribucija**

- **Kako koristiti:** Dupli klik na fajl u Finder-u
- **Šta radi:**
  1. Čisti prethodne build fajlove (`flutter clean`)
  2. Instalira dependencies (`flutter pub get`)
  3. Build-uje release verziju (`flutter build macos --release`)
  4. Kreira DMG fajl na Desktop-u
- **Output:** `~/Desktop/Squart-macOS-v1.0.dmg`
- **Trajanje:** 2-3 minuta
- **Ideal za:** Profesionalno deljenje aplikacije

### 2. `build_zip.command`
**Kreira ZIP arhivu - brža alternativa**

- **Kako koristiti:** Dupli klik na fajl u Finder-u
- **Šta radi:**
  1. Build-uje release verziju
  2. Kreira ZIP arhivu na Desktop-u
- **Output:** `~/Desktop/Squart-macOS-v1.0.zip`
- **Trajanje:** 1-2 minuta
- **Ideal za:** Brzo testiranje i deljenje

---

## 📤 Proces Distribucije

### Korak 1: Kreiraj Distribucijski Fajl

```bash
# Option A: DMG (preporučeno)
./build_release.command

# Option B: ZIP (brže)
./build_zip.command
```

### Korak 2: Pronađi Output Fajl

Oba fajla će biti na Desktop-u:
- `Squart-macOS-v1.0.dmg` ili
- `Squart-macOS-v1.0.zip`

### Korak 3: Podeli Fajl

Izbor platforme za deljenje zavisi od veličine fajla:

| Platforma | Max Veličina | Link |
|-----------|--------------|------|
| Email | 25 MB | Gmail, Outlook, etc. |
| Google Drive | Unlimited | drive.google.com |
| Dropbox | Unlimited | dropbox.com |
| WeTransfer | 2 GB | wetransfer.com |
| GitHub Releases | 2 GB | github.com/releases |

### Korak 4: Pošalji Uputstva

Obavezno pošalji `INSTALLATION.md` sa distribucijskim fajlom!

```bash
# Kopiraj INSTALLATION.md na Desktop
cp INSTALLATION.md ~/Desktop/
```

Ili uključi INSTALLATION.md u email/poruku.

---

## 🔒 Signature & Notarization

### Bez Apple Developer naloga:

**Šta radiš sada:**
- ✅ Release build (brz i optimizovan)
- ✅ Ad-hoc distribucija
- ⚠️ Korisnici moraju: Right-click → Open prvi put

**Ograničenja:**
- ❌ Gatekeeper upozorenje
- ❌ Ne može na Mac App Store

### Sa Apple Developer nalogom ($99/year):

```bash
# 1. Potpiši aplikaciju
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name" \
  build/macos/Build/Products/Release/squart.app

# 2. Notarizuj kod Apple-a
xcrun notarytool submit Squart-macOS-v1.0.dmg \
  --apple-id your@email.com \
  --team-id YOUR_TEAM_ID \
  --password APP_SPECIFIC_PASSWORD

# 3. Staple notarization
xcrun stapler staple build/macos/Build/Products/Release/squart.app
```

**Prednosti:**
- ✅ Bez Gatekeeper upozorenja
- ✅ Distribucija preko Mac App Store (opciono)
- ✅ Automatsko ažuriranje moguće

---

## 📊 Build Konfiguracija

### Debug vs Release Build

| Feature | Debug | Release |
|---------|-------|---------|
| Veličina | ~100 MB | ~60 MB |
| Brzina | Sporija | Brža |
| Hot Reload | ✅ | ❌ |
| Debugging | ✅ | ❌ |
| Optimizacija | ❌ | ✅ |
| Za deljenje | ❌ | ✅ |

**Za deljenje UVEK koristi Release build!**

---

## 🛠️ Ručni Build (bez skripti)

Ako želiš ručno:

```bash
# 1. Clean
flutter clean

# 2. Get dependencies
flutter pub get

# 3. Build release
flutter build macos --release

# 4. Output lokacija:
# build/macos/Build/Products/Release/squart.app

# 5. Kreiraj DMG
hdiutil create -volname "Squart" \
  -srcfolder build/macos/Build/Products/Release/squart.app \
  -ov -format UDZO ~/Desktop/Squart.dmg

# 6. Ili ZIP
cd build/macos/Build/Products/Release/
zip -r ~/Desktop/Squart.zip squart.app
```

---

## 📋 Checklist Pre Distribucije

Pre nego što pošalješ aplikaciju, proveri:

- [ ] Release build kreiran (ne debug!)
- [ ] Aplikacija testirana na lokalnom Mac-u
- [ ] Tutorial ekran funkcioniše
- [ ] AI opponent radi pravilno
- [ ] Sound effects rade
- [ ] Dark/Light tema rade
- [ ] INSTALLATION.md fajl pripremljen
- [ ] Distribucijski fajl (DMG ili ZIP) na Desktop-u
- [ ] Veličina fajla prihvatljiva za izabrani metod deljenja

---

## 🎯 Beta Testing

Ako želiš da beta testuješ sa više ljudi:

### Opcija 1: TestFlight (potreban Apple Developer)
- Distribucija preko TestFlight-a
- Do 10,000 beta testera
- Automatsko ažuriranje

### Opcija 2: Ad-hoc distribucija (bez naloga)
- Deli DMG/ZIP fajlove
- Korisnici instaliraju ručno
- Email sa uputstvima (INSTALLATION.md)

---

## 🌐 Web Verzija kao Alternativa

Ako ne želiš da se baviš macOS distribucijom:

```bash
# Build web verziju
flutter build web --release

# Deploy na:
- GitHub Pages (besplatno)
- Netlify (besplatno)
- Vercel (besplatno)
- Firebase Hosting (besplatno)
```

Web verzija nema security upozorenja i radi u svim browserima!

---

## 📞 Questions?

Ako imaš pitanja o distribuciji, kontaktiraj:
- GitHub: https://github.com/sgazz/Squart
- Issues: https://github.com/sgazz/Squart/issues

---

**Napravio:** build_release.command & build_zip.command skripte  
**Dokumentacija:** INSTALLATION.md & BUILD_DISTRIBUTION_README.md

