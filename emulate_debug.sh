#/bin/bash!
/home/dustin/Android/Sdk/emulator/emulator \
  -show-kernel -debug-init \
  -kernel /home/dustin/AOSP/workingdir/Android_Source_Nougat/kernel/goldfish-3.10-n-dev/arch/x86/boot/bzImage \
  -avd Custom_AVD \
  -writable-system \
  -wipe-data \
  -qemu -s -S
