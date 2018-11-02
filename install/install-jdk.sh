#!/usr/bin/env bash

function get-redirect-url() {
    curl -w "%{redirect_url}" -I -s -S "$1" -o /dev/null
}

javaVersion=8
releaseType=releases
impl=hotspot
release=latest
type=jdk

while getopts v:r:i:o:a:V:t:p: option; do
    case "$option" in
        v) javaVersion="$OPTARG";;
        r) releaseType="$OPTARG";;
        i) impl="$OPTARG";;
        o) os="$OPTARG";;
        a) arch="$OPTARG";;
        V) release="$OPTARG";;
        t) type="$OPTARG";;
        p) proxy="$OPTARG";;
    esac
done
shift $((OPTIND-1))

if [ -z "$os" ]; then
    case `uname -s` in
        Darwin) os=mac;;
        Linux)  os=linux;;
        CYGWIN*|MINGW*|MSYS*) os=windows;;
        *)
            echo "Unknown operating system type: $(uname -s)" >&2
            exit 1
            ;;
    esac
fi

if [ -z "$arch" ]; then
    case `uname -m` in
        i386|i686)    arch=x32;;
        x86_64|amd64) arch=x64;;
        *)
            echo "Unknown machine architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac
fi

dest="$1"

url="https://api.adoptopenjdk.net/v2/binary/$releaseType/openjdk$javaVersion?openjdk_impl=$impl&os=$os&arch=$arch&release=$release&type=$type"
url=`get-redirect-url "$url"`
if [ -n "$proxy" ] && [[ "$url" =~ ^https:\/\/github\.com\/AdoptOpenJDK\/(.+) ]]; then
    url="$proxy/${BASH_REMATCH[1]}"
fi

echo "Downloading $url to $dest" >&2
mkdir -p "$dest" || exit $?
case "$url" in
    *.zip)
        tempFile="$(mktemp)"
        curl -L "$url" >"$tempFile" || exit $?
        unzip -q -d "$dest" "$tempFile"
        ;;
    *.tgz|*.tar.gz)
        curl -L "$url" | tar -xpzC "$dest"
        ;;
    *)
        echo "Unknown archive type for ${url%.*}" >&2
        exit 1
        ;;
esac
