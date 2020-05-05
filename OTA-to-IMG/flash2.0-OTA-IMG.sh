#!/bin/bash
set -e

# Elo 2.0 Unit Flash Script ( Used for builds 3.24.1 or greater )
AUTHOR="Elo"
VERSION="0.11"

SCRIPT_NAME=$0
ALL_PARAMS=$@
NO_OF_PARAMS=$#

# Flash binary path
# FLASH_IMG_PATH='/home/elo/Downloads/TMP'
FLASH_IMG_PATH='.'

# Script command line args
ARG_C=$#
ARG_V1=$1
ARG_V2=$2

function print_usage {
    echo "#"
    echo "# Usage"
    echo "# $SCRIPT_NAME [flash]/flashfactory"
    echo "#"
}

#usage: crcchk <crc_array> <partition> <crc_file_line - 1>
crcchk() {
	echo "Not Performing CRC check on $2 partition..."
	# Rebuild crc array from args
#	IFS=' ' read -r -a crc_array <<< "$1"

	# echo "crc_array received:"
	# echo "$1"

#    OUTPUT="$(sudo fastboot oem crc_check $2 2>&1)"
#    TRIMMED_OUTPUT=${OUTPUT#*CRC=0x}
#    TRIMMED_OUTPUT=${TRIMMED_OUTPUT//[$'\t\r\n']}	# remove linefeeds
#    TRIMMED_OUTPUT=${TRIMMED_OUTPUT::-43}			# remove trailing chars
#    TRIMMED_OUTPUT=${TRIMMED_OUTPUT:0:8}			# only look at CRC of 8 nibbles

    # echo "Got |$TRIMMED_OUTPUT| as CRC of the currently flashed $2 partition, confirming..."
    # echo "CRC of $2 partition is supposed to be ${crc_array[$3]}"

#	if [ "${crc_array[$3]}" == "$TRIMMED_OUTPUT" ]
#	then
#	echo "$2 partition: CRC PASS!"
#	else
#	echo "CRC CHECK FAILED... STOPPING."
#	exit
#	fi
}

######################## MAIN Function #################################
# Global flags
#
FACTORY_FLASH=0

echo "#"
echo "#  I-Series 2.0 Flashing Script Version $VERSION" 
echo "#"


#
#  Parse params
#
FACTORY_FLASH=0
if [ "1$NO_OF_PARAMS" == "10" ] ; then
    # No params supplied, apply defaut
    FACTORY_FLASH=0
else
    for token in $ALL_PARAMS
    do
        case $token in
        "flashfactory")
            FACTORY_FLASH=1
            ;;
        "flash")
            FACTORY_FLASH=0
            ;;
        *)
            ;;
        esac
    done
fi

#
#  Query Devices
#
echo "# Finding devices"
NO_DEVICES=`sudo fastboot devices | wc -l`
if [ $? != 0 ] ; then
    exit -1
fi

#  Make sure only 1 device present
if [ "1$NO_DEVICES" == "10" ] 
then
    echo "# Error: No device found! Please check connection"
    exit -1
fi

if [ "1$NO_DEVICES" != "11" ] 
then
    echo "# Error: More than 1 devices detected! Please disconnect unwanted devices"
    exit -1
fi

#  Get device id
DEVICE_ID=`sudo fastboot devices | head -n1 | cut -f1`
echo "# Found Device = $DEVICE_ID"
echo


#
#  Find product ID
#
echo "# Finding Project ID" 
ret=`sudo fastboot oem project_id 2>&1`
PROJECT_ID=`echo "$ret" | grep value | cut -f2 -d=`
echo "# Project ID = $PROJECT_ID" 
echo

#
#  Find Partition size
#
echo "# Finding Partition Size" 
ret=`sudo fastboot oem partition_size userdata 2>&1`
PARTITION_SIZE=`echo "$ret" | grep value | cut -f2 -d=`
echo "# Partition size = $PARTITION_SIZE"
echo

#
#  Decide which logo image to flash
#
if [ "1$PROJECT_ID" == "14" ] \
|| [ "1$PROJECT_ID" == "17" ] \
|| [ "1$PROJECT_ID" == "13" ] \
|| [ "1$PROJECT_ID" == "111" ] 
then
    LOGO_IMG=elo_logo_hd_raw_24bpp.bin
else
    LOGO_IMG=elo_logo_fhd_raw_24bpp.bin
fi

#
#  Decide which userdata.img to flash
#
if [ "1$PARTITION_SIZE" == "116G" ] ; then
    DATA_IMG=userdata_16.img
else if [ "1$PARTITION_SIZE" == "132G" ] ; then
    DATA_IMG=userdata_32.img
else
    echo "Error: Partition Size not supported: $PARTITION_SIZE"
    exit -1
fi
fi

# Just some warning
if [ $FACTORY_FLASH == 1 ] ; then
    echo "# Factory mode detected, will be erasing elo partition"
else
    echo "# Normal mode detected, will not be erasing elo partition"
fi

#
#  Start flashing
#
echo 
echo -ne "# Starting flashing in...  " ; sleep 1
echo -ne "3" ; sleep 1
echo -ne "2" ; sleep 1
echo -ne "1" ; sleep 1
echo 

set -e
set -x

