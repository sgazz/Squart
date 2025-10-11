#!/bin/bash

# Squart Launcher - Choose which version to run
# Double-click this file to choose between macOS and Web versions

cd "$(dirname "$0")"

clear
echo "╔════════════════════════════════════════╗"
echo "║      SQUART - Verzija Launcher        ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Izaberi verziju koju želiš da pokreneš:"
echo ""
echo "  1) 🖥️  macOS verzija"
echo "  2) 🌐 Web verzija (Safari)"
echo "  3) 🚀 OBE verzije (macOS + Web)"
echo "  4) ❌ Izlaz"
echo ""
read -p "Unesi broj (1, 2, 3 ili 4): " choice

case $choice in
  1)
    echo ""
    echo "🚀 Pokrećem macOS verziju..."
    echo ""
    flutter run -d macos
    ;;
  2)
    echo ""
    echo "🌐 Pokrećem Web verziju..."
    echo "📍 URL: http://localhost:8080"
    echo ""
    echo "Safari će se automatski otvoriti za 5 sekundi..."
    
    # Start Flutter web server in background
    flutter run -d web-server --web-port 8080 &
    FLUTTER_PID=$!
    
    # Wait for server to start
    sleep 5
    
    # Open Safari
    open -a Safari http://localhost:8080
    
    echo ""
    echo "✅ Web server pokrenut!"
    echo "📱 Safari browser otvoren"
    echo ""
    echo "ℹ️  Za zaustavljanje: pritisni 'q' u ovom prozoru"
    echo ""
    
    # Wait for Flutter process
    wait $FLUTTER_PID
    ;;
  3)
    echo ""
    echo "🚀 Pokrećem OBE verzije istovremeno..."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if port 8080 is already in use
    if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "⚠️  Port 8080 je zauzet. Zaustavaljam stari server..."
        kill -9 $(lsof -ti:8080) 2>/dev/null
        sleep 2
    fi
    
    echo "📱 Pokrećem macOS verziju..."
    
    # Start macOS version in new Terminal window
    SCRIPT_DIR="$(pwd)"
    osascript <<EOF
tell application "Terminal"
    do script "cd '$SCRIPT_DIR' && flutter run -d macos"
    activate
end tell
EOF
    
    echo "✅ macOS verzija pokrenuta u novom Terminal prozoru"
    echo ""
    sleep 3
    
    echo "🌐 Pokrećem Web verziju..."
    echo "📍 URL: http://localhost:8080"
    echo ""
    
    # Start web server in background
    flutter run -d web-server --web-port 8080 &
    WEB_PID=$!
    
    # Wait for web server to start
    echo "⏳ Čekam da web server startuje..."
    sleep 8
    
    # Open Safari
    open -a Safari http://localhost:8080
    
    echo "✅ Web server pokrenut!"
    echo "📱 Safari browser otvoren"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🎮 OBE VERZIJE SU POKRENUTE!"
    echo ""
    echo "📺 macOS app: u zasebnom Terminal prozoru"
    echo "🌐 Web app: http://localhost:8080"
    echo ""
    echo "ℹ️  Za zaustavljanje:"
    echo "   - Web server: pritisni 'q' u OVOM prozoru"
    echo "   - macOS app: pritisni 'q' u DRUGOM Terminal prozoru"
    echo "   - Ili zatvori oba Terminal prozora"
    echo ""
    
    # Wait for web server (user controls this one)
    wait $WEB_PID
    
    echo ""
    echo "✅ Web server zaustavljen."
    echo "ℹ️  macOS verzija možda još radi u drugom Terminal prozoru."
    ;;
  4)
    echo ""
    echo "👋 Izlazim..."
    exit 0
    ;;
  *)
    echo ""
    echo "❌ Nepoznata opcija!"
    echo ""
    read -p "Pritisni ENTER za izlaz..."
    exit 1
    ;;
esac

echo ""
echo "✅ Aplikacija zatvorena."
read -p "Pritisni ENTER za izlaz..."

