# genBerry
Sort of Gentoo stage 4 for RaspberryPi with several tools.

Tools list:

* portage2squa.sh: 
	Build a squash image with a portage tree. The tree is retrieved from gentoo repository,
	verified (hash + signature) and the image is created

* imagebuilder.sh:
	Download the stage4, 
	verify it against the signature, 
	prepare the sdcard:
			partition it
			format it (without swap)
	install the stage4 on the sdcard
