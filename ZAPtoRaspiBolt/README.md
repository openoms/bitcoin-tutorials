

## Connect the ZAP Desktop Lightning wallet to the RaspiBolt

The desktop app ZAP (https://github.com/LN-Zap/zap-desktop)
) is a cross platform Lightning Network wallet focused on user experience and ease of use.

Download ZAP for your operating sytem:
https://github.com/LN-Zap/zap-desktop/releases  
Install instructions: https://github.com/LN-Zap/zap-desktop#install

### Preparation on the Pi

* Allow connections to the RaspiBolt from your LAN. Check what your LAN IP address is starting with eg. 192.168.0.xxx or 192.168.1.xxx and use the address accordingly. Changing the last number (xxx) with .0/24 will allow all IP addresses from your local network.
    `$ sudo nano /home/bitcoin/.lnd/lnd.conf`  

    Add the following line to the section `[Application Options]`:  
  ```tlsextraip=192.168.0.0/24```
  
* Delete tls.cert (restarting LND will recreate it):  
    `$ sudo rm /home/bitcoin/.lnd/tls.*`

* Restart LND :  
  `$ sudo systemctl restart lnd`  
  
* Copy the new tls.cert to user "admin", as it is needed for lncli:  
    `$ sudo cp /home/bitcoin/.lnd/tls.cert /home/admin/.lnd`

* Unlock wallet  
  `$ lncli unlock` 

* Allow the ufw firewall to listen on 10009 from the LAN:  
  `$ sudo ufw allow from 192.168.0.0/24 to any port 10009 comment 'allow LND grpc from local LAN'`

 * restart and check the firewall:  
  `$ sudo ufw enable`  
  `$ sudo ufw status`

  ---

## To use the Connection String method (available from  ZAP 0.4 beta):

### On the RaspiBolt:
* Install LndConnect:  
  `$ cd ~`  
  `$ go get -d github.com/LN-Zap/lndconnect`  - this can take a couple of minutes  
  `$ cd ~/go/src/github.com/LN-Zap/lndconnect`  
  `$ make install`  

* Generate the Connection String  
  `$ cd ~/go/bin`  
  `$ ./lndconnect --lnddir=/home/admin/.lnd --image  --host=your.RaspiBolt.LAN.IP --port=10009`

  Copy the resulting text starting with lndconnect://...

### Set up ZAP: 

  * Start ZAP on your desktop
  * Create new wallet
  * Connect to your node
  * Paste the Connection string generated with LndConnect
  * Confirm and Connect

---

## To use the files method: 

### On your Linux desktop terminal:  

* Copy the tls.cert to your home directory:  
  `$ scp admin@your.RaspiBolt.LAN.IP:/home/admin/.lnd/tls.cert ~/`

* Copy the admin.macaroon to your home directory:  
`$ scp bitcoin@your.RaspiBolt.LAN.IP:/home/bitcoin/.lnd/data/chain/bitcoin/mainnet/admin.macaroon ~/`

### Configure ZAP:

* Start the app and select:  
```Connect your own node```

<img src="./zap1.png">


* Fill in the next screen:  
`your.RaspiBolt.LAN.IP:10009`  
`~/tls.cert`  
`~/admin.macaroon`  

<img src="./zap1.png">

* Confirm the settings on the following screen and you are done!

