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

## Restore a Raspiblitz ZFS disk
* do this when the pool is already mounted to /mnt/hdd
  ```
  # switch off swapfile
  sudo dphys-swapfile swapoff
  sudo dphys-swapfile uninstall

  # make links and fix permissions
  sudo config.scripts/blitz.datadrive.sh link

  # run bootstrap again
  # sudo /home/admin/_bootstrap.sh
  sudo systemctl restart bootstrap.service

  # set state and setupPhase
  /home/admin/_cache.sh set state waitsetup
  /home/admin/_cache.sh set setupPhase recovery

  # change the password A
  sudo config.scripts/blitz.passwords.sh set a

  # run the recovery of the rest of the services (consider in tmux)
  sudo /home/admin/_provision_.sh

  # monitor in  a new terminal
  tail -f raspiblitz.log

  # fix tor
  /home/admin/config.scripts/tor.install.sh enable

  # fix python3
  sudo rm /usr/lib/python3.*/EXTERNALLY-MANAGED

  ## mainnet
  # switch on bitcoind
  config.scripts/bitcoin.install.sh on mainnet

  # switch on CLN:
  config.scripts/cl.install.sh on mainnet

  # switch on LND:
  config.scripts/lnd.install.sh on mainnet


  ## signet
  # switch on bitcoind
  config.scripts/bitcoin.install.sh on signet

  # switch on CLN:
  config.scripts/cl.install.sh on signet

  # switch on LND:
  config.scripts/lnd.install.sh on signet

  # reboot to rerun the bootstrap script and synchronise the state with the redis database
  restart
  ```
