#/bin/bash!
export ARCH=x86_64 		&& \
export SUBARCH=x86_64 		&& \
export CROSS_COMPILE=${ANDROID_BUILD_TOP}/prebuilts/gcc/linux-x86/x86/x86_64-linux-android-4.9/bin/x86_64-linux-android- && \
export HOST_BUILD_TYPE=debug	&& \
export TARGET_BUILD_TYPE=debug	&& \
export DEX_PREOPT_DEFAULT=nostripping && \
. ./build/envsetup.sh 		&& \
lunch aosp_x86_64-userdebug	&& \
set_stuff_for_environment

