#!/bin/bash

# Squart - Run Web version in Safari
# Double-click this file to run the web version

cd "$(dirname "$0")"

echo "🌐 Pokrećem Squart Web verziju..."
echo ""
echo "📍 URL: http://localhost:8080"
echo ""
echo "Safari će se automatski otvoriti za 5 sekundi..."
echo ""

# Start Flutter web server in background
flutter run -d web-server --web-port 8080 &
FLUTTER_PID=$!

# Wait for server to start
sleep 5

# Open Safari
open -a Safari http://localhost:8080

echo "✅ Web server pokrenut!"
echo "📱 Safari browser otvoren"
echo ""
echo "ℹ️  Za zaustavljanje servera:"
echo "   - Pritisni 'q' u ovom prozoru, ili"
echo "   - Zatvori ovaj terminal prozor"
echo ""

# Wait for Flutter process
wait $FLUTTER_PID

echo ""
echo "✅ Web server zaustavljen."

