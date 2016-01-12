# genBerry
Sort of Gentoo stage 4 for RaspberryPi with several tools.

This collection of scripts:
* helpers
* imagebuilder
* kernelbuilder
* portage2squash
will help you to build a gentoo stage4 for the raspberry Pi boards. I will try to maintain
updated the initial image.

*imagebuilder* will download an initial archive, the latest kernel sources and portage tree.
It will prepare your sdcard (part + format), install the archive on it, build the kernel + 
additional drivers (fbtft), install them and do the same with a squashfs image of the portage tree.

The system contain no swap space, /var/log and /tmp are tmpfs.

To use it:

I you want the script to check the signature of the several files you will need to import some public keys:
* Mine (1): https://keybase.io/dervishe/key.asc
* Gentoo PK (3): https://www.gentoo.org/downloads/signatures/

Then:

* plug one sdcard in your computer
* download the tools: git clone https://github.com/dervishe-/genBerry.git
* make them executable: cd genBerry && chmod +x ./
* execute: imagebuilder

if all goes, just unplug the sdcard and put it in your raspberry Pi.

* The temporary password for root is: toor  (Don't forget to update it...)

For more information, consult the help: imagebuilder --help


Distcc is installed, you have to configure it. 

Then you can make a:

	emerge -uD @world 

	in order to update (if needed) the system
