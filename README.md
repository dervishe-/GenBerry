# GenBerry

![logo GenBerry](./Medias/GenBerry.webp)

## Purpose

GenBerry is a shell script which provide a minimal gentoo image for
Raspberry Pi 0, 0W 1B, 2B, 3B, 3B+ and 4B in 32 or 64 bit version. You can see it as a
bootable and usable stage4 image. The other boards have not been tested.
By default, you will have the latest kernel, stage3 and portage tree. 
You can install the system on a sdcard if you provide one or you can build an 
image to put on the card.
You can customize it with hostname, keyboard layout, timezone, kernel config, 
config.txt and filesystem type. You can also enable the serial console communications.

## What the script actually do ?

If you don't provide any workplace (`-m` option), the script will create a new one in /tmp. 
By default, it will ask you an sdcard plugged. It will retrieve the latests kernel sources,
stage3, portage tree and firmwares from their respectives repository.
It will configure and build the kernel, modules and device tree. Then it will prepare 
the card (partitions, format) and expand the various archives on it.
When all the files are where they belong, the script will tune a little the system for you.

## How to use it

### Configuration

You can use the ![config file](./GenBerry.cfg) to configure the script or directly 
with CLI options. Help is available via:
```bash
GenBerry -h
```

### Options list

There are two types of options, the short ones which take an argument and the long ones without any arguments
* ![Short options](../../wiki/Options#short-options)
* ![Long options](../../wiki/Options#long-options)

### Requirements

* For some operations, you need to have admin rights
* A minimal working sdcard
* An internet connection
* A crossdev environment to compile the kernel:
    * aarch64-linux-gnu (rpi 3, 3+, 4)
    * armv7a-linux-gnueabihf (rPi 2, 3, 3+, 4)
    * armv6j-linux-gnueabihf (rpi 0, 0W, 1)

### Examples

* Create a simple sdcard for rpi4 on /dev/mmcblk0 with portage tree installed:
```bash
sudo ./GenBerry --add-portage
```
* Create an image for rPi 3B+ in 32 bit mode with f2fs portage and the kernel sources:
```bash
sudo ./GenBerry --add-portage --build-image -M 32 -f f2fs -b 3P --add-kernel-src
```
This will generate a GenBerry_3P.img file in the work dir. 
* -M 32 means select 32 bit mode
* -f f2fs means use f2fs as filesystem for the root partitions (instead of ext4)
* -b 3P means build for raspberry Pi 3B+

You can use this image after, this way:
```bash
sudo dd if=GenBerry_3P.img of=/dev/yoursdcard status=progress
```

### What to do after ?

Once your card is ready, plug it in you Pi and boot. Then you have two possibilities. If you used qemu options, well, just do what you want. There's nothing more to do :). If you didn't used qemu options,  your pi will execute a `firstRun.start` script located in `/etc/local.d/`
The content of this script is available in the ![`FIRSTRUN`](./GenBerry.cfg).
Basically, it will run udhcpc on eth0, sync the time, emerge dhcpcd, delete itself and reboot.
After this reboot, your pi will be available thrue eth0.
Once you're logged in, just execute this few commands, to make the thingss proper:

```bash
emerge --sync
emerge -auD --newuse @world
emerge -av --depclean
# If you want to use Wifi
emerge -av wpa_supplicant
rc-update add wpa_supplicant default
# reboot
shutdown -r now
```
Then, you just will have to customize your new system :)

## Sources

* https://wiki.gentoo.org/wiki/Raspberry_Pi
* https://wiki.gentoo.org/wiki/Raspberry_Pi_3_64_bit_Install
* https://wiki.gentoo.org/wiki/Raspberry_Pi4_64_Bit_Install
* https://www.raspberrypi.org/documentation/linux/kernel/building.md
* https://www.raspberrypi.org/documentation/configuration/config-txt/boot.md
* https://www.framboise314.fr/le-port-serie-du-raspberry-pi-3-pas-simple/
* https://socialcompare.com/fr/comparison/raspberrypi-models-comparison
* http://wiki.openmoko.org/wiki/USB_Networking
* https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html#ARM-Options
* https://wiki.gentoo.org/wiki/GCC_optimization
* https://developer.arm.com/architectures/instruction-sets/floating-point

## Todo

* Change partitions scheme
* (dis|en)able some actions
* Silent mode
* Update kernel helper
* Boot sur USB
* For Pi4 activate USB attached SCSI
* Add userland utilities form RaspberryOS

## Disclaimer

Of course, this script is given without any warantly. Use it at your own risks.

## Credits

* The logo is from Luis Espinosa
