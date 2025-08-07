#!/bin/bash

# Complete Development Environment Setup
# echo -e "\n${GREEN}Available Commands:${NC}"
echo "  fvm flutter doctor       - Check Flutter setup"
echo "  ./start-emulator.sh android - Start Android emulator"  
echo "  ./start-emulator.sh ios     - Start iOS simulator"
echo "  ./start-emulator.sh list    - List all available devices"
echo "  fvm flutter run          - Run the app"
echo "  gradle --version         - Check Gradle version"
echo "  fvm use <version>        - Set Flutter version for project"nsures consistent Java version across all tools

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up development environment...${NC}"

# Set Java 17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Override Android Studio's Java detection by putting our Java first in PATH
# Remove Android Studio's JBR from PATH if it exists
export PATH=$(echo $PATH | sed 's|/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin:||g')
export PATH="$JAVA_HOME/bin:$PATH"

# Override Android Studio's Java for Gradle
export GRADLE_OPTS="-Dorg.gradle.java.home=$JAVA_HOME"

# Additional environment variables for Flutter/Android toolchain
export FLUTTER_JDK="$JAVA_HOME"
export ANDROID_JAVA_HOME="$JAVA_HOME"

# Set Android SDK
if [ -z "$ANDROID_HOME" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
fi
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# Verify setup
echo -e "\n${GREEN}Environment Configuration:${NC}"
echo "JAVA_HOME: $JAVA_HOME"
echo "ANDROID_HOME: $ANDROID_HOME"
echo "GRADLE_OPTS: $GRADLE_OPTS"

echo -e "\n${GREEN}Java Version:${NC}"
java -version

echo -e "\n${GREEN}Android Tools:${NC}"
if command -v adb &> /dev/null; then
    echo "✓ ADB available: $(which adb)"
else
    echo -e "${RED}✗ ADB not found${NC}"
fi

if command -v emulator &> /dev/null; then
    echo "✓ Emulator available: $(which emulator)"
else
    echo -e "${RED}✗ Emulator not found${NC}"
fi

echo -e "\n${GREEN}Available Commands:${NC}"
echo "  fvm flutter doctor       - Check Flutter setup"
echo "  ./start-emulator.sh      - Start Android emulator"  
echo "  fvm flutter run          - Run the app"
echo "  gradle --version         - Check Gradle version"
echo "  fvm use <version>        - Set Flutter version for project"

# Check FVM and Flutter setup
echo -e "\n${GREEN}Flutter Setup (FVM):${NC}"
if command -v fvm &> /dev/null; then
    echo "✓ FVM available: $(which fvm)"
    if [ -f ".fvm/flutter_version" ]; then
        FVM_VERSION=$(cat .fvm/flutter_version)
        echo "✓ Project Flutter version: $FVM_VERSION"
    else
        echo -e "${YELLOW}⚠️  No FVM Flutter version set for this project${NC}"
        echo "   Run: fvm use <version> (e.g., fvm use stable)"
    fi
else
    echo -e "${RED}✗ FVM not found${NC}"
    echo "   Install with: dart pub global activate fvm"
fi

echo -e "\n${YELLOW}To make these settings permanent for your current shell:${NC}"
echo "export JAVA_HOME=\"$JAVA_HOME\""
echo "export GRADLE_OPTS=\"$GRADLE_OPTS\""
echo "export ANDROID_HOME=\"$ANDROID_HOME\""
echo "export PATH=\"\$JAVA_HOME/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$PATH\""
