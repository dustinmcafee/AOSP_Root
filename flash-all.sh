#!/bin/bash

INSTALLER_DIR="/home/dustin/AOSP/workingdir/hikey960/device/linaro/hikey/installer/hikey960"
ANDROID_PRODUCT_OUT="/home/dustin/AOSP/build_out/hikey960/target/product/hikey960"

if [ ! -d "${ANDROID_PRODUCT_OUT}" ]; then
    echo "error in locating out directory, check if it exist"
    exit
fi

echo "android out dir:${ANDROID_PRODUCT_OUT}"

fastboot flash xloader "${INSTALLER_DIR}"/hisi-sec_xloader.img
fastboot flash ptable "${INSTALLER_DIR}"/hisi-ptable.img
fastboot flash fastboot "${INSTALLER_DIR}"/hisi-fastboot.img
fastboot reboot-bootloader
fastboot flash nvme "${INSTALLER_DIR}"/nvme.img
fastboot flash fw_lpm3   "${INSTALLER_DIR}"/lpm3.img
fastboot flash trustfirmware   "${INSTALLER_DIR}"/bl31.bin
fastboot flash boot "${ANDROID_PRODUCT_OUT}"/boot.img
fastboot flash dts "${ANDROID_PRODUCT_OUT}"/dt.img
fastboot flash system "${ANDROID_PRODUCT_OUT}"/system.img
fastboot flash cache "${ANDROID_PRODUCT_OUT}"/cache.img
fastboot flash userdata "${ANDROID_PRODUCT_OUT}"/userdata.img
fastboot reboot
