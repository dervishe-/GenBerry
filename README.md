# genBerry
Sort of Gentoo stage 4 for RaspberryPi with several tools.

This collection of scripts:
* helpers
* imagebuilder
* kernelbuilder
* portage2squash
will help you to build a gentoo stage4 for the raspberry Pi boards. I will try to maintain
updated the initial image.

**imagebuilder** will download an initial archive, the latest kernel sources and portage tree.
It will prepare your sdcard (part + format), install the archive on it, build the kernel + 
additional drivers (fbtft), install them and do the same with a squashfs image of the portage tree.

**kernelbuilder** will retrieve the kernel sources: https://github.com/raspberrypi/linux , the notro drivers
for fbtft: https://github.com/notro/fbtft , compile them and install them. (You can also provide an already 
created .config file to customize your kernel.

**portage2squash** will retrieve the portage-latest archive, verify its signature, make a squashfs archive with it.

The system contain no swap space, /var/log and /tmp are tmpfs.

##You will need:
* git (to retrieve some sources)
* crossdev for arm6j (to compile the kernel)
* gpg (to verify several downloaded file signatures)
* sfdisk (to format the sdcard)
* partprobe (in the parted suite)
* dosfstools (for vfat formating)
* imagetool-uncompressed.py (to treat Raspberry Pi 1 familly kernels)
* squashfs-tools (to build the portge image)
* And to be root or use sudo

I you want the script to check the signature of the several files you will need to import some public keys:
* Mine (1): https://keybase.io/dervishe/key.asc
* Gentoo PK (3): https://www.gentoo.org/downloads/signatures/


##To use it:

* plug one sdcard in your computer
* download the tools: git clone https://github.com/dervishe-/genBerry.git
* make them executable: cd genBerry && chmod +x ./
* execute: imagebuilder <options>
'''bash
Option's list:

	-b <type>			Type of the board: 
					1/ for raspberryPi (1 A A+ B B+ and zero) and 
					2/ for raspberryPi (2 B)
					Default type is 1
	-d <dev>			Set the device used to store the system (/dev/mmcblk0)
	-m <dir>			Set the mount point for the disk (./mnt)
	-H hostname			Set the hostname
	-h : --help			Display this help message
	-c : --dont-check		Don't check the several files signature
	-C <file>			Use your own .config file to compile the kernel. Here, you MUST use absolute path to the file
	-n : --no-disk			You have to prepare the disk yourself (partitionning, formating and mounting) and you MUST use this option
					in conjonction with -m in order to indicate the mount point. In this case, it is necessary to adjust the /etc/fstab
					located in the media.
	-k : --keep-files		Keep all the files retrieved (archives, hash, signature, etc)
	-w : --without-fbtft		Don't include the Notro fbtft drivers
	-i : --no-auto-net			Disable network interface startup at boot time (for the raspberry without network interface like zero)
'''


if all goes, just unplug the sdcard and put it in your raspberry Pi.

* The temporary password for root is: toor  (Don't forget to update it...)

For more information, consult the help: imagebuilder --help


Distcc is installed, you have to configure it. 

Then you can make a:

	emerge -uD @world 

in order to update (if needed) the system
