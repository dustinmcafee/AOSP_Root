#!/bin/bash
adb push ./update_termux.sh /data/data/com.termux/files/home/ &&
adb shell chmod 06755 /data/data/com.termux/files/home/update_termux.sh

