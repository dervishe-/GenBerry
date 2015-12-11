#!/bin/bash
# vim: foldmarker={{{,}}}
#
# helpers.sh
# Author: Alexndre Keledjian <dervishe@yahoo.fr>
# Version: 1.0
# License: GPLv3
# 
#
# Some kind of library
#

#{{{ Helpers
HSTAR="\e[1;32m*\e[0m\e[37m"

function printResult()
{
	[[ $1 -ne 0 ]] && echo -e "\e[1;31m[FAIL]\e[0m" || echo -e "\e[1;32m[OK]\e[0m\e[37m"
	return 0
}

function getFile()
{
	wget $1 > /dev/null 2>&1
	local BUFFER=$?
	printResult $BUFFER
	if [[ $BUFFER -ne 0 ]]; then 
		echo -e "\tThe file can't be retrieve. Check the name, the address or the connectivity."
		exit 1
	fi
	return 0
}

function checkConnectivity()
{
	ping -c 1 -w 2 www.gentoo.org > /dev/null 2>&1
	BUFFER=$?
	printResult $BUFFER
	if [[ $BUFFER -ne 0 ]]; then
		echo -e "\tYour connection seems to be down."
		exit 1
	fi
	return 0
}
#}}}
