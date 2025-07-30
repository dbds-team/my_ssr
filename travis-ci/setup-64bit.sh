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

# 检查是否有32位的libgojni.so可以作为基础
if [ -f ./src/main/libs/armeabi-v7a/libgojni.so ]; then
    echo "Found 32-bit libgojni.so, copying as placeholder for 64-bit..."
    mkdir -p ./src/main/libs/arm64-v8a ./src/main/libs/x86_64
    # 暂时复制32位版本作为占位符，确保APK包含库目录
    cp ./src/main/libs/armeabi-v7a/libgojni.so ./src/main/libs/arm64-v8a/
    cp ./src/main/libs/x86/libgojni.so ./src/main/libs/x86_64/
fi

# 构建native库
sbt native-build

# 打包APK
sbt android:package-release