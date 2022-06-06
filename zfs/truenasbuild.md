# TrueNAS CORE server build

Following [Guide to ₿itcoin & Lightning️ on FreeNAS / TrueNAS from @set586](https://github.com/seth586/guides/blob/master/FreeNAS/bitcoin/README.md)

[FreeNAS became TrueNAS CORE](https://www.ixsystems.com/blog/freenas-truenas-unification/)

[TrueNAS CORE Docs](https://www.truenas.com/docs/core/)

[CORE Hardware Guide](https://www.truenas.com/docs/core/introduction/corehardwareguide/)


## Hardware

Chose an affordable HP ProLiant ML310e Gen8 v2 microserver

[User Guide](https://content.etilize.com/User-Manual/1028053012.pdf)

up to 32 GB ECC RAM
120GB SSD to boot
6 x 1 TB SSD for storage

### Redundant disks

TrueNAS uses ZFS.
Recommended type: RAID-Z2 (Double parity with variable stripe width)
[ZFS / RAIDZ Capacity Calculator](https://wintelguy.com/zfs-calc.pl)
You can’t add drives to a volume once its setup, however you can replace drives with larger drives.
6 drives in RAIDZ2 (more than 50% of additive capacity)
4 drives in RAIDZ2 (less than 50% of additive capacity)

#### Drive connectors:
* 1 can boot from USB (SSD with a USB to SATA adapter)
* 2 x onboard SATA
* 4 x onboard SATA controller -> hotplug cage
* \+ optional SAS card / HBA (2x4 SATA connector=8)

max 6 without SATA card (+ USB)
max 14 (+ USB)

#### Physical drives
* 4 or 8 in hotplug cage
* 6\*2 2.5" or (2\*2 2.5"+ 2\*1 3.5") in 5.25 Optical Bay Drive Slot Case Adapter

max 20 2.5"
or
12 2.5" + 2 3.5"

#### Actual:
* 4 onboard SATA -> 4 2.5" adapter in LFF hotplug cage
* 2 onboard SATA
* 2 from SATA card -> 4 2.5"
* 2 from SATA card -> 2 3.5"

10 disks


#### Mirrored boot drives:

Could benefit from a RAID card:
https://www.truenas.com/community/threads/to-boot-with-usb-or-ssd-or-nvme.83594/post-620199

RAID 1 configurations can tolerate one drive failure. If one physical drive in a RAID 1 configuration fails, the RAID volume is still intact as a degraded RAID 1.

#### Harware notes
B120i is just software RAID
[B120i User guide](http://docshare04.docshare.tips/files/31252/312525081.pdf)

Use the onboard SAS adapter (4 SATA connections) or choose a reputable HBA:
https://www.servethehome.com/buyers-guides/top-hardware-components-freenas-nas-servers/top-picks-freenas-hbas/

In BIOS setup
System Options, SATA Controller Options, Embedded SATA Configuration, Enable SATA AHCI support

The embedded storage controller supports SATA drive installation only. For SAS drive installation, install a Smart Array card and a Mini-SAS cable option kit. Optional Smart Array controllers support both SATA and SAS drives.

Beware! The two system fans are custom, and cannot be replaced with standard ones. A dead fan will prevent your system from even booting! So as you get it, better take a couple spares on the ebay/aliexpress ecc

TEST:
* does the onboard SATA controller work together with the B120i?
* can the B120i be used to boot?

#### Hardware debug
[POST debug flowchart](https://i.stack.imgur.com/5NtIt.png)
from https://serverfault.com/questions/465883/hp-proliant-dl360-g7-hangs-at-power-and-thermal-calibration-screen

[HP ProLiant Servers Troubleshooting Guide](http://h10032.www1.hp.com/ctg/Manual/c00257512.pdf)

### Redundant power
#### UPS
[APC UPS config](https://www.cyberciti.biz/faq/how-to-install-apc-ups-on-freenas-server/)
#### Dual power supply
Can be connected to 2 UPS-es, the second backed by a large battery or generator

### Redundant network
E.g broadband + 4G
    * router level (1 NIC)
    * dual router (2 NICs)
The router + modem needs to be connected to the UPS as well.

## Setting up TrueNAS

[Encryption](https://www.truenas.com/docs/core/storage/pools/storageencryption/)
Keys for data-at-rest are managed on the local TrueNAS system.




DebianVM:
set VNC to 800x600:
https://www.truenas.com/community/threads/debian-vm-display-is-not-clear-with-vnc.88501/post-613065

fix boot: https://www.truenas.com/community/threads/howto-how-to-boot-linux-vms-using-uefi.54039/

Fix GUI desktop:
https://www.truenas.com/community/threads/debian-vm-with-gui.90808/post-629025
