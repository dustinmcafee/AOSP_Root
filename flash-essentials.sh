#!/bin/bash

ANDROID_PRODUCT_OUT="/home/dustin/AOSP/build_out/hikey960/target/product/hikey960"

if [ ! -d "${ANDROID_PRODUCT_OUT}" ]; then
    echo "error in locating out directory, check if it exist"
    exit
fi

echo "android out dir:${ANDROID_PRODUCT_OUT}"

fastboot flash boot "${ANDROID_PRODUCT_OUT}"/boot.img
fastboot flash dts "${ANDROID_PRODUCT_OUT}"/dt.img
fastboot flash system "${ANDROID_PRODUCT_OUT}"/system.img
fastboot flash cache "${ANDROID_PRODUCT_OUT}"/cache.img
fastboot flash userdata "${ANDROID_PRODUCT_OUT}"/userdata.img
fastboot reboot
