#!/bin/bash
#gdb \
#/home/dustin/AOSP/workingdir/Android_Source_Nougat/prebuilts/gdb/linux-x86/bin/gdb \
gdb \
    -ex "file /home/dustin/AOSP/workingdir/Android_Source_Nougat/kernel/goldfish-3.10-n-dev/vmlinux" \
    -ex 'target remote localhost:1234'
#    -ex 'hbreak start_kernel' \
#    -ex 'hbreak ESM.c:387' \
#    -ex hbreak esm_interpret \
#    -ex hbreak esm_wait
#    -ex hbreak esm_register \
#-ex set debug-file-directory /home/dustin/AOSP/build_out/Android_Source/target/product/generic_x86/symbols/ \

