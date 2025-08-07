#!/bin/bash

# Java Environment Setup for Flutter Project
# This script sets up the appropriate Java version for this project

# Set Java 17 for this project (recommended for Flutter/Android development)
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Also set for Gradle (override Android Studio's Java)
export GRADLE_OPTS="-Dorg.gradle.java.home=$JAVA_HOME"

# Override Flutter's Java detection by putting our Java first in PATH
# Remove Android Studio's JBR from PATH if it exists
export PATH=$(echo $PATH | sed 's|/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin:||g')
export PATH="$JAVA_HOME/bin:$PATH"

# Additional environment variables for Flutter/Android toolchain
export FLUTTER_JDK="$JAVA_HOME"
export ANDROID_JAVA_HOME="$JAVA_HOME"

echo "Java environment set for this project:"
echo "JAVA_HOME: $JAVA_HOME"
echo "GRADLE_OPTS: $GRADLE_OPTS"
echo "PATH (Java portion): $(echo $PATH | cut -d: -f1-3)"
java -version

# Also set ANDROID_HOME if not already set
if [ -z "$ANDROID_HOME" ]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
    echo "ANDROID_HOME set to: $ANDROID_HOME"
fi

echo ""
echo "Environment ready for Flutter development!"
echo "You can now run:"
echo "  fvm flutter doctor"
echo "  fvm flutter run"
echo "  ./start-emulator.sh"

# Check if FVM is available and show Flutter version
if command -v fvm &> /dev/null; then
    echo ""
    echo "FVM Flutter setup:"
    fvm flutter --version 2>/dev/null || echo "Run 'fvm use <version>' to set Flutter version for this project"
else
    echo ""
    echo "⚠️  FVM not found. Install with: dart pub global activate fvm"
fi
