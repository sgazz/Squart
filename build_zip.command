#!/bin/bash

# Squart - Build Release ZIP for Distribution
# Double-click to create a distributable macOS ZIP file (simpler alternative to DMG)

cd "$(dirname "$0")"

clear
echo "╔════════════════════════════════════════╗"
echo "║  SQUART - ZIP Release Build Creator   ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "🚀 Kreiram release verziju (ZIP format)..."
echo ""

# Build release version
echo "🔨 Build-ujem macOS release verziju..."
flutter build macos --release

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Build nije uspeo!"
    read -p "Pritisni ENTER za izlaz..."
    exit 1
fi

echo "✅ Build završen!"
echo ""

# Create ZIP
echo "📦 Kreiram ZIP arhivu..."
ZIP_NAME="Squart-macOS-v1.0.zip"
OUTPUT_PATH="$HOME/Desktop/$ZIP_NAME"

# Remove old ZIP if exists
if [ -f "$OUTPUT_PATH" ]; then
    rm "$OUTPUT_PATH"
fi

# Create ZIP from the app
cd build/macos/Build/Products/Release/
zip -r "$OUTPUT_PATH" squart.app
cd - > /dev/null

FILE_SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🎉 USPEŠNO KREIRANO!"
echo ""
echo "📍 Lokacija: $OUTPUT_PATH"
echo "📊 Veličina: $FILE_SIZE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✅ Gotovo! ZIP fajl je spreman za deljenje."
read -p "Pritisni ENTER za izlaz..."