echo "Reading CRC file..."
arr=(); i=0;  while read crc _; do arr[i]=$crc; i=$((i+1)); done < $FLASH_IMG_PATH/pc_crc_result.txt
echo "Done..."

sudo fastboot flash aboot $FLASH_IMG_PATH/emmc_appsboot.mbn || true
sudo fastboot reboot-bootloader
sleep 2

sudo fastboot flash partition $FLASH_IMG_PATH/gpt_both0.bin || true
sleep 2
sudo fastboot flash modem $FLASH_IMG_PATH/NON-HLOS.bin || true
crcchk "$(echo ${arr[@]})" "modem" 2

sudo fastboot flash sbl1 $FLASH_IMG_PATH/sbl1.mbn || true
crcchk "$(echo ${arr[@]})" "sbl1" 3

sudo fastboot flash sbl1bak $FLASH_IMG_PATH/sbl1.mbn || true
crcchk "$(echo ${arr[@]})" "sbl1" 3

sudo fastboot flash rpm $FLASH_IMG_PATH/rpm.mbn || true
crcchk "$(echo ${arr[@]})" "rpm" 4

sudo fastboot flash rpmbak $FLASH_IMG_PATH/rpm.mbn || true
crcchk "$(echo ${arr[@]})" "rpm" 4

sudo fastboot flash tz $FLASH_IMG_PATH/tz.mbn || true
crcchk "$(echo ${arr[@]})" "tz" 5

sudo fastboot flash tzbak $FLASH_IMG_PATH/tz.mbn || true
crcchk "$(echo ${arr[@]})" "tz" 5

sudo fastboot flash devcfg $FLASH_IMG_PATH/devcfg.mbn || true
crcchk "$(echo ${arr[@]})" "devcfg" 6

sudo fastboot flash devcfgbak $FLASH_IMG_PATH/devcfg.mbn || true
crcchk "$(echo ${arr[@]})" "devcfg" 6

sudo fastboot flash dsp $FLASH_IMG_PATH/adspso.bin || true
crcchk "$(echo ${arr[@]})" "dsp" 7

sudo fastboot flash lksecapp $FLASH_IMG_PATH/lksecapp.mbn || true
crcchk "$(echo ${arr[@]})" "lksecapp" 8

sudo fastboot flash lksecappbak $FLASH_IMG_PATH/lksecapp.mbn || true
crcchk "$(echo ${arr[@]})" "lksecapp" 8

sudo fastboot flash cmnlib $FLASH_IMG_PATH/cmnlib.mbn || true
crcchk "$(echo ${arr[@]})" "cmnlib" 9

sudo fastboot flash cmnlibbak $FLASH_IMG_PATH/cmnlib.mbn || true
crcchk "$(echo ${arr[@]})" "cmnlib" 9

sudo fastboot flash cmnlib64 $FLASH_IMG_PATH/cmnlib64.mbn || true
crcchk "$(echo ${arr[@]})" "cmnlib64" 10

sudo fastboot flash cmnlib64bak $FLASH_IMG_PATH/cmnlib64.mbn || true
crcchk "$(echo ${arr[@]})" "cmnlib64" 10

sudo fastboot flash keymaster $FLASH_IMG_PATH/keymaster.mbn || true
crcchk "$(echo ${arr[@]})" "keymaster" 11

sudo fastboot flash keymasterbak $FLASH_IMG_PATH/keymaster.mbn || true
crcchk "$(echo ${arr[@]})" "keymaster" 11

sudo fastboot flash aboot $FLASH_IMG_PATH/emmc_appsboot.mbn || true
crcchk "$(echo ${arr[@]})" "aboot" 12

sudo fastboot flash abootbak $FLASH_IMG_PATH/emmc_appsboot.mbn || true
crcchk "$(echo ${arr[@]})" "aboot" 12

sudo fastboot flash boot $FLASH_IMG_PATH/boot.img
crcchk "$(echo ${arr[@]})" "boot" 13

sudo fastboot flash recovery $FLASH_IMG_PATH/recovery.img
crcchk "$(echo ${arr[@]})" "recovery" 14

sudo fastboot -S 256M flash system $FLASH_IMG_PATH/system.img
crcchk "$(echo ${arr[@]})" "system" 0

sudo fastboot flash persist $FLASH_IMG_PATH/persist.img || true

sudo fastboot flash mdtp $FLASH_IMG_PATH/mdtp.img || true

echo ; sudo fastboot flash userdata $DATA_IMG || true

echo ; sudo fastboot flash factory $LOGO_IMG || true

sudo fastboot flash cache $FLASH_IMG_PATH/cache.img || true

sudo fastboot flash eloconf $FLASH_IMG_PATH/eloconf.img || true

if [ $FACTORY_FLASH == 1 ] ; then
    echo ; sudo fastboot erase elo
fi

#sudo fastboot oem uart Qon
#sudo fastboot oem uartconsole Qon

sudo fastboot erase modemst1
sudo fastboot erase modemst2
sudo fastboot erase misc
sudo fastboot erase DDR

sleep 2

set +x
set +e

#
#  Flashing done, wind up
#

echo "# OKAY"

echo "# Rebooting device..."
sudo fastboot reboot

echo "# "
echo "# Flashing Successful"
echo "# "
