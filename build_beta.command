#!/bin/bash

# Squart - Build Beta DMG for Beta Testers
# Double-click to create a beta distributable macOS DMG file

cd "$(dirname "$0")"

clear
echo "╔════════════════════════════════════════╗"
echo "║   SQUART - Beta Build Creator          ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🚀 Kreiram BETA verziju za testiranje..."
echo ""

# Step 1: Clean previous builds
echo "🧹 Čistim prethodne build fajlove..."
flutter clean
echo "✅ Completed"
echo ""

# Step 2: Get dependencies
echo "📦 Instaliram dependencies..."
flutter pub get
echo "✅ Completed"
echo ""

# Step 3: Build release version
echo "🔨 Build-ujem macOS BETA verziju..."
echo "   (Ovo može potrajati 1-2 minuta...)"
echo ""
flutter build macos --release

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Build nije uspeo!"
    echo ""
    read -p "Pritisni ENTER za izlaz..."
    exit 1
fi

echo "✅ Beta build završen!"
echo ""

# Step 4: Create DMG
echo "💿 Kreiram BETA DMG fajl..."
echo ""

DMG_NAME="Squart-macOS-Beta-v1.0.0-beta.1.dmg"
OUTPUT_PATH="$HOME/Desktop/$DMG_NAME"

# Remove old DMG if exists
if [ -f "$OUTPUT_PATH" ]; then
    echo "⚠️  Stari BETA DMG postoji, brišem ga..."
    rm "$OUTPUT_PATH"
fi

# Create new DMG
hdiutil create -volname "Squart Beta" \
  -srcfolder "build/macos/Build/Products/Release/Squart Beta.app" \
  -ov -format UDZO \
  "$OUTPUT_PATH"

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Kreiranje BETA DMG nije uspelo!"
    echo ""
    read -p "Pritisni ENTER za izlaz..."
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 BETA VERZIJA USPEŠNO KREIRANA!"
echo ""
echo "📍 Lokacija: $OUTPUT_PATH"
echo ""

# Get file size
FILE_SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
echo "📊 Veličina: $FILE_SIZE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📤 SLEDEĆI KORACI ZA BETA TESTERE:"
echo ""
echo "1. Pronađi fajl na Desktop-u: $DMG_NAME"
echo "2. Podeli ga sa BETA TESTERIMA preko:"
echo "   • Email (ako je < 25MB)"
echo "   • Google Drive / Dropbox"
echo "   • WeTransfer"
echo "   • GitHub Releases"
echo ""
echo "3. Pošalji im BETA_INSTALLATION.md sa uputstvima"
echo ""
echo "ℹ️  VAŽNO za BETA TESTERE:"
echo "   Pri prvom pokretanju moraju:"
echo "   • Right-click na 'Squart Beta.app'"
echo "   • Izabrati 'Open'"
echo "   • Kliknuti 'Open' u security dijalogu"
echo ""
echo "⚠️  BETA NAPOMENA:"
echo "   Ovo je BETA verzija za testiranje!"
echo "   Prijavite sve bugove i predloge."
echo ""

# Open Desktop folder
read -p "Želiš li da otvoriš Desktop folder? (y/n): " open_desktop

if [ "$open_desktop" = "y" ] || [ "$open_desktop" = "Y" ]; then
    open ~/Desktop
    echo "✅ Desktop folder otvoren"
fi

echo ""
echo "✅ Beta verzija gotova!"
read -p "Pritisni ENTER za izlaz..."
