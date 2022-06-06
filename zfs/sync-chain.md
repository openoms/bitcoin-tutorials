# Snapshot and run bitcoin-qt from a cloned filesystem

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


# start the destination node
sudo -u bitcoin bitcoind --listen=0 --datadir=/mnt/hdd/hdd-snapshot-clone/bitcoin

# to use the bitcoin-qt GUI use the password_B to log in with the bitcoin user (might need to permit it in the ssh settings)
ssh -X bitcoin@raspiblitz_ip

bitcoin-qt --listen=0 --datadir=/mnt/hdd/hdd-snapshot-clone/bitcoin
```

```
# OFF
# destroy the clone filesystem
sudo zfs destroy fourdiskpool/hdd/hdd-snapshot-clone
# destroy the snapshot
sudo zfs destroy fourdiskpool/hdd@hdd-snapshot
```