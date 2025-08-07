#!/bin/bash

# Java Version Switcher
# Usage: ./switch-java.sh [11|17|21]

VERSION=${1:-17}

case $VERSION in
    11)
        export JAVA_HOME=$(/usr/libexec/java_home -v 11)
        ;;
    17)
        export JAVA_HOME=$(/usr/libexec/java_home -v 17)
        ;;
    21)
        export JAVA_HOME=$(/usr/libexec/java_home -v 21)
        ;;
    *)
        echo "Usage: $0 [11|17|21]"
        echo "Available Java versions:"
        /usr/libexec/java_home -V
        exit 1
        ;;
esac

export PATH="$JAVA_HOME/bin:$PATH"

echo "Switched to Java $VERSION"
echo "JAVA_HOME: $JAVA_HOME"
java -version

# Update current shell
echo ""
echo "To make this change permanent in your current shell, run:"
echo "export JAVA_HOME=\"$JAVA_HOME\""
echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\""
