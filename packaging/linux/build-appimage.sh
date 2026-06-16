#!/usr/bin/env bash
# Packs a built CMake tree into dist/Testux-<version>-x86_64.AppImage.
#
#   packaging/linux/build-appimage.sh [build-dir] [version]
#
# build-dir defaults to ./build, version to project(VERSION) in CMakeLists.txt.
# Safe to rerun: the AppDir is rebuilt from scratch, downloaded tools are reused.
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
build_dir=$(realpath "${1:-$root/build}")
version=${2:-$(sed -nE 's/^project\(Testux VERSION ([0-9.]+).*/\1/p' "$root/CMakeLists.txt")}
tools="$build_dir/appimage-tools"
appdir="$build_dir/AppDir"
output="$root/dist/Testux-$version-x86_64.AppImage"

fetch_tool() {
    local name=$1 url=$2
    [[ -x "$tools/$name" ]] && return
    curl -fsSL --retry 3 -o "$tools/$name.part" "$url"
    chmod +x "$tools/$name.part"
    mv "$tools/$name.part" "$tools/$name"
}

mkdir -p "$tools" "$root/dist"
fetch_tool linuxdeploy-x86_64.AppImage \
    https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
fetch_tool linuxdeploy-plugin-qt-x86_64.AppImage \
    https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage

# linuxdeploy names the icon after its file, the desktop entry asks for "testux".
cp "$root/assets/testux-256.png" "$tools/testux.png"
