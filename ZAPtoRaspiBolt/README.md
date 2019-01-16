

## Connect the ZAP Desktop Lightning wallet to your RaspiBolt


The desktop app ZAP (https://github.com/LN-Zap/zap-desktop)
) is a cross platform Lightning Network wallet focused on user experience and ease of use.

Download ZAP for your operating sytem:
https://github.com/LN-Zap/zap-desktop/releases  
Install instructions: https://github.com/LN-Zap/zap-desktop#install


### Preparation on the Pi

* Add the following line to your lnd configuration file in the section `[Application Options]`  
  `$ sudo nano /home/bitcoin/.lnd/lnd.conf`
  
  ```tlsextraip=0.0.0.0```
* Allow the ufw firewall to listen on 10009 from the LAN

  `$ sudo ufw allow from 192.168.0.0/24 to any port 10009 comment 'allow LND grpc from local LAN'`

 * restart and check the firewall:  
 `$ sudo ufw enable`  
 `$ sudo ufw status`

* Restart LND and unlock wallet  
  `$ sudo systemctl restart lnd`  
  `$ lncli unlock` 
### On your linux desktop:  

* Copy the tls.cert to your home directory:  
  `$ scp admin@your.RaspiBolt.LAN.IP:/home/admin/.lnd/tls.cert ~/`

* Copy the admin.macaroon to your home directory:  
`$ scp admin@your.RaspiBolt.LAN.IP:/home/admin/admin.macaroon ~/`

### Configure ZAP

* Start the app and select:  
```Connect your own node```

![](zap1.png)


* Fill in the next screen:

`your.RaspiBolt.LAN.IP:10009`

`~/tls.cert`

`~/admin.macaroon`

![](zap2.png)

* Confirm the settings on the following screen and you are done!

