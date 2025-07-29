#!/bin/bash

function try () {
"$@" || exit -1
}

try pushd src/main

# Build for 64-bit architectures
try ${ANDROID_NDK_HOME}/ndk-build -j8

# No need to move executables for 64-bit version
# The NDK build will create libs in the correct directories based on Application.mk

try popd