# Create a ZFS pool to be used as a Raspiblitz disk

## Documentation
```
man zpool create
man zpool-features
man zfsprops
man zfs-load-key
```

## Install ZFS
* https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html#installation
```
# work as root
sudo su -

echo "deb http://deb.debian.org/debian bullseye-backports main contrib" | sudo tee -a /etc/apt/sources.list.d/bullseye-backports.list
echo "deb-src http://deb.debian.org/debian bullseye-backports main contrib" | sudo tee -a /etc/apt/sources.list.d/bullseye-backports.list

echo "Package: src:zfs-linux" | sudo tee -a /etc/apt/preferences.d/90_zfs
echo "Pin: release n=bullseye-backports" | sudo tee -a /etc/apt/preferences.d/90_zfs
echo "Pin-Priority: 990" | sudo tee -a /etc/apt/preferences.d/90_zfs

apt update
apt install -y dpkg-dev linux-headers-generic linux-image-generic
apt install -y zfs-dkms zfsutils-linux
```

## Create a pool
```
# create encryption key
dd if=/dev/urandom of=/root/.zpoolraw.key bs=32 count=1
chmod 400 /root/.zpoolraw.key

# list physical disks
lsblk --scsi
# get the IDS
ls -la /dev/disk/by-id

# Working with a four disk setup - need identical sizes in the mirrrors

DISK1="/dev/disk/by-id/ata-name-and-id-of-disk1"
DISK2="/dev/disk/by-id/ata-name-and-id-of-disk2"
DISK3="/dev/disk/by-id/ata-name-and-id-of-disk3"
DISK4="/dev/disk/by-id/ata-name-and-id-of-disk4"

# Clear the partition table:
sgdisk --zap-all $DISK1
sgdisk --zap-all $DISK2
sgdisk --zap-all $DISK1
sgdisk --zap-all $DISK2

# create pool with two disk pair mirrored, see the last line and edit to your setup:
# mirror $DISK1 $DISK3 mirror $DISK2 $DISK4
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
    -O mountpoint=/mnt \
    -O encryption=on \
    -O keyformat=raw -O keylocation=file:///root/.zpoolraw.key \
    mirrorpool mirror $DISK1 $DISK3 # mirror $DISK2 $DISK4

# check
zpool status
zpool list

# create a dataset name hdd (so it can be mounted as /mnt/hdd)
zfs create zpool/hdd
# check
zfs list
df -h

# Mount a ZFS dataset to `/mnt/hdd`:
zfs create zpool/hdd
zfs mount zpool/hdd /mnt

#or change an existing mountpoint for a whole pool:
sudo zfs set mountpoint=/mnt/hdd POOL1

# to automount:
echo "\
[Service]
ExecStartPre=/sbin/zfs load-key -a
ExecStartPre=/sbin/zfs mount -la
" | sudo tee /etc/systemd/system/bootstrap.service.d/zfsautomount.conf

# or in cron:
cronjob="@reboot sudo /sbin/zfs load-key -a; sudo /sbin/zfs mount -la"
(
    crontab -u admin -l
    echo "$cronjob"
) | crontab -u admin -
```


## ZFS encryption key operations
```
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

## temperature monitoring
```
sudo sudo apt install hddtemp nvme-cli
sudo hddtemp /dev/sd?
sudo nvme smart-log /dev/nvme0 | grep "^temperature"
sudo nvme smart-log /dev/nvme1 | grep "^temperature"

sudo smartctl -d auto -H /dev/nvme0
sudo smartctl -d auto -H /dev/nvme1

sudo smartctl -d auto -a /dev/nvme1
sudo smartctl -d auto -a /dev/nvme1
```

## import an existing ZFS pool
* https://openzfs.github.io/openzfs-docs/Getting%20Started/Debian/index.html
```
zpool import
zpool import -a
sudo /sbin/zfs load-key -a
sudo /sbin/zfs mount -la

cronjob="@reboot sudo /sbin/zfs load-key -a; sudo /sbin/zfs mount -la"
(
    crontab -u admin -l
    echo "$cronjob"
) | crontab -u admin -
```
