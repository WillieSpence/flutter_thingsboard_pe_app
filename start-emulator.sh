#!/bin/bash

# Android Emulator Launcher Script
# Usage: ./start-emulator.sh [avd_name]

ANDROID_HOME=${ANDROID_HOME:-"$HOME/Library/Android/sdk"}
AVD_NAME=${1:-"Pixel_9"}

echo "Starting Android emulator: $AVD_NAME"
echo "Available AVDs:"
$ANDROID_HOME/emulator/emulator -list-avds

echo ""
echo "Starting $AVD_NAME..."
$ANDROID_HOME/emulator/emulator -avd "$AVD_NAME" &

echo "Emulator starting in background..."
echo "To check running emulators: adb devices"
