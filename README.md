# GenBerry

![logo GenBerry](./GenBerry.png)

## Purpose

GenBerry is a shell script which provide a minimal gentoo image for
Raspberry Pi 1, 2, 3b, 3b+ and 4b in 32 or 64 bit version. You can see it as a
bootable and usable stage4 image.
By default, you will have the latest kernel, stage3 and portage tree. 
You can build directly the sdcard image if you provide one or you can build an 
image to put on the card.
You can customize it with hostname, keyboard layout, timezone, kernel config, 
config.txt and filesystem.

The images are build following those tutorials:
* https://wiki.gentoo.org/wiki/Raspberry_Pi
* https://wiki.gentoo.org/wiki/Raspberry_Pi_3_64_bit_Install
* https://wiki.gentoo.org/wiki/Raspberry_Pi4_64_Bit_Install

## What the script actually do ?

If you don't provide any workplace (-m option), the script will create a new one in /tmp. 
By default, it will ask you an sdcard plugged. It will retrieve the latests kernel sources,
stage3, portage tree and firmwares from their respectives repository. (Cf the config 
part in the script).
It will configure and build the kernel, modules and device tree. Then it will prepare 
the card (partitions, format), expand the various archive on it.
When all the files are where they belong, the script will tune a little the system for you.

## How to use it

### Configuration

You can use the file to configure the script or directly with CLI options.

```
-h		Display this help message

-b <type>	Type of the board:
		1 for raspberryPi 1 family
		2 for raspberryPi 2 family
		3 for raspberryPi 3B
		3P for raspberryPi 3B+
		4 for raspberryPi 4B
		Default value is 4

-m <dir>	Set the mount point for the disk
		Actual value is a temporary directory

-B <branch>	Install a specific kernel branch (from rPi kernel github repository)
		Actual value is the latest official branch

-d <device>	Device to use for install:
		Actual value is /dev/mmcblk0

-k <lang>	Lang for the keymaps
		Actual value is "fr"

-c <file>	Use your own kernel config file
		You need to use the absolute path

-H <hostname>	Fix the hostname
		Actual value is "gibolin"

-t <timezone>	Fix the timezone
		Actual value is "Europe/Paris"

-f <filesystem>	Filesystem for the root partition:
		f2fs, ext4
		Actual value is ext4

-a <actions>	Actions to perform [Actually, for testing purpose]
		You can pick the actions in the following list:
		(all, retrieve_files, prepare_card, build_kernel, populate, tune)
		Actual value is "all"

-C <file>	Use your own config.txt file
		You need to use the absolute path

-M <size>	Mode: 32 or 64 bits
		This apply only on rPi 3, 3P and 4
		Actual value: 64

-s		Copy the kernel sources on the card,
		Beware that this will run make distclean on the actual sources
		Actual value is "false"

-p		Copy the portage tree,
		Actual value is "false"

-i		Build an image instead of writing directly on the media

```
Another config part is also available in the script:
```bash
# 32 or 64 bit
MODE=64$
# Which device to use for the sdcard
CARD="/dev/mmcblk0"$
# your Timezone
TZ="Europe/Paris"$
# Your keymaps
KEYMAPS="fr"$
# Your Hostname
HN="gibolin"$
# Here you can adjust the partitions size and type
PARTITION_SCHEME="unit: sectors\n\nstart=2048, size=262144, type=c, bootable\nstart=264192, size=4194304, type=82\nstart=4458496, type=83"$
# Filesystem format tuning
FORMAT_ROOT_EXT4="mkfs.ext4 -F -i 8192"$
FORMAT_ROOT_F2FS="mkfs.f2fs -f -O extra_attr,inode_checksum,sb_checksum"$
ROOT_FS="ext4"$
#Type of card wanted
RPI_VERSION="4"$
# If you just want an image, here are the size config part and the prefix of the image name
BLOC_SIZE=512$
NBR_BLOCS=$((7 * 1024 * 1024 * 1024 / BLOC_SIZE))$
IMG_PREFIX="GenBerry"$
# Here are the CFLAG content for the considered card
MCFLAGS_1="-march=armv6j -mfpu=vfp -mfloat-abi=hard -O2"$
MCFLAGS_2="-march=armv7-a -mfpu=neon-vfpv4 -mfloat-abi=hard -O2"$
MCFLAGS_3="-march=armv8-a+crc -mtune=cortex-a53 -ftree-vectorize -O2 -pipe -fomit-frame-pointer"$
MCFLAGS_4="-march=armv8-a+crc+simd -mtune=cortex-a72 -ftree-vectorize -O2 -pipe -fomit-frame-pointer"$
NB_JOBS=4$
# Fix the default power governor mode
DEFAULT_POWER_GOV="ONDEMAND"$
```

### Requirements

* For some operations, you need to have admin rights
* A minimal working sdcard
* An internet connection
* A crossdev environment to compile the kernel:
    * aarch64-linux-gnu (rpi 3, 3P, 4)
    * armv7a-linux-gnueabihf (rPi 2, 3, 3P, 4)
    * armv6j-linux-gnueabihf (rpi 1)

### Examples

* Create a simple sdcard for rpi4 on /dev/mmcblk0 with portage tree installed:
```bash
sudo ./GenBerry -p
```
* Create an image for rPi 3B+ in 32 bit mode with f2fs portage and the kernel sources:
```bash
sudo ./GenBerry -p -i -M 32 -f f2fs -b 3P -s
```
This will generate a GenBerry_3P.img file in the work dir. 
* -M 32 means select 32 bit mode
* -i means generate an image instead of using a rela sdcard
* -f f2fs means use f2fs as filesystem for the root partitions (instead of ext4)
* -b 3P means build for raspberry Pi 3B+
* -s means copy the kernel source (it wille be a clean sources afetr a make mrproper)

You can use this image after, this way:
```bash
sudo dd if=GenBerry_3P.img of=/dev/yoursdcard status=progress
```

### [Important] What to do after ?

Once your card is ready, plug it in you Pi and waait for the prompt.
As i couldn't manage to use udhcpc directly in the script, you will need a screen and 
a keyboard to finish:

```bash
busybox udhcpc -i eth0
rc-service busybox-ntpd restart
emerge --sync
emerge -auD --newuse @world
emerge -av --depclean
emerge -av dhcpcd
# If you want to use Wifi
emerge -av wpa_supplicant
rc-update add wpa_supplicant default
# reboot
shutdown -r now
```
Then, you just will have to customize your new system :)

## Todo

* Change partitions scheme
* Allow to (dis|e)able some actions
* Add silent mode
* Update the kernel
* Create tarball to expand on a sdcard instead of writing directly onto
* Support for rPi 0w family
* For rPi4 activate USB attached SCSI
* sshd ativated and root allowed to login
* Allow to choose the password
* Check the available space for building the image
