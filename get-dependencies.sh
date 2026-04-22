#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
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
    tinyxml    \
    tinyxml2   \
    tolua++

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package sfml2
make-aur-package gtk2
make-aur-package fluxcomp
make-aur-package freeimage
PRE_BUILD_CMDS='sed -i "s/build() {/build() {\n  export CFLAGS+=\" -fcommon -Wno-error=incompatible-pointer-types -Wno-implicit-function-declaration\"/" ./PKGBUILD' make-aur-package directfb
make-aur-package rapidxml
make-aur-package silly
make-aur-package boost183
PRE_BUILD_CMDS='sed -i "s/cmake /cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCEGUI_BUILD_RENDERER_DIRECT3D9=FALSE -DCEGUI_BUILD_RENDERER_DIRECT3D10=FALSE -DCEGUI_BUILD_RENDERER_DIRECT3D11=FALSE -DCEGUI_BUILD_RENDERER_OPENGL=FALSE -DCEGUI_BUILD_RENDERER_OPENGLES=FALSE -DCEGUI_BUILD_RENDERER_OPENGLES3=FALSE -DCEGUI_BUILD_RENDERER_OPENGL3=FALSE -DCEGUI_BUILD_IMAGECODEC_FREEIMAGE=FALSE -DCEGUI_OPTION_DEFAULT_IMAGECODEC=OgreRenderer-0 -DCEGUI_SAMPLES_ENABLED=FALSE -DCEGUI_BUILD_PYTHON_MODULES=OFF -DCEGUI_BUILD_STATIC_CONFIGURATION=OFF -DCMAKE_CXX_FLAGS=-std=c++11 /" ./PKGBUILD' make-aur-package cegui-git
#PRE_BUILD_CMDS='sed -i "s/cmake /cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 /" ./PKGBUILD; export CXXFLAGS="$CXXFLAGS -std=c++11"' make-aur-package cegui

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
