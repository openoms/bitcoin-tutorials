# Snapshot and mount a cloned bitcoin datadir

## Create the snapshot, clone and mount
```
# create snapshot of /mnt/hdd - fourdiskpool/hdd@hdd-snapshot
sudo zfs snap fourdiskpool/hdd@hdd-snapshot
# display snapshots
zfs list -t snap
# clone snapshot (fourdiskpool/hdd/hdd-snapshot-clone)
sudo zfs clone fourdiskpool/hdd@hdd-snapshot fourdiskpool/hdd/hdd-snapshot-clone
# see if mounted
zfs list

# delete lockfile
sudo rm /mnt/hdd/hdd-snapshot-clone/bitcoin/.lock
# delete bitcoin.conf
sudo rm /mnt/hdd/hdd-snapshot-clone/bitcoin/bitcoin.conf
```

## sync an existing snapshot
```
# make sure the source bitcoind is stopped
# it is faster to just create a new snapshot
sudo -u bitcoin rsync -v -r /mnt/hdd/bitcoin/blocks/ /mnt/hdd/hdd-snapshot-clone/bitcoin/blocks/
sudo -u bitcoin rsync -v -r /mnt/hdd/bitcoin/chainstate/ /mnt/hdd/hdd-snapshot-clone/bitcoin/chainstate/
```

## Start bitcoind with the cloned db to test
```
sudo -u bitcoin bitcoind --listen=0 --server=0 --datadir=/mnt/hdd/hdd-snapshot-clone/bitcoin
```

## Remote bitcoin-qt
```
# to use the bitcoin-qt GUI use the password_B to log in with the bitcoin user (might need to permit it in the ssh settings)
ssh -X bitcoin@raspiblitz_ip

bitcoin-qt --listen=0 --server=0 --datadir=/mnt/hdd/hdd-snapshot-clone/bitcoin
```

## Prepare a Raspiblitz SSD
```
# choose the disk to be prepared
lsblk
# !! careful here to choose the right disk !!
hdd=sde

# create the filesystem and label
# sudo /home/admin/config.scripts/blitz.datadrive.sh format ext4 /dev/${hdd}

sudo parted -s /dev/${hdd} mklabel gpt
sudo parted -s /dev/${hdd} mkpart primary ext4 1024KiB 100%
sudo mkfs.ext4 -F -L BLOCKCHAIN /dev/${hdd}1

# mount
sudo mount /dev/${hdd}1  /media/usb
sudo mkdir /media/usb/bitcoin
sudo chown -R bitcoin:bitcoin /media/usb/bitcoin

# work in tmux
tmux
cd /mnt/hdd/hdd-snapshot-clone/bitcoin/
# use time to compare disks (see below)
time sudo -u bitcoin cp -rv ./chainstate ./blocks ./indexes ./testnet3 /media/usb/bitcoin/

# monitor disk load in a split pane (CTRL+B, ")
sudo iotop

# remove disk
sudo umount /media/usb
```

## OFF
```
zfs list
# destroy the clone filesystem
sudo zfs destroy fourdiskpool/hdd/hdd-snapshot-clone
# destroy the snapshot
sudo zfs destroy fourdiskpool/hdd@hdd-snapshot
zfs list
```

# Measurements
```
WD Blue 1TB
real    49m35.539s
user    0m8.089s
sys     15m20.593s

Samsung 870 QVO 1TB
real    113m42.488s
user    0m8.947s
sys     16m33.474s
```