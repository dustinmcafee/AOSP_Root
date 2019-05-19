#/bin/bash!
cp ~/AOSP/workingdir/Android_Source_Nougat/out/target/product/generic_x86_64/ramdisk.img ~/Android/Sdk/system-images/android-25/google_apis/x86_64 &&
cp ~/AOSP/workingdir/Android_Source_Nougat/out/target/product/generic_x86_64/cache.img ~/Android/Sdk/system-images/android-25/google_apis/x86_64 &&
cp ~/AOSP/workingdir/Android_Source_Nougat/out/target/product/generic_x86_64/userdata.img ~/Android/Sdk/system-images/android-25/google_apis/x86_64 &&
cp ~/AOSP/workingdir/Android_Source_Nougat/out/target/product/generic_x86_64/system.img ~/Android/Sdk/system-images/android-25/google_apis/x86_64 &&
#cp ~/AOSP/workingdir/Android_Source_Nougat/out/target/product/generic_x86_64/obj/PACKAGING/systemimage_intermediates/system.img ~/Android/Sdk/system-images/android-25/google_apis/x86_64 &&
~/Android/Sdk/tools/bin/avdmanager -v create avd --package 'system-images;android-25;google_apis;x86_64' --path /home/dustin/Android/Sdk_Custom/ --name Custom_AVD --abi google_apis/x86_64 -d 8 --force &&
echo hw.keyboard=yes >> ~/Android/Sdk_Custom/config.ini

