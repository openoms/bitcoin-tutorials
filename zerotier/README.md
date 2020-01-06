## Set up the RaspiBlitz for remote connections with ZeroTier

ZeroTier is a VPN service which is an easy option to connect remotely when neither port forwarding nor using Tor is possible (e.g. iOS on a remote network)

The drawback is that it requires installing a trusted (open-source) package which gives access to your private network.  

Steps to install:

* Create a my.zerotier.com account and a network

* Go to https://my.zerotier.com/login and register. 
Use a STRONG PASSWORD as anyone with your credentials will have access to your private network.

* Click `Create a network` then record your `Network ID`.
* Install ZeroTier on the RaspiBlitz (more details on https://www.zerotier.com/download.shtml):  
  ```
  $ curl -s 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg' | gpg --import && \
  if z=$(curl -s 'https://install.zerotier.com/' | gpg); then echo "$z" | sudo bash; fi
  ```

* Then run:

    `$ sudo zerotier-cli join [the network ID you previously recorded]`

* Install ZeroTier on your other devices: iOS, Android, Windows, Mac, Linux, etc. Use the same `network ID` you recorded before.
* Open https://my.zerotier.com  `Networks` menu and accept the new devices pending approval.

* On the Raspiblitz modify the lnd.conf manually:  
`$ sudo nano /mnt/hdd/lnd/lnd.conf`  
    
    add the line:  
    ```
    tlsextraip=172.X
    ```
    CTRL+O and ENTER to save, CTRL+X to exit  

    Restart LND and unlock:  
    `$ sudo systemctl restart lnd`  
    `$ lncli unlock`

* Renew the TLS certificates either from the EXPORT menu or run:  
`$ ./config.scripts/lnd.newtlscert.sh`

After setting up and activating ZeroTier on my Android phone successfully tested: 
* ZeusLN using the IP 172.x.x.x and port 8080
* RTL from the outside on my 172.x.x.x:3000 address 
* Termius to connect with ssh to admin@172.x.x.x
---
* To uninstall run:
    ```bash
    $ sudo systemctl stop zerotier-one
    $ sudo apt remove zerotier-one
    $ sudo rm -r /var/lib/zerotier-one
    ```
---

This guide is based on: https://medium.com/@ketominer/using-nodl-remotely-with-zerotier-a9a17cbb48cf

Discussion: https://github.com/rootzoll/raspiblitz/issues/601

