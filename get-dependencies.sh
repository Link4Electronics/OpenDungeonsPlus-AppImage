#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    boost      \
    cmake      \
    doxygen    \
    ninja      \
    ogre       \
    ois        \
    pybind11   \
    swig

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package sfml2
#make-aur-package boost183
PRE_BUILD_CMDS='sed -i "s/cmake /cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCEGUI_BUILD_RENDERER_DIRECT3D11=FALSE -DCEGUI_BUILD_RENDERER_OPENGL=FALSE -DCEGUI_BUILD_RENDERER_OPENGLES=FALSE -DCEGUI_BUILD_RENDERER_OPENGL3=FALSE -DCEGUI_BUILD_IMAGECODEC_STB=TRUE -DCEGUI_BUILD_PYTHON_MODULES_SWIG=FALSE -DCEGUI_BUILD_STATIC_CONFIGURATION=OFF -DCMAKE_CXX_FLAGS=-std=c++11 /" ./PKGBUILD' make-aur-package cegui-git
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
mv -v opendungeons-plus plugins.cfg resources.cfg ../../AppDir/bin
mv -v ../config ../gui ../levels ../materials ../models ../music ../particles ../python ../scripts ../shaders ../sounds ../../AppDir/bin
cp -r /usr/share/OGRE-*/Media/RTShaderLib ../../AppDir/bin
sed -i -e 's|^FileSystem=.*/share/OGRE/Media/|FileSystem=|' -e '/^FileSystem=RTShaderLib\//d' ../../AppDir/bin/resources.cfg
