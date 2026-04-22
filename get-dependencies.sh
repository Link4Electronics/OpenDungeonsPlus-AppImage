#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    boost      \
    boost-libs \
    ccache     \
    cmake      \
    devil      \
    doxygen    \
    freeglut   \
    glfw       \
    irrlicht   \
    libraqm    \
    lua51      \
    minizip    \
    ogre       \
    ois        \
    pcre       \
    pugixml    \
    pybind11   \
    python     \
    sdl2_image \
    sfml       \
    tinyxml    \
    tinyxml2   \
    tolua++

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package gtk2
make-aur-package fluxcomp
make-aur-package freeimage
PRE_BUILD_CMDS='export CFLAGS="$CFLAGS -Wno-error=implicit-function-declaration -fcommon"' make-aur-package directfb
make-aur-package rapidxml
make-aur-package silly
PRE_BUILD_CMDS='export CXXFLAGS="$CXXFLAGS -std=c++11"' make-aur-package cegui

# If the application needs to be manually built that has to be done down here
echo "Making nightly build of OpenDungeonsPlus..."
echo "---------------------------------------------------------------"
REPO="https://github.com/tomluchowski/OpenDungeonsPlus"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone "$REPO" ./OpenDungeonsPlus
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./OpenDungeonsPlus
mkdir build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DOD_TREAT_WARNINGS_AS_ERRORS=OFF \
    -DPYBIND11_FINDPYTHON=ON
make -j$(nproc)
ls
mv -v opendungeons-plus ../../AppDir/bin
mv -v ../levels ../materials ../models ../music ../particles ../shaders ../sounds ../../AppDir/bin
