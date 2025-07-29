#!/bin/bash

ANDROID_COMPILE_SDK="29"
ANDROID_BUILD_TOOLS="29.0.0"
ANDROID_SDK_TOOLS="4333796"
export ARCH=`uname -m`
export ANDROID_NDK_HOME=$HOME/.android/android-ndk-r12b
export ANDROID_HOME=$HOME/.android
export ANDROID_CACHE_DIR=$HOME/.android-cache
export PATH=${ANDROID_NDK_HOME}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${PATH}

unzip_from_cache () {
    CACHE_FILE_NAME=$1
    CAHCE_FILE_PATH=$ANDROID_CACHE_DIR/$CACHE_FILE_NAME
    if [ ! -f  "$CAHCE_FILE_PATH" ]; then
        wget -q -O "$CAHCE_FILE_PATH" https://dl.google.com/android/repository/$CACHE_FILE_NAME
    fi
    cp "$CAHCE_FILE_PATH" ./$CACHE_FILE_NAME
    unzip -q $CACHE_FILE_NAME 
}

mkdir -p $ANDROID_CACHE_DIR
if [ ! -d "$ANDROID_HOME" ]; then
    mkdir -p $ANDROID_HOME
    pushd $HOME/.android
    unzip_from_cache sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip
    popd
fi

if [ ! -d "$ANDROID_NDK_HOME" ]; then
    mkdir -p $ANDROID_NDK_HOME
    pushd $HOME/.android
    unzip_from_cache android-ndk-r12b-linux-${ARCH}.zip
    popd
fi

echo y | sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null
echo y | sdkmanager "platform-tools" >/dev/null &
echo y | sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null &
wait
cp local.properties.github local.properties
git submodule update --init

# 64位版本不需要备份和恢复32位的libgojni.so
# 如果存在64位的libgojni.so，保留它们
if [ -f ./src/main/libs/arm64-v8a/libgojni.so ] || [ -f ./src/main/libs/x86_64/libgojni.so ]; then
    echo "Found existing 64-bit libgojni.so, preserving..."
    mkdir -p ./backup/arm64-v8a ./backup/x86_64
    if [ -f ./src/main/libs/arm64-v8a/libgojni.so ]; then
        cp ./src/main/libs/arm64-v8a/libgojni.so ./backup/arm64-v8a/
    fi
    if [ -f ./src/main/libs/x86_64/libgojni.so ]; then
        cp ./src/main/libs/x86_64/libgojni.so ./backup/x86_64/
    fi
fi

# 构建native库
chmod +x ./build-64bit.sh
./build-64bit.sh

# 如果之前备份了64位库，恢复它们
if [ -f ./backup/arm64-v8a/libgojni.so ]; then
    cp ./backup/arm64-v8a/libgojni.so ./src/main/libs/arm64-v8a/
fi
if [ -f ./backup/x86_64/libgojni.so ]; then
    cp ./backup/x86_64/libgojni.so ./src/main/libs/x86_64/
fi

# 打包APK
sbt android:package-release