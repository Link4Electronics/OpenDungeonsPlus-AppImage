#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    boost      \
    boost-libs \
    cmake      \
    ogre       \
    pugixml    \
    pybind11   \
    python     \
    sfml

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package cegui

# If the application needs to be manually built that has to be done down here
git clone https://github.com/tomluchowski/OpenDungeonsPlus

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DOD_TREAT_WARNINGS_AS_ERRORS=OFF \
    -DPYBIND11_FINDPYTHON=ON
