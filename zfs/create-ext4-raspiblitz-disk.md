```
parted -s /dev/${hdd} mkpart primary ext4 1024KiB 100%
mkfs.ext4 -F -L BLOCKCHAIN /dev/${hdd}
tune2fs -c 1 /dev/${hdd}
```

```
    hddDataPartitionExt4=$hdd
    # loop until the uuids are available
    uuid1=""
    loopcount=0
    while [ ${#uuid1} -eq 0 ]
    do
      echo "# waiting until uuid gets available"
      sleep 2
      sync
      uuid1=$(lsblk -o NAME,UUID | grep "${hddDataPartitionExt4}" | awk '$1=$1' | cut -d " " -f 2 | grep "-")
      loopcount=$(($loopcount +1))
      if [ ${loopcount} -gt 10 ]; then
        echo "error='no uuid'"
        exit 1
      fi
    done

    echo "# mount /mnt/hdd"
    mkdir -p /mnt/hdd 1>/dev/null
    updated=$(cat /etc/fstab | grep -c "/mnt/hdd")
    if [ $updated -eq 0 ]; then
       echo "# updating /etc/fstab"
       sed "/raspiblitz/ i UUID=${uuid1} /mnt/hdd ext4 noexec,defaults 0 2" -i /etc/fstab 1>/dev/null
    fi
    sync
    mount -a 1>/dev/null


      # make sure common base directory exits
  mkdir -p /mnt/hdd/lnd
  mkdir -p /mnt/hdd/app-data

      >&2 echo "# Creating EXT4 setup links"
    >&2 echo "# opening blockchain into /mnt/hdd"
    mkdir -p /mnt/hdd/bitcoin
    >&2 echo "# linking blockchain for user bitcoin"
    rm /home/bitcoin/.bitcoin 2>/dev/null
    ln -s /mnt/hdd/bitcoin /home/bitcoin/.bitcoin
    >&2 echo "# linking lnd for user bitcoin"
    rm /home/bitcoin/.lnd 2>/dev/null
    ln -s /mnt/hdd/lnd /home/bitcoin/.lnd
    >&2 echo "# creating default storage & temp folders"
    mkdir -p /mnt/hdd/app-storage
    mkdir -p /mnt/hdd/temp


  # fix ownership of linked files
  chown -R bitcoin:bitcoin /mnt/hdd/bitcoin
  chown -R bitcoin:bitcoin /mnt/hdd/lnd
  chown -R bitcoin:bitcoin /home/bitcoin/.lnd
  chown -R bitcoin:bitcoin /home/bitcoin/.bitcoin
  chown bitcoin:bitcoin /mnt/hdd/app-storage
  chown bitcoin:bitcoin /mnt/hdd/app-data
  chown -R bitcoin:bitcoin /mnt/hdd/temp 2>/dev/null
  chmod -R 777 /mnt/temp 2>/dev/null
  chmod -R 777 /mnt/hdd/temp 2>/dev/null

  # write info files about what directories are for

  echo "The /mnt/hdd/temp directory is for short time data and will get cleaned up on very start. Dont work with data here thats bigger then 25GB - because on BTRFS hdd layout this is a own partition with limited space. Also on BTRFS hdd layout the temp partition is an FAT format - so it can be easily mounted on Windows and OSx laptops by just connecting it to such laptops. Use this for easy export data. To import data make sure to work with the data before bootstrap is deleting the directory on startup." > ./README.txt
  mv ./README.txt /mnt/hdd/temp/README.txt 2>/dev/null

  echo "The /mnt/hdd/app-data directory should be used by additional/optional apps and services installed to the RaspiBlitz for their data that should survive an import/export/backup. Data that can be reproduced (indexes, etc.) should be stored in app-storage." > ./README.txt
  mv ./README.txt /mnt/hdd/app-data/README.txt 2>/dev/null

  echo "The /mnt/hdd/app-storage directory should be used by additional/optional apps and services installed to the RaspiBlitz for their non-critical and reproducible data (indexes, public blockchain, etc.) that does not need to survive an an import/export/backup. Data is critical should be in app-data." > ./README.txt
  mv ./README.txt /mnt/hdd/app-storage/README.txt 2>/dev/null

  >&2 echo "# OK - all symbolic links are built"
```
