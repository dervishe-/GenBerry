#!/bin/bash
# vim: foldmarker={{{,}}}
#
# kernelbuilder.sh
# Author: Alexndre Keledjian <dervishe@yahoo.fr>
# Version: 1.0
# License: GPLv3
#
#
# This script build the kernel image for the raspberryPi
#	Parameters list:
#		modules install path
#		rPi type:	1 for (A, A+, B, B+ and zero) or 2 for 2A and 2B
#		server address


#{{{ Parameters
KERNEL_SOURCES=git://github.com/raspberrypi/linux.git
FBTFT_SOURCES=git://github.com/notro/fbtft.git
ROOT_PATH="$1"
TARGET=/usr/bin/armv6j-hardfloat-linux-gnueabi-
WDIR=./repository_alt
LOCATION="$3"
RASP_TYPE="$2"
# Check for a correct raspberry type
if ! [[ $RASP_TYPE  -eq 1 ]] && ! [[ $RASP_TYPE -eq 2 ]]; then
	echo "Bad RaspBerry type (1|2): $RASP_TYPE"
	exit 1
fi
#}}}
. ./helpers.sh

echo -e "\t$HSTAR Checking requirements: " #{{{
echo -en "\t\t$HSTAR Are you root ? "
checkRoot
echo -en "\t\t$HSTAR Are you connected ? "
checkConnectivity
echo -en "\t\t$HSTAR Is your crossdev env installed ? "
checkCrossdev $TARGET
echo -en "\t\t$HSTAR Kernel building tools installed ? "
checkKBT
#}}}

echo -en "\t$HSTAR Building working dir: " #{{{
([[ -d $WDIR ]] || mkdir "$WDIR") && cd "$WDIR" >> $LOG 2>&1
printResult $?
#}}}

echo -en "\t$HSTAR Retrieving the kernel source: " #{{{
git clone --depth 1 $KERNEL_SOURCES >> $LOG 2>&1
printResult $?
#}}}

echo -en "\t$HSTAR Retrieving the notro fbtft source: " #{{{
cd ./linux/drivers/video/fbdev >> $LOG 2>&1
git clone $FBTFT_SOURCES >> $LOG 2>&1
echo "source \"drivers/video/fbdev/fbtft/Kconfig\"" >> ./Kconfig
echo "obj-y += fbtft/" >> ./Makefile
cd - >> $LOG 2>&1
printResult $?
#}}}

echo -e "\t$HSTAR Compiling the kernel (You can take a coffee now): " #{{{
cd ./linux >> $LOG 2>&1

echo -en "\t\t$HSTAR Configure BCM chip: "
if [[ $RASP_TYPE -eq 1 ]]; then
	make ARCH=arm bcmrpi_defconfig >> $LOG 2>&1
elif [[ $RASP_TYPE -eq 2 ]]; then
	make ARCH=arm bcm2709_defconfig >> $LOG 2>&1
fi
printResult $?

echo -en "\t\t$HSTAR Configuring the kernel: "
make ARCH=arm CROSS_COMPILE=$TARGET oldconfig >> $LOG 2>&1
printResult $?

echo -en "\t\t$HSTAR Compiling the kernel: "
NB_CORE=$(cat /proc/cpuinfo | grep processor | wc -l);
make ARCH=arm CROSS_COMPILE=$TARGET -j$(( $NB_CORE + 1 )) -l$NB_CORE >> $LOG 2>&1
printResult $?
#}}}

echo -en "\t$HSTAR Installing the modules: " #{{{
make ARCH=arm CROSS_COMPILE=$TARGET modules_install INSTALL_MOD_PATH=$ROOT_PATH >> $LOG 2>&1
BUFFER=$?
printResult $BUFFER
[[ $BUFFER -eq 1 ]] && exit 1
# Adjusting the symbolic link
KERN_VERSION=$(cat .config | grep Linux | cut -d ' ' -f 3)
cd ${ROOT_PATH}/lib/modules/${KERN_VERSION}*
rm ./build ./source
ln -s /usr/src/linux ./build
ln -s /usr/src/linux ./source
cd -
#}}}

echo -en "\t$HSTAR Installing the kernel: " #{{{
if [[ $RASP_TYPE -eq 1 ]]; then
	imagetool-uncompressed.py arch/arm/boot/Image ${ROOT_PATH}/boot/kernel.img >> $LOG 2>&1
elif [[ $RASP_TYPE -eq 2 ]]; then
	cp arch/arm/boot/zImage ${ROOT_PATH}/boot/kernel7.img >> $LOG 2>&1
fi
cp arch/arm/boot/dts/*.dtb ${ROOT_PATH}/boot/ >> $LOG 2>&1
cp arch/arm/boot/dts/overlays/*.dtb* ${ROOT_PATH}/boot/overlays/ >> $LOG 2>&1
cp arch/arm/boot/dts/overlays/README ${ROOT_PATH}/boot/overlays/ >> $LOG 2>&1
printResult $?
#}}}

echo -en "\t$HSTAR Installing the kernel config file: " #{{{
cp .config ${ROOT_PATH}/usr/src/linux/ >> $LOG 2>&1
printResult $?
#}}}

echo -e "\t$HSTAR Cleaning all the stuffs: " #{{{
echo -en "\t\t$HSTAR Deleting stuffs: "
cd ../../
rm -Rf $WDIR >> $LOG 2>&1
BUFFER=$?
printResult $BUFFER
if [[ $BUFFER -ne 0 ]]; then
	echo -e "\t\t\tUnable to clean and delete the temporary directory"
	exit 1
fi
cd .. >> $LOG 2>&1
#}}}
