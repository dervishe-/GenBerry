# GenBerry

![logo GenBerry](./GenBerry.webp)

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


| Option | Argument | Values | Description |
|:------:|:--------:|--------|-------------|
|-b|type|0, 0W, 1, 2, 3, 3P, `4`|Type of the board: 0 *(Pi0)*, 0W *(Pi0W)*, 1 *(Pi1)*, 2 *(Pi2)*, 3 *(Pi3)*, 3P *(Pi3B+)*, 4 *(4B)*|
|-m|dir|`/tmp/bldGenPiImg-XXXXXXXXXX`|Set the working directory.|
|-B|branch|`rpi-X.XX.y`|Install a specific kernel branch (from rPi kernel github repository).|
|-d|device|`/dev/mmcblk0`|Device to use for install.|
|-k|lang|`fr`|Lang for the keymaps.|
|-c|file|`/path/to/cfg`|Use your own kernel config file. *You need to use the absolute path*|
|-H|hostname|`gibolin`|Fix the hostname.|
|-t|timezone|`Europe/Paris`|Fix the timezone.|
|-f|filesystem|f2fs, `ext4`|Filesystem for the root partition.|
|-a|actions|`all`,retrieve_files,prepare_card, build_kernel,populate,tune|Actions to perform Actually, **for testing purpose only**|
|-C|file|`/path/to/cfg`|Use your own config.txt file. *(You need to use the absolute path)*|
|-M|size|32, `64`|Architecture 32 or 64 bits. **This apply only on rPi 3, 3P and 4**|
|-h| | |Display this help message.|
|-s| | |Copy the kernel sources on the card, Beware that this will run make distclean on the actual sources.|
|-p| | |Copy the portage tree.|
|-i| | |Build an image to burn on the media.|
|-T| | |Build a tarball to expand on a pre-formated media.|
|-u| | |Enable serial communications. Might disable bluetooth on some boards.|
|-U| | |Enable usb tethering. Might need some tweak on your computer. Actually only tested on Pi 0 and 0W.|
|-S| | |Enable sshd server with root connections allowed. If ssh-add -L give a record it will be use for the connection, else use the password.|

(Defaults value in the table above are `highlighted`)

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

### What to do after ?

Once your card is ready, plug it in you Pi and boot. If you don't have a screen available
you can use the -u option to connect to your pi via the uart serial interface.
After the first boot, your pi will execute a `firstRun.start` script located in `/etc/local.d/`
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

## Todo

* Change partitions scheme
* (dis|en)able some actions
* Silent mode
* Update kernel helper
* For Pi4 activate USB attached SCSI
* Choose the password

## Disclaimer

Of course, this script is given without any warantly. Use it at your own risks.

## Credits

* The logo is from Luis Espinosa
