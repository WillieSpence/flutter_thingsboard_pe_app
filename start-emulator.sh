#!/bin/bash

# Emulator/Simulator Launcher Script
# Usage: ./start-emulator.sh [platform] [device_name]
# Examples:
#   ./start-emulator.sh android Pixel_9
#   ./start-emulator.sh ios "iPhone 15 Pro"
#   ./start-emulator.sh (defaults to android Pixel_9)

ANDROID_HOME=${ANDROID_HOME:-"$HOME/Library/Android/sdk"}
PLATFORM=${1:-"android"}
DEVICE_NAME=${2}

# Function to start Android emulator
start_android() {
    local avd_name=${1:-"Pixel_9"}
    
    echo "🤖 Starting Android emulator: $avd_name"
    echo "Available Android AVDs:"
    $ANDROID_HOME/emulator/emulator -list-avds
    
    echo ""
    echo "Starting $avd_name..."
    $ANDROID_HOME/emulator/emulator -avd "$avd_name" &
    
    echo "Android emulator starting in background..."
    echo "To check running emulators: adb devices"
}

# Function to start iOS simulator
start_ios() {
    local device_name=${1:-"iPhone 15 Pro"}
    
    echo "🍎 Starting iOS simulator: $device_name"
    echo "Available iOS simulators:"
    xcrun simctl list devices available | grep -E "iPhone|iPad"
    
    echo ""
    echo "Starting $device_name..."
    
    # Get the device UDID for the specified device name
    local device_udid=$(xcrun simctl list devices available | grep "$device_name" | head -1 | grep -o '[0-9A-F-]\{36\}')
    
    if [ -z "$device_udid" ]; then
        echo "❌ Device '$device_name' not found. Available devices:"
        xcrun simctl list devices available | grep -E "iPhone|iPad" | sed 's/^/  /'
        return 1
    fi
    
    # Boot the simulator
    xcrun simctl boot "$device_udid" 2>/dev/null || echo "Simulator already booted or booting..."
    
    # Open Simulator app
    open -a Simulator
    
    echo "iOS simulator starting..."
    echo "To check running simulators: xcrun simctl list devices booted"
}

# Function to show help
show_help() {
    echo "Emulator/Simulator Launcher"
    echo ""
    echo "Usage: $0 [platform] [device_name]"
    echo ""
    echo "Platforms:"
    echo "  android    Start Android emulator (default)"
    echo "  ios        Start iOS simulator"
    echo "  list       List available devices for both platforms"
    echo ""
    echo "Examples:"
    echo "  $0                              # Start default Android emulator (Pixel_9)"
    echo "  $0 android Pixel_9              # Start specific Android emulator"
    echo "  $0 ios \"iPhone 15 Pro\"          # Start specific iOS simulator"
    echo "  $0 ios                          # Start default iOS simulator (iPhone 15 Pro)"
    echo "  $0 list                         # List all available devices"
}

# Function to list all available devices
list_devices() {
    echo "📱 Available Android AVDs:"
    if command -v $ANDROID_HOME/emulator/emulator &> /dev/null; then
        $ANDROID_HOME/emulator/emulator -list-avds | sed 's/^/  /'
    else
        echo "  Android SDK not found or emulator not available"
    fi
    
    echo ""
    echo "📱 Available iOS Simulators:"
    if command -v xcrun &> /dev/null; then
        xcrun simctl list devices available | grep -E "iPhone|iPad" | sed 's/^/  /'
    else
        echo "  Xcode command line tools not installed"
    fi
}

# Main logic
case $PLATFORM in
    "android")
        start_android "$DEVICE_NAME"
        ;;
    "ios")
        start_ios "$DEVICE_NAME"
        ;;
    "list")
        list_devices
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ Unknown platform: $PLATFORM"
        echo ""
        show_help
        exit 1
        ;;
esac
