#!/bin/bash
# vim: foldmarker={{{,}}}
#
# portage2squa.sh
# Author: Alexndre Keledjian <dervishe@yahoo.fr>
# Version: 1.0
# License: GPLv3
# 
#
# This script download the portage tree and make a squashfs file with it
#

#{{{ Parameters
ARCH_LOCATION=http://distfiles.gentoo.org/snapshots
FILE=portage-latest.tar.xz
SIG=${FILE}.gpgsig
HASH=${FILE}.md5sum
WDIR=./repository
TEST_DIR=./mnt
SQUASH_FILE=portage.squashfs
LOCAL_PORTAGE_DIR=portage
HSTAR="\e[1;32m*\e[0m\e[37m"
#}}}
#{{{ Helpers
function print_result()
{
	[[ $1 -ne 0 ]] && echo -e "\e[1;31m[FAIL]\e[0m" || echo -e "\e[1;32m[OK]\e[0m\e[37m"
}

function getFile()
{
	wget $1 > /dev/null 2>&1
	local BUFFER=$?
	print_result $BUFFER
	if [[ $BUFFER -ne 0 ]]; then 
		echo -e "\tThe file can't be retrieve. Check the name, the address or the connectivity."
		exit 1
	fi
}

function clean()
{
	cd .. > /dev/null 2>&1
	mv $WDIR/$SQUASH_FILE . > /dev/null 2>&1
	local BUFFER=$?
	if [[ $BUFFER -ne 0 ]]; then
		print_result $BUFFER
		echo -e "\tUnable to move the squashfs file: '$SQUASH_FILE' from the temporary directory"
		exit 1
	fi
	rm -Rf $WDIR > /dev/null 2>&1
	BUFFER=$?
	print_result $BUFFER
	if [[ $BUFFER -ne 0 ]]; then
		echo -e "\tUnable to clean and delete the temporary directory"
		exit 1
	fi
}
#}}}
clear
echo -en "\n\n$HSTAR Prepare environment (1/12): " #{{{
[[ ! -d $WDIR ]] && mkdir "$WDIR"
cd "$WDIR"
GPG=$(whereis gpg | awk '{ print $2}')
if [[ $GPG = '' ]]; then
	print_result 1
	echo -e "\tgpg is needed but not installed."
	exit 1
fi
print_result 0
#}}}

echo -en "$HSTAR Test the connectivity (2/12): " #{{{
ping -c 1 -w 2 www.gentoo.org > /dev/null 2>&1
BUFFER=$?
print_result $BUFFER
if [[ $BUFFER -ne 0 ]]; then
	echo -e "\tYour connection seems to be down."
	return 1
fi
#}}}

echo -en "$HSTAR Retrieve the fingerprint (3/12): " #{{{
[[ -f $HASH ]] && rm $HASH
getFile $ARCH_LOCATION/$HASH
#}}}

echo -en "$HSTAR Check the local file with the fingerprint (4/12): " #{{{
md5sum --quiet -c $HASH > /dev/null 2>&1
BUFFER=$?
print_result 0
OVERWRITE=1
if [[ $BUFFER -eq 0 ]]; then 
	echo -ne "\tThe archive is the same, would you continue anyway ? (y/N) "
	read REP
	[[ $REP =~ ^[yY](es)?$ ]] && OVERWRITE=0 || exit 0
fi
#}}}

echo -en "$HSTAR Retrieve portage archive (5/12): " #{{{
[[ $OVERWRITE = 0 ]] && print_result $OVERWRITE || getFile $ARCH_LOCATION/$FILE
#}}}

echo -en "$HSTAR Verify the new file's fingerprint (6/12): " #{{{
md5sum --quiet -c $HASH > /dev/null 2>&1
BUFFER=$?
print_result $BUFFER
if [[ $BUFFER -eq 1 ]]; then 
	rm $HASH
	echo -e "\tBad fingerprint check result, archive corrupted !!!"
	exit 1;
fi
rm $HASH
#}}}

echo -en "$HSTAR Retrieve the file's signature (7/12): " #{{{
getFile $ARCH_LOCATION/$SIG
#}}}

echo -en "$HSTAR Check file's signature (8/12): " #{{{
$GPG --verify $SIG $FILE > /dev/null 2>&1
BUFFER=$?
print_result $BUFFER
if [[ $BUFFER -ne 0 ]]; then
	rm $SIG
	echo -e "\tSignature's problem: the file don't seems to be legit..."
	echo -e "\tPerhap's you don't have imported the Gentoo public key:"
	echo -e "\thttps://www.gentoo.org/downloads/signatures/"
	exit 1;
fi
rm $SIG
#}}}

echo -en "$HSTAR Expand the portage tree (9/12): " #{{{
tar -xJf $FILE > /dev/null 2>&1
BUFFER=$?
print_result $BUFFER
if [[ $BUFFER -ne 0 ]]; then
	echo -e "\tCheck the free space in your filesystem."
	echo -e "\tDon't forget to erase the '$LOCAL_PORTAGE_DIR' directory before"
	echo -e "\trunning this script again."
	exit 1;
fi
#}}}

echo -en "$HSTAR Build the Portage Squash image (10/12): " #{{{
mksquashfs $LOCAL_PORTAGE_DIR $SQUASH_FILE > /dev/null 2>&1
BUFFER=$?
print_result $BUFFER
[[ $BUFFER -ne 0 ]] && exit 1
#}}}

echo -en "$HSTAR Test the new image (11/12): " #{{{
mkdir $TEST_DIR > /dev/null 2>&1
mount -o loop -t squashfs $SQUASH_FILE $TEST_DIR > /dev/null 2>&1
BUFFER=$?
print_result $BUFFER
if [[ $BUFFER -ne 0 ]]; then
	echo -e "\tUnable to mount the new squash image."
	echo -e "\tCheck your kernel if it can handle them."
	exit 1
fi
umount $TEST_DIR
#}}}

echo -en "$HSTAR Clean all the stuffs (12/12): " #{{{
clean
#}}}
exit 0
