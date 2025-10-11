#!/bin/bash

# Squart - Run macOS version
# Double-click this file to run the macOS version

cd "$(dirname "$0")"

echo "🚀 Pokrećem Squart macOS verziju..."
echo ""

flutter run -d macos

echo ""
echo "✅ Aplikacija zatvorena."
read -p "Pritisni ENTER za izlaz..."

