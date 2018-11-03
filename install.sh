#!/usr/bin/env bash

while getopts r: option; do
    case "${option}" in
        r) REPO=${OPTARG};;
    esac
done
shift $((OPTIND-1))

PROJECT_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPTS_DIR="$PROJECT_DIR/install"
TOOLS_DIR="$PROJECT_DIR/tools"

source "$SCRIPTS_DIR/PROPERTIES" || exit $?

#
# Install JDK
#

JDK_DIR="$TOOLS_DIR/jdk"

#TODO Check for existing Java
"$SCRIPTS_DIR/install-jdk.sh" -v ${javaVersion:-8} ${REPO:+-p $REPO/openjdk} "$JDK_DIR" || exit $?
num_jdks=$(ls "$JDK_DIR" | wc -w)
if [ $num_jdks -lt 1 ]; then
    echo "Error with JDK installation: no JDK directory detected" >&2
    exit 1
elif [ $num_jdks -gt 1 ]; then
    echo "Error with JDK installation: more then 1 JDK directory detected: $(ls "$JDK_DIR")" >&2
    exit 1
fi

export JAVA_HOME=`echo $JDK_DIR/*`

#
# Modify properties files
#

case `uname -s` in
    CYGWIN*|MINGW*|MSYS*) JAVA_HOME_PROP=`cygpath -m "$JAVA_HOME"`;;
    *) JAVA_HOME_PROP="$JAVA_HOME";;
esac

echo "" >> "$PROJECT_DIR/gradle.properties" || exit $?
echo "org.gradle.java.home=$JAVA_HOME_PROP" >> "$PROJECT_DIR/gradle.properties" || exit $?

if [ -n "$REPO" ]; then
    sed -i -r -e 's|https?\\?\://services\.gradle\.org/distributions|'"$REPO/gradle-distributions|" \
        "$PROJECT_DIR/gradle/wrapper/gradle-wrapper.properties" || exit $?
    echo "mavenProxyUrl=$REPO/maven-public" >> "$PROJECT_DIR/gradle.properties"
fi
