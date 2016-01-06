# genBerry
Sort of Gentoo stage 4 for RaspberryPi with several tools.

## Tools list:

* portage2squa.sh: 
	Build a squash image with a portage tree. The tree is retrieved from gentoo repository,
	verified (hash + signature) and the image is created

* kernelbuilder.sh:
	Download the kernel sources on Git
	Configure and compile it
	install the boot files, the kernel and the modules

* imagebuilder.sh:
	Download the stage4, 
	Verify it against the signature, 
	Prepare the sdcard:
			partition it
			format it (without swap)
	Install the stage4 on the sdcard
	Cross-compile and install the latest kernel
	Retrieve and install the last portage tree on a quashfs image
	Cleann all the stuff

## How it works

You have to be root to use it.

* Get the tools on GitHub: 
git clone https://github.com/dervishe-/genBerry.git

* Make them executable
cd tools
chmod +x ./*.sh

* Put your sdcard in the card-reader

* Following your raspberryPi model:
	1A, 1A+, 1B or 1B+ -> 1
	2A, 2B -> 2

* Launch the script
buildimage.sh 1 or buildimage 2
At the end of the script if all goes well, you just have to take your sdcard , put it in
your rPi and boot this one.

* The temporary password for root is: toor
Update it...

There is no swap, /tmp and /var/log are tmpfs mount and the portage tree is in a squashfs 
archive.

Distcc is installed, you have to configure it. 
Then you can make a:
	emerge -uD @world 
in order to update (if needed) the system
