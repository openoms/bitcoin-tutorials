<!-- omit from toc -->
# Create a ZFS pool to be used as a Raspiblitz data disk

- [Raspiblitz setup notes](#raspiblitz-setup-notes)
- [Install ZFS](#install-zfs)
- [Create the encryption key](#create-the-encryption-key)
- [Create a pool](#create-a-pool)
  - [Examples](#examples)
  - [A four disk setup](#a-four-disk-setup)
  - [Mount to /mnt/hdd](#mount-to-mnthdd)
  - [manual Raspiblitz config with the zfs pool mounted](#manual-raspiblitz-config-with-the-zfs-pool-mounted)
- [Attach a new disk to an existing pool](#attach-a-new-disk-to-an-existing-pool)
- [ZFS encryption key operations](#zfs-encryption-key-operations)
- [Temperature monitoring](#temperature-monitoring)
- [Import an existing ZFS pool](#import-an-existing-zfs-pool)
- [Copy files while keeping the owners and permissions](#copy-files-while-keeping-the-owners-and-permissions)
- [Documentation](#documentation)

## Raspiblitz setup notes
* to start with ZFS build the data disk during the initial setup - before the EXT4 data disk is created and mounted (this happens after running the build_sdcard.sh and rebooting or using the prebuilt image on the first boot)
* prebuilt OS disk images for amd64: https://github.com/rootzoll/raspiblitz/tree/dev/ci#images-generated-in-github-actions
* you can start with the single EXT4 data disk as default and switch to ZFS later by adding a new disk, set up ZFS, mount, automount and copy the data

## Install ZFS
* https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html#installation
    ```
    # work as root
    sudo su -

    echo "deb http://deb.debian.org/debian bookworm-backports main contrib
    deb-src http://deb.debian.org/debian bookworm-backports main contrib" | sudo tee -a /etc/apt/sources.list.d/bookworm-backports.list

    echo "Package: src:zfs-linux" | sudo tee -a /etc/apt/preferences.d/90_zfs
    echo "Pin: release n=bookworm-backports" | sudo tee -a /etc/apt/preferences.d/90_zfs
    echo "Pin-Priority: 990" | sudo tee -a /etc/apt/preferences.d/90_zfs

    apt update
    apt install -y dpkg-dev linux-headers-generic linux-image-generic
    # might need to reboot here if the headers are updated
    apt install -y zfs-dkms zfsutils-linux
    # test
    zpool status
    ```

## Create the encryption key
* could use a CLN hsm_secret, see https://twitter.com/openoms/status/1480881081851207683
    ```
    dd if=/dev/urandom of=/root/.zpoolraw.key bs=32 count=1
    chmod 400 /root/.zpoolraw.key
    ```

## Create a pool
* see for the basic options
    ```
    man zpoolconcepts
    ```
* [Why you should use mirror vdevs not raidz](https://jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raid)
### Examples
* edit the last line of the `zpool create` command
* for 4 disks - 2 pairs mirrored:
    ```
    mirror $DISK1 $DISK3 mirror $DISK2 $DISK4
    ```
* for 2 disks - 1 pair mirrored:
    ```
    mirror $DISK1 $DISK2
    ```
* for single data disk (can be extended to be a mirror later with `zpool attach`)
    ```
    $DISK1
    ```

### A four disk setup
* needs identical sizes in the mirrors
    ```
    # list physical disks
    lsblk --scsi
    # get the IDs
    ls -la /dev/disk/by-id

    DISK1="/dev/disk/by-id/ata-name-and-id-of-disk1"
    DISK2="/dev/disk/by-id/ata-name-and-id-of-disk2"
    DISK3="/dev/disk/by-id/ata-name-and-id-of-disk3"
    DISK4="/dev/disk/by-id/ata-name-and-id-of-disk4"

    # Clear the partition table:
    sgdisk --zap-all $DISK1
    sgdisk --zap-all $DISK2
    sgdisk --zap-all $DISK3
    sgdisk --zap-all $DISK4

    # Clean a disk which was previously used with zfs:
    wipefs -a $DISK1

    ## Decide on a pool name
    POOL_NAME=<pool name>
    ```

    ```
    zpool create \
        -o cachefile=/etc/zfs/zpool.cache \
        -o ashift=12 -d \
        -o feature@async_destroy=enabled \
        -o feature@bookmarks=enabled \
        -o feature@bookmark_v2=enabled \
        -o feature@embedded_data=enabled \
        -o feature@empty_bpobj=enabled \
        -o feature@enabled_txg=enabled \
        -o feature@encryption=enabled \
        -o feature@extensible_dataset=enabled \
        -o feature@filesystem_limits=enabled \
        -o feature@hole_birth=enabled \
        -o feature@large_blocks=enabled \
        -o feature@livelist=enabled \
        -o feature@lz4_compress=enabled \
        -o feature@spacemap_histogram=enabled \
        -o feature@zpool_checkpoint=enabled \
        -O acltype=posixacl -O canmount=off -O compression=lz4 \
        -O devices=off -O normalization=formD -O relatime=on -O xattr=sa \
        -O encryption=on \
        -O keyformat=raw -O keylocation=file:///root/.zpoolraw.key \
        $POOL_NAME \
        mirror $DISK1 $DISK3 mirror $DISK2 $DISK4

    # check
    zpool status
    zpool list
    ```

### Mount to /mnt/hdd
*   ```
    # create a dataset named hdd (so it can be mounted as /mnt/hdd)
    zfs create $POOL_NAME/hdd

    # mount a ZFS dataset to /mnt/hdd
    zfs set mountpoint=/mnt $POOL_NAME
    zfs load-key -a
    zfs mount -la

    # check
    zfs list
    df -h

    # automount with cron
    cronjob="@reboot sudo /sbin/zfs load-key -a; sudo /sbin/zfs mount -la"
    (
        crontab -u admin -l
        echo "$cronjob"
    ) | crontab -u admin -

    # list the active crontab for admin
    crontab -u admin -l
    ```

### manual Raspiblitz config with the zfs pool mounted
* Assuming a new setup you have exited before it was mounting and formatting the data disk itself
    ```
    # create a minimal /home/admin/raspiblitz.info
    echo "baseimage=debian
    cpu=x86_64
    blitzapi=off
    state='setup'" | sudo tee /home/admin/raspiblitz.info
    sudo chmod 664 /home/admin/raspiblitz.info

    # create a minimal /mnt/hdd/raspiblitz.conf
    echo "# RASPIBLITZ CONFIG FILE
    raspiBlitzVersion='1.9.0rc3'
    lcdrotate=0
    lightning=off
    network='bitcoin'
    chain='main'
    runBehindTor=on
    mainnet=on" | sudo tee /mnt/hdd/raspiblitz.conf
    sudo chmod 644 /home/admin/raspiblitz.info

    # create symlinks
    config.scripts/blitz.datadrive.sh link

    # install bitcoin
    config.scripts/bitcoin.install.sh on mainnet

    # for CLN:
    config.scripts/cl.install.sh on mainnet

    # for LND:
    config.scripts/cl.install.sh on mainnet

    # reboot to rerun the bootstrap script and synchronise the state with the redis database
    restart
    ```

## Attach a new disk to an existing pool
* by adding another disk can convert a single zfs disk pool to mirrorred pool or a two-way mirror to a three-way mirror
    ```
    # choose the existing disk from:
    zpool status
    POOL_NAME=<pool name>
    EXISTING_DISK=<existing-disk-id>

    # choose the new disk id from:
    # the tmlist of physical disks
    lsblk --scsi
    # get the IDs
    ls -la /dev/disk/by-id
    NEW_DISK=/dev/disk/by-id/ata-<new-disk-id>

    # attach the new disk
    zpool attach $POOL_NAME $EXISTING_DISK $NEW_DISK

    # check - should start to resilver as the new disk is added
    zpool status
    ```

## ZFS encryption key operations
*   ```
    # backup the key
    xxd /root/.zpoolraw.key
    00000000: 30cc f221 94e1 7f01 cd54 d68c a1ba f124 0..!.....T.....$
    00000010: e1f3 1d45 d904 823c 77b7 1e18 fd93 1676 ...E... <w......v

    # recover the key from text
    # https://lightning.readthedocs.io/BACKUP.html#hsm-secret
    cat >.zpoolraw_hex.txt <<HEX
    00: 30cc f221 94e1 7f01 cd54 d68c a1ba f124
    10: e1f3 1d45 d904 823c 77b7 1e18 fd93 1676
    HEX
    xxd -r .zpoolraw_hex.txt >/root/.zpoolraw.key
    chmod 0400 .zpoolraw.key
    srm .zpoolraw_hex.txt
    ```

## Temperature monitoring
*   ```
    sudo sudo apt install hddtemp nvme-cli
    sudo hddtemp /dev/sd?
    sudo nvme smart-log /dev/nvme0 | grep "^temperature"
    sudo nvme smart-log /dev/nvme1 | grep "^temperature"

    sudo smartctl -d auto -H /dev/nvme0
    sudo smartctl -d auto -H /dev/nvme1

    sudo smartctl -d auto -a /dev/nvme1
    sudo smartctl -d auto -a /dev/nvme1
    ```

## Import an existing ZFS pool
* https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html
    ```
    poolname="fourdiskpool"
    zpool import ${poolname} -f

    # restore the key

    # load key and mount
    sudo /sbin/zfs load-key -a
    sudo /sbin/zfs mount -la

    # check
    df -h

    # automount with cron on reboot
    cronjob="@reboot sudo /sbin/zfs load-key -a; sudo /sbin/zfs mount -la"
    (
        crontab -u admin -l
        echo "$cronjob"
    ) | crontab -u admin -
    # list the active crontab for admin
    crontab -u admin -l
    ```

## Copy files while keeping the owners and permissions
*   ```
    # change to destination
    cd /mnt1/hdd
    # copy with the flags --archive --verbose --recursive --progress
    rsync -avrP /mnt/hdd/* ./
    ```

## Documentation
- [OpenZFS on Debian](https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html)
- [Capacity calculator](https://wintelguy.com/zfs-calc.pl)
- [Why you should use mirror vdevs not raidz](https://jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raid)
- [ZFS manager plugin for Cockpit](https://github.com/45Drives/cockpit-zfs-manager)
    ```
    man zpoolconcepts
    man zpool create
    man zpool-features
    man zfsprops
    man zfs-load-key
    ```
