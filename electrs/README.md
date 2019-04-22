## RaspiBlitz: install the Electrum Server in Rust (electrs)
Based on https://github.com/romanz/electrs/blob/master/doc/usage.md  
Shared experiences here: https://github.com/rootzoll/raspiblitz/issues/123 and https://github.com/openoms/bitcoin-tutorials/issues/2


\`The server indexes the entire Bitcoin blockchain, and the resulting index enables fast queries for any given user wallet, allowing the user to keep real-time track of his balances and his transaction history using the Electrum wallet. Since it runs on the user's own machine, there is no need for the wallet to communicate with external Electrum servers, thus preserving the privacy of the user's addresses and balances.\` - [https:/github.com/romanz/electrs](https:/github.com/romanz/electrs)

Tested on the
* Odroid HC1 and XU4 (~18 hours)
* Raspberry Pi 3 B+ (~ two days to build the database from scratch)

Requires 47 Gb diskpace (March 2019).

The install instructions adapted to the RaspiBlitz are in this script, take a look: [1_electrs_on_RaspiBlitz.sh](1_electrs_on_RaspiBlitz.sh)

To download and run on the RaspiBlitz::  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/1_electrs_on_RaspiBlitz.sh && bash 1_electrs_on_RaspiBlitz.sh`  

This will only run the server until the terminal window is open.  
To restart electrs manually run (with your PASSWORD_B filled in):  
`$ /home/admin/electrs/target/release/electrs --index-batch-size=10 --jsonrpc-import --db-dir /mnt/hdd/electrs/db  --electrum-rpc-addr="0.0.0.0:50001" --cookie="raspibolt:PASSWORD_B"`

---
## RaspiBlitz: Set up the Electrs systemd service

Set up the systemd service to run electrs continuously in the background.

Take a look: [2_electrs_systemd_service.sh](2_electrs_systemd_service.sh)

To download and run:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/2_electrs_systemd_service.sh && bash 2_electrs_systemd_service.sh`

If running the always-on electrs service is too much for your RPi stop it with:  
`$ sudo systemctl stop electrs`  
To stop running on boot:  
`$  sudo systemctl disable electrs`  
(To re-enable and start use the `enable`  and  `start`commands)

## RaspiBlitz: install Nginx and Certbot to connect over SSL 

For the SSL certificate to be obtained successfully a **dynamic DNS** and **port forwarding is necessary**.
Forward the port 80 to the IP of your RaspiBlitz for Certbot.  
Forward the port 50002 to be able to access electrs from the outside of your LAN (optional).

The script sets up the automatic start Nginx and Certbot.

Assumes that electrs is already installed.

Can be used as a secure backend of:

    Eclair Mobile Bitcoin and Ligthtning wallet
    Electrum wallet

Take a look: [3_Nginx_and_Certbot_for_SSL.sh](3_Nginx_and_Certbot_for_SSL.sh)

To download and run on the RaspiBlitz:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/3_Nginx_and_Certbot_for_SSL.sh && bash 3_Nginx_and_Certbot_for_SSL.sh`

---

## Linux desktop: install, configure and run the Electrum wallet
The instruction are in the script: [4_electrum_install.sh](4_electrum_install.sh)

Tested on Ubuntu 18.04.

To download and run on the Linux desktop:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/4_electrum_install.sh && bash 4_electrum_install.sh`  

