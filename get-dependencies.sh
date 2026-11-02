#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    boost      \
    cmake      \
    doxygen    \
    glew       \
    glm        \
    ogre       \
    ois        \
    openal     \
    pybind11   \
    swig

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano gtk2-mini sdl2_image-mini

echo "Building sfml2..."
echo "---------------------------------------------------------------"
REPO="https://github.com/SFML/SFML"
git clone --depth 1 -b 2.6.2 "$REPO" ./sfml

cmake -B build-sfml -S ./sfml \
      -DCMAKE_INSTALL_PREFIX=/opt/sfml2 \
      -DCMAKE_BUILD_TYPE=Release \
      -DSFML_USE_SYSTEM_DEPS=ON \
      -DSFML_BUILD_EXAMPLES=0 \
      -DSFML_BUILD_DOC=0 \
      -DSFML_INSTALL_PKGCONFIG_FILES=1 \
      -DSFML_PKGCONFIG_INSTALL_PREFIX=/usr/lib/pkgconfig/sfml2
cmake --build build-sfml -j$(nproc)
cmake --install build-sfml

echo "Building cegui..."
echo "---------------------------------------------------------------"
REPO="https://github.com/cegui/cegui"
git clone --depth 1 "$REPO" ./cegui
git -C ./cegui apply ../cegui-ogre14.patch

cmake -S ./cegui -B build \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCEGUI_BUILD_RENDERER_DIRECT3D11=FALSE \
    -DCEGUI_BUILD_RENDERER_OPENGL=FALSE \
    -DCEGUI_BUILD_RENDERER_OPENGLES=FALSE \
    -DCEGUI_BUILD_RENDERER_OPENGL3=FALSE \
    -DCEGUI_BUILD_IMAGECODEC_STB=TRUE \
    -DCEGUI_BUILD_PYTHON_MODULES_SWIG=FALSE \
    -DCEGUI_BUILD_PYTHON_MODULES_PYPLUSPLUS=FALSE \
    -DCEGUI_BUILD_STATIC_CONFIGURATION=OFF \
    -DCMAKE_CXX_STANDARD=17
cmake --build build -j$(nproc)
cmake --install build

echo "Building OpenDungeonsPlus..."
echo "---------------------------------------------------------------"
REPO="https://github.com/tomluchowski/OpenDungeonsPlus"
VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
git clone --depth 1 "$REPO" ./OpenDungeonsPlus
echo "$VERSION" > ~/version

mkdir -p ./AppDir/bin
cd ./OpenDungeonsPlus
mkdir build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DOD_TREAT_WARNINGS_AS_ERRORS=OFF \
    -DPYBIND11_FINDPYTHON=ON \
    -DSFML_ROOT=/opt/sfml2
make -j$(nproc)
mv -v opendungeons-plus plugins.cfg resources.cfg ../../AppDir/bin
mv -v ../config ../gui ../levels ../materials ../models ../music ../particles ../python ../scripts ../shaders ../sounds ../../AppDir/bin
cp -r /usr/share/OGRE-*/Media/RTShaderLib ../../AppDir/bin
sed -i -e 's|^FileSystem=.*/share/OGRE/Media/|FileSystem=|' -e '/^FileSystem=RTShaderLib\//d' ../../AppDir/bin/resources.cfg
