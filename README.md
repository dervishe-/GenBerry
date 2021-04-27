# GenBerry

![logo GenBerry](./Medias/GenBerry.webp)

## Purpose

GenBerry is a shell script which provide a minimal gentoo image for Raspberry Pi 0, 
0W 1B, 2B, 3B, 3B+ and 4B in 32 or 64 bit version. You can see it as a
bootable and usable stage4 image. The other boards have not been tested yet.
By default, you will have the latest kernel and stage3. 
It can also use qemu in order to performs further installation and configuration 
tasks.

You can install the system directly on a ![device](../../wiki/Several-ways-to-build-the-system#use-a-device) 
or build an ![image](../../wiki/Several-ways-to-build-the-system#create-an-image-to-burn) 
to put on several card or build a ![tarball](../../wiki/Several-ways-to-build-the-system#create-a-tarball) 
to share on a network.

You can customize it with hostname, keyboard layout, timezone, kernel config, 
config.txt and filesystem type. You can also enable the 
![serial console](../../wiki/Networking#serial-console) communications or 
the ![usb tethering](../../wiki/Networking#usb-tethering).

You can use it with any Linux distribution, BSD or macOS X except for functions 
requiring qemu which need a gentoo based system.

**Take a tour on the ![wiki](../../wiki) (always a wiP) for more specific documentation.**


## Requirements

* An internet connection
* A crossdev environment to compile the kernel:
    * aarch64-linux-gnu (rpi 3, 3+, 4)
    * armv7a-linux-gnueabihf (rPi 2, 3, 3+, 4)
    * armv6j-linux-gnueabihf (rpi 0, 0W, 1)
* qemu static installed and packaged (optional: here you need a gentoo based system)


## Installation

You have to clone the repository and switch to the root of the project:
```bash
git clone https://github.com/dervishe-/GenBerry.git
cd ./GenBerry
```


### Configuration

GenBerry comes with several configuration files located in the `GenBerry/Configs` 
directory. As GenBerry needs those files to perform its tasks, if you want to execute 
it outside de `GenBerry` directory you will have to specify the Configs directory location
![here](./GenBerry#L13).

You can use the ![config file](./Configs/GenBerry.cfg) to configure the script 
or directly with CLI options.

### Options list

There are two types of options, the short ones which take an argument and the long 
ones without any arguments
* ![Short options](../../wiki/Options#short-options)
* ![Long options](../../wiki/Options#long-options)

### Examples

* Create a simple sdcard for rpi4 on /dev/mmcblk0:
```bash
sudo ./GenBerry
```
* Create an image for rPi 3B+ in 32 bit mode with f2fs and the kernel sources:
```bash
sudo ./GenBerry --build-image -M 32 -f f2fs -b 3P --add-kernel-src
```
This will generate a GenBerry_3P-32.img file in the work dir. 
* -M 32 means select 32 bit mode
* -f f2fs means use f2fs as filesystem for the root partitions (instead of ext4)
* -b 3P means build for raspberry Pi 3B+

You can use this image after, this way:
```bash
sudo dd if=GenBerry_3P-32.img of=/dev/yoursdcard status=progress
```

### The first boot

Once your card is ready, plug it in you Pi and boot. Then you have two possibilities:
* If you used qemu options, well, just do what you want. There's nothing more to do :). 
* If you didn't used qemu options,  your pi will execute a `firstRun.start` script 
located in `/etc/local.d/`
The content of this script is available ![`here`](./Configs/firstRun.start).
Basically, it will run udhcpc on eth0, sync the time, emerge dhcpcd, and wpa_supplicant 
if wlan0 exists, delete itself and reboot.

**BEWARE: This part of the first boot could be very very long depending of your 
board as firstRun.start emerge some packages. Let the things go quietly at its end
;) You can follow live what's going on with the log file (tail -f ...)** 

After this reboot, your pi will be available thrue eth0 or wlan0 if you gave a 
`wpa_supplicant.conf` in option.

## Participate

Do not hesitate to fill a ticket if you have suggestions, bug reports, found the 
documentation not clear, or saw english faults (as you can read, my english is 
far from perfect ;) )


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
* https://ownyourbits.com/2018/06/13/transparently-running-binaries-from-any-architecture-in-linux-with-qemu-and-binfmt_misc/


## Todo

* Change partitions scheme
* Silent mode
* Update kernel helper
* Boot on USB
* For Pi4 activate USB attached SCSI
* Install the script
* Access point template
* Better sources managment for the rpi firmwares
* Add possibility to use systemd


## Disclaimer

Of course, this script is given without any warantly. Use it at your own risks.


## Credits

* The logo is from Luis Espinosa
