#!/bin/bash 
#
#  Name              = flash_3.0.sh
#  Purpose           = 3.0 device flashing script
#  Devices supported = I-series 2.0 (10inch, 15inch, 22inch),
#                      Paypoint (Refresh and 2.0),
#                      Puck
#
#  Orig Script Link  = https://bitbucket.org/elosystemsteam/elo-android-8.1-oreo-_oem_scripts/src/67f36ceb389ea5b5770e276860b9568bfd6c0438/download_tools/fastboot_dl_all.bat
#

AUTHOR="Elo"
VERSION="0.13"

SCRIPT_NAME=$0
ALL_PARAMS=$@
NO_OF_PARAMS=$#

function print_usage {
    echo "#"
    echo "# Usage"
    echo "# $SCRIPT_NAME [flash]/flashfactory"
    echo "#"
}

######################## MAIN Function #################################

# Global flags
#
FACTORY_FLASH=0

echo "#"
echo "#  I-Series 3.0 Flashing Script Version $VERSION" 
echo "#"


#
#  Parse params
#
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
            echo "unknown param $token"
            print_usage
            exit -1
            ;;
        esac
    done
fi


#
#  Query Devices
#
echo "# Finding devices"
NO_DEVICES=`sudo fastboot devices | wc -l | awk '{$1=$1};1'`

if [ $? != 0 ] ; then
    exit -1
fi

#  Make sure only 1 device present
if [ "1$NO_DEVICES" == "01" ] 
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
|| [ "1$PROJECT_ID" == "13" ]
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

echo ; sudo fastboot flash partition       gpt_both0.bin || true
echo ; sudo fastboot flash modem           NON-HLOS.bin || true
echo ; sudo fastboot flash sbl1            sbl1.mbn || true
echo ; sudo fastboot flash sbl1bak         sbl1.mbn || true
echo ; sudo fastboot flash rpm             rpm.mbn || true
echo ; sudo fastboot flash rpmbak          rpm.mbn || true
echo ; sudo fastboot flash tz              tz.mbn || true
echo ; sudo fastboot flash tzbak           tz.mbn || true
echo ; sudo fastboot flash devcfg          devcfg.mbn || true
echo ; sudo fastboot flash devcfgbak       devcfg.mbn || true
echo ; sudo fastboot flash dsp             adspso.bin || true
echo ; sudo fastboot flash lksecapp        lksecapp.mbn || true
echo ; sudo fastboot flash lksecappbak     lksecapp.mbn || true
echo ; sudo fastboot flash cmnlib          cmnlib_30.mbn || true
echo ; sudo fastboot flash cmnlibbak       cmnlib_30.mbn || true
echo ; sudo fastboot flash cmnlib64        cmnlib64_30.mbn || true
echo ; sudo fastboot flash cmnlib64bak     cmnlib64_30.mbn || true
echo ; sudo fastboot flash keymaster       keymaster64.mbn || true
echo ; sudo fastboot flash keymasterbak    keymaster64.mbn || true
echo ; sudo fastboot flash aboot           emmc_appsboot.mbn || true
echo ; sudo fastboot flash abootbak        emmc_appsboot.mbn || true
echo ; sudo fastboot flash boot            boot.img
echo ; sudo fastboot flash recovery        recovery.img
echo ; sudo fastboot flash vendor          vendor.img
echo ; sudo fastboot flash system          system.img
echo ; sudo fastboot flash persist         persist.img || true
echo ; sudo fastboot flash mdtp            mdtp.img || true

echo ; sudo fastboot flash userdata        $DATA_IMG || true

echo ; sudo fastboot flash factory         $LOGO_IMG || true

echo ; sudo fastboot flash cache           cache.img || true
echo ; sudo fastboot flash eloconf         eloconf.img || true

echo ; sudo fastboot erase                 modemst1 || true
echo ; sudo fastboot erase                 modemst2 || true
echo ; sudo fastboot erase                 misc || true
echo ; sudo fastboot erase                 DDR || true

if [ $FACTORY_FLASH == 1 ] ; then
    echo ; sudo fastboot erase             elo
fi

echo ; sudo fastboot oem all_var Qoff
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

exit 0
