#!/bin/bash
adb root &&
sleep 1 &&
adb remount &&
sleep 1 &&
adb -e install /home/dustin/AOSP/workingdir/apk/supersu/supersu-2-82.apk &&
adb -e push /home/dustin/AOSP/workingdir/apk/supersu/x86/su.pie /system/bin/su &&
adb root &&
sleep 1 &&
adb remount &&
sleep 1 &&
adb -e shell "chmod 06755 /system/bin/su && /system/bin/su --install && /system/bin/su --daemon& setenforce 0" &&
adb -e install /home/dustin/AOSP/workingdir/apk/Termux_v0.60_apkpure.com.apk &&
echo "Now Open SuperSu and update su binary (Normally without rebooting)" &&
adb shell am start eu.chainfire.supersu/eu.chainfire.supersu.MainActivity
