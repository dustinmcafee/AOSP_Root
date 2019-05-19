#/bin/bash!
/home/dustin/Android/Sdk/emulator/emulator \
  -show-kernel -debug-init \
  -kernel /home/dustin/AOSP/workingdir/Android_Source_Nougat/kernel/goldfish-3.10-n-dev/arch/x86/boot/bzImage \
  -avd Custom_AVD \
  -writable-system \
  -wipe-data \
  -gpu swiftshader_indirect \
  -qemu -s
#  -show-kernel -debug-all \
#  -avd Nexus_5_API_24_x86_64 \
#  -system /home/dustin/AOSP/workingdir/Android_Source_Nougat/out/debug/target/product/generic_x86_64/system.img \
