# Snapshot and mount a cloned bitcoin datadir

## Create the snapshot, clone and mount
```
# create snapshot of /mnt/hdd - fourdiskpool/hdd@hdd-snapshot
zfs snap fourdiskpool/hdd@hdd-snapshot
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

# sync (not reliable while the source bitcoind is running)
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
hdd=sde

# create the filesystem and label
# sudo /home/admin/config.scripts/blitz.datadrive.sh format ext4 /dev/${hdd}

sudo parted -s /dev/${hdd} mklabel gpt
sudo parted -s /dev/${hdd} mkpart primary ext4 1024KiB 100%
sudo mkfs.ext4 -F -L BLOCKCHAIN /dev/${hdd}1

# mount
sudo mount /dev/${hdd}1  /media/usb
sudo mkdir /media/usb/bitcoin/

# work in tmux
tmux
cd /mnt/hdd/hdd-snapshot-clone/bitcoin/
sudo cp -rv ./chainstate ./blocks ./indexes ./testnet3 /media/usb/bitcoin/

# monitor disk load
sudo iotop

# remove disk
sudo umount /media/usb
```

## OFF
```
# destroy the clone filesystem
sudo zfs destroy fourdiskpool/hdd/hdd-snapshot-clone
# destroy the snapshot
sudo zfs destroy fourdiskpool/hdd@hdd-snapshot
```