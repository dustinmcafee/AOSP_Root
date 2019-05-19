#!/bin/bash
adb -e push /home/dustin/AOSP/workingdir/Android_Source_Nougat/update_termux.sh /data/data/com.termux/files/home/ &&
adb -e shell chmod 06755 /data/data/com.termux/files/home/update_termux.sh &&
adb -e push /home/dustin/AOSP/workingdir/test_event1.cpp /data/data/com.termux/files/home/

