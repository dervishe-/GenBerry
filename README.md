# GenBerry

## Purpose

GenBerry is a shell script which provide a minimal gentoo 64bit image for
Raspberry Pi 3b, 3b+ and 4b stored on a sdcard.

The images are build following those tutorials:
* https://wiki.gentoo.org/wiki/Raspberry_Pi_3_64_bit_Install
* https://wiki.gentoo.org/wiki/Raspberry_Pi4_64_Bit_Install

## How to use it

### Configuration

This is an abstract of the configuration part. Several are directly adjustable 
from the cli options.

```bash
# The sdcard device on which the system will be built
CARD="/dev/mmcblk0"
# The timezone
TZ="Europe/Paris"
# The keyboard layer
KEYMAPS="fr"
# The hostname
HN="gibolin"
# The content of the /boot/config.txt file
CONFIG_FILE="disable_overscan=1\ndtoverlay=vc4-fkms-v3d\nhdmi_drive=2\ndtparam=audio=on\ndtparam=krnbt=on\ngpu_mem=16\narm_64bit=1"
# The partition layout
PARTITION_SCHEME="unit: sectors\n\nstart=2048, size=262144, type=c, bootable\nstart=264192, size=4194304, type=82\nstart=4458496, type=83"
# Ext4 creation options
FORMAT_ROOT_EXT4="mkfs.ext4 -F -q -i 8192"
# F2FS creation options
FORMAT_ROOT_F2FS="mkfs.f2fs -f -O extra_attr,inode_checksum,sb_checksum"
# Compile flags
MCFLAGS_3="-march=armv8-a+crc -mtune=cortex-a53 -ftree-vectorize -O2 -pipe -fomit-frame-pointer"
MCFLAGS_4="-march=armv8-a+crc+simd -mtune=cortex-a72 -ftree-vectorize -O2 -pipe -fomit-frame-pointer"
```

### Requirements

* For some operations, you need to have admin rights
* A minimal working sdcard
* An internet connection
* A crossdev environment to compile the kernel

## Todo

* Change partitions scheme
* Allow to (dis|e)able some actions
* Add silent mode
* Update the kernel
* Create tarball to expand on a sdcard instead of writing directly onto
* Support for rpi3, rPi2, rPi1 and rPi0 on 32bit arch
* For rPi4 activate USB attached SCSI
* sshd ativated and root allowed to login
