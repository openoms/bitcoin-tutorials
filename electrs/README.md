# Electrum Server in Rust (electrs) setup on the RaspiBlitz

\`The server indexes the entire Bitcoin blockchain, and the resulting index enables fast queries for any given user wallet, allowing the user to keep real-time track of his balances and his transaction history using the Electrum wallet. Since it runs on the user's own machine, there is no need for the wallet to communicate with external Electrum servers, thus preserving the privacy of the user's addresses and balances.\` - [https:/github.com/romanz/electrs](https:/github.com/romanz/electrs)

![electrum](/electrs/images/electrum.png)

Tested on:
* Odroid HC1 and XU4 (~18 hours)
* Raspberry Pi 3 B+ (~two days to build the database from scratch)
* Raspberry Pi 4

Requires 47 Gb diskpace (March 2019).

## Install Electrs

***
**The new Electrs installs are currently not working**: https://github.com/romanz/electrs/issues/170  
In the meantime the more lightweight Electrum Personal Server is a good alternative (and recommended for the RPi3-s by default): 
https://stadicus.github.io/RaspiBolt/raspibolt_64_electrum.html
***

The install instructions are adapted to the RaspiBlitz are in this script, take a look: [1_electrs_on_RaspiBlitz.sh](1_electrs_on_RaspiBlitz.sh)

To download and run on the RaspiBlitz (logged in as the user `admin`):  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/1_electrs_on_RaspiBlitz.sh && bash 1_electrs_on_RaspiBlitz.sh`  

This will only run the server until the terminal window is open.  
To restart electrs manually run (with your PASSWORD_B filled in) or install the Electrs systemd service (next step):  
`$ /home/admin/electrs/target/release/electrs --index-batch-size=10 --jsonrpc-import --db-dir /mnt/hdd/electrs/db  --electrum-rpc-addr="0.0.0.0:50001" --cookie="raspibolt:PASSWORD_B" -vvvv`

---


## RaspiBlitz: Set up the Electrs systemd service

Set up the systemd service to run electrs continuously in the background.

Take a look: [2_electrs_systemd_service.sh](2_electrs_systemd_service.sh)

To download and run:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/2_electrs_systemd_service.sh && bash 2_electrs_systemd_service.sh`

If running the always-on electrs service is taking up too much RAM of your RPi3 stop it with:  
`$ sudo systemctl stop electrs`  
To stop running on boot:  
`$  sudo systemctl disable electrs`  
(To re-enable and start use the `enable` and `start`commands)  

---

## Check if Electrs is working:

Electrs will only start serving on the port 50001 when it has finished indexing.

To check if the indexing is running run in the RaspiBlitz terminal:  
`$ sudo systemctl status electrs`  

Example output when running afte indexing has finished:
![electrs status](/electrs/images/electrs_status.png)

Find electrs between running processes with:
`htop`

Cheack if it is serving on the port 50001:  
`$ lsof -i`

Look for the output:
```
electrs 2532 admin   17u  IPv4  32885      0t0  TCP *:50001 (LISTEN)
```


---

## Install Electrum wallet on your desktop

**Warning: Electrum versions older than 3.3.4 are susceptible to phishing. Do not download Electrum from another source than electrum.org, and learn to verify GPG signatures.**

Follow the instructions on https://electrum.org/#download

### Linux desktop: install, configure and run the Electrum wallet
The instruction are in the script: [4_electrum_install.sh](4_electrum_install.sh)  
Tested on Ubuntu 18.04.  
To download and run on the Linux desktop:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/4_electrum_install.sh && bash 4_electrum_install.sh`  




### Connect the Electrum wallet to Electrs:

For an unencrypted TCP connection (suitable inside a secure LAN):  
`electrum --oneserver --server RASPIBLITZ_IP:50001:t` 

To connect through SSL (requires setting up the Nginx server):  
`electrum --oneserver --server YOUR_DOMAIN:50002:s`

---

## Remote connection options to Electrs
Any communication outside a secure LAN must be encrypted.  

### Tor Hidden Service

The easiest option is to activate Tor on the RaspiBlitz +  on the computer used for Electrum and [configure a Tor Hidden Service for Electrs](Tor_Hidden_Service_for_Electrs.md)

### Reverse SSH tunnel
See the guide from @cryptomulde to connect to a VPS through a reverse ssh tunnel: https://medium.com/@cryptomulde/private-electrum-server-electrs-for-your-raspiblitz-full-node-without-forwarding-ports-417e4c3af975  

The more secure option is to continue with setting up the SSL connection as described in the next section.

### Nginx and Certbot to serve an SSL connection

For the SSL certificate to be obtained successfully a **dynamic DNS** and **port forwarding is necessary**.
Forward the port 80 to the IP of your RaspiBlitz for Certbot.  
Forward the port 50002 to be able to access electrs from the outside of your LAN (optional).

The script sets up the automatic start Nginx and Certbot.

Assumes that electrs is already installed.

Can be used as the secure backend of:

    Eclair Mobile Bitcoin and Ligthtning wallet
    Electrum wallet
    BitBox App

Take a look: [3_Nginx_and_Certbot_for_SSL.sh](3_Nginx_and_Certbot_for_SSL.sh)

To download and run on the RaspiBlitz:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/3_Nginx_and_Certbot_for_SSL.sh && bash 3_Nginx_and_Certbot_for_SSL.sh`

---

## Further help: 

The script is a collection of commands. The whole setup has multiple components and dependencies which can change when updated or modified by the maintainers.  

Based on:
* https://github.com/romanz/electrs/blob/master/doc/usage.md  
Shared experiences:
* https://github.com/rootzoll/raspiblitz/issues/123 
* https://github.com/openoms/bitcoin-tutorials/issues/2

If you run into problems:
*  try to run the commands manually one-by-one, spot which is causing the problem and copy the output
* open an issue here with the details and I will be happy to help to solve it  
* join the Community Raspiblitz Telegram group on https://t.me/raspiblitz 

Bear in mind that this guide and the parts used are free-opensource projects, you use them at your own responsibility and there are no guarantees of any kind.