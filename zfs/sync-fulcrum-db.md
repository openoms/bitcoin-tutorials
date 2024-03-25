# Snapshot and mount a datadisk

## Create the snapshot, clone and mount
```
# create snapshot of /mnt/hdd - datadisk/hdd@hdd-snapshot
sudo zfs snap datadisk/hdd@hdd-snapshot
# display snapshots
zfs list -t snap
# clone snapshot (datadisk/hdd/hdd-snapshot-clone)
sudo zfs clone datadisk/hdd@hdd-snapshot datadisk/hdd/hdd-snapshot-clone
# see if mounted
zfs list
```


## Copy over the network
### on the remote computer
```
sudo mkdir -p /mnt/hdd/fulcrum_db
sudo chown admin:admin /mnt/hdd/fulcrum_db
```
### on the source computer
```
sudo scp -r /mnt/hdd/hdd-snapshot-clone/app-storage/fulcrum/db admin@$REMOTE_IP:/mnt/hdd/fulcrum_db/
```
### on the remote computer once finished
sudo mv /mnt/hdd/app-storage/fulcrum/db /mnt/hdd/app-storage/fulcrum/db-corrupt
sudo mv /mnt/hdd/fulcrum_db/db /mnt/hdd/app-storage/fulcrum/
sudo chown -R fulcrum:fulcrum /mnt/hdd/app-storage/fulcrum/db
sudo rm -rf /mnt/hdd/fulcrum_db

## OFF
```
zfs list
# destroy the clone filesystem
sudo zfs destroy datadisk/hdd/hdd-snapshot-clone
# destroy the snapshot
sudo zfs destroy datadisk/hdd@hdd-snapshot
zfs list
```

