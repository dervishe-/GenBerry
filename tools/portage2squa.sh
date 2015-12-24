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
LOCATION=http://distfiles.gentoo.org/snapshots
FILE=portage-latest.tar.xz
SIG=${FILE}.gpgsig
HASH=${FILE}.md5sum
WDIR=./repository
TEST_DIR=./mnt
SQUASH_FILE=portage.squashfs
LOCAL_PORTAGE_DIR=portage
#}}}
. ./helpers.sh

clear
echo -e "$HSTAR Checking requirements (1/11): " #{{{
echo -en "\t$HSTAR Is gpg installed ? "
checkGPG
echo -en "\t$HSTAR Are you root ? "
checkRoot
echo -en "\t$HSTAR Are you connected ? "
checkConnectivity
#}}}

echo -en "$HSTAR Building working dir (2/11): " #{{{
([[ -d $WDIR ]] || mkdir "$WDIR") && cd "$WDIR" >> $LOG 2>&1
printResult $?
#}}}

echo -en "$HSTAR Retrieving the fingerprint (3/11): " #{{{
[[ -f $HASH ]] && rm $HASH
getFile $LOCATION/$HASH
#}}}

echo -en "$HSTAR Retrieving the portage archive (4/11): " #{{{
retrieveFile $FILE $HASH $LOCATION
#}}}

echo -en "$HSTAR Checking file's fingerprint (5/11): " #{{{
checkFingerprint $HASH
#}}}

echo -en "$HSTAR Retrieving the file's signature (6/11): " #{{{
getFile $LOCATION/$SIG
#}}}

echo -en "$HSTAR Checking file's signature (7/11): " #{{{
checkSignature $SIG $FILE
if [[ $? -ne 0 ]]; then
	echo -e "\tSignature's problem: the file don't seems to be legit..."
	echo -e "\tPerhap's you don't have imported the Gentoo public key:"
	echo -e "\thttps://www.gentoo.org/downloads/signatures/"
	exit 1;
fi
#}}}

echo -en "$HSTAR Expanding the portage tree (8/11): " #{{{
tar -xJpf $FILE >> $LOG 2>&1
BUFFER=$?
printResult $BUFFER
if [[ $BUFFER -ne 0 ]]; then
	echo -e "\tCheck the free space in your filesystem."
	echo -e "\tDon't forget to erase the '$LOCAL_PORTAGE_DIR' directory before"
	echo -e "\trunning this script again."
	exit 1;
fi
#}}}

echo -en "$HSTAR Building the Portage Squash image (9/11): " #{{{
mksquashfs $LOCAL_PORTAGE_DIR $SQUASH_FILE >> $LOG 2>&1
BUFFER=$?
printResult $BUFFER
[[ $BUFFER -ne 0 ]] && exit 1
#}}}

echo -en "$HSTAR Testing the new image (10/11): " #{{{
[[ -d $TEST_DIR ]] || mkdir $TEST_DIR >> $LOG 2>&1
mount -o loop -t squashfs $SQUASH_FILE $TEST_DIR >> $LOG 2>&1
BUFFER=$?
printResult $BUFFER
if [[ $BUFFER -ne 0 ]]; then
	echo -e "\tUnable to mount the new squash image."
	echo -e "\tCheck your kernel if it can handle them"
	echo -e "\tOr if you have the authorization to mount squashfs volumes."
	exit 1
fi
umount $TEST_DIR
#}}}

echo -en "$HSTAR Cleaning all the stuffs (11/11): " #{{{
cd .. >> $LOG 2>&1
mv $WDIR/$SQUASH_FILE . >> $LOG 2>&1
BUFFER=$?
if [[ $BUFFER -ne 0 ]]; then
	printResult $BUFFER
	echo -e "\tUnable to move the squashfs file: '$SQUASH_FILE' from the temporary directory"
	exit 1
fi
rm -Rf $WDIR >> $LOG 2>&1
BUFFER=$?
printResult $BUFFER
if [[ $BUFFER -ne 0 ]]; then
	echo -e "\tUnable to clean and delete the temporary directory"
	exit 1
fi
#}}}
exit 0
