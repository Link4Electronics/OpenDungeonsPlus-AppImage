#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=https://raw.githubusercontent.com/tomluchowski/OpenDungeonsPlus/refs/heads/shaders-improvement/io.github.tomluchowski.OpenDungeonsPlus.desktop
export DEPLOY_PYTHON=1
export DEPLOY_OPENGL=1

# Deploy dependencies
quick-sharun ./AppDir/bin/opendungeons-plus    \
    /usr/lib/libopenal.so*                     \
    /usr/lib/cegui-0.9999/*.so                 \
    /usr/lib/OGRE/Codec_STBI.so                \
    /usr/lib/OGRE/Plugin_OctreeSceneManager.so \
    /usr/lib/OGRE/Plugin_ParticleFX.so         \
    /usr/lib/OGRE/RenderSystem_GL.so           \
    /usr/lib/OGRE/RenderSystem_GL3Plus.so
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env
echo 'OGRE_PLUGIN_DIR=${SHARUN_DIR}/lib/OGRE' >> ./AppDir/.env
echo 'CEGUI_MODULE_DIR=${SHARUN_DIR}/lib/cegui-0.9999' >> ./AppDir/.env

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
