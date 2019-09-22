## Install BTCPayServer on the RaspiBlitz

Run BTCPayServer on your RaspiBlitz using the already synced bitcoin blockchain and local LND node.
Benefit from the backup and security features of the RaspiBlitz and LND.  
No added synchronization needed. 

Requirements:
* a domain name or dynamic DNS
* the ports 80, 443 and 9735 forwarded on the router to the RaspiBlitz LAN IP

Tested successfully on:
* RaspiBlitz v1.3 
* RPi4 4GB (2GB RAM is sufficient)

### [Automated Script](/BTCPayServer/btcpay_to_blitz.sh)

To download and run:  
`wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/BTCPayServer/btcpay_to_blitz.sh && bash btcpay_to_blitz.sh`


* BTCpayServer, NBXplorer and the .NET Core is confined to the user `btcpay`.
* The BTCPay data and store settings are stored on the HDD `/mnt/hdd/.btcpayserver` and recoverable on a reinstall / SDcard update.
* Sets up a Tor Hidden Service if Tor is active

### Setting up BTCPayServer

* Go to your domain
* Register the first (administrator) account
* Create a Store
* In Store settings set up the derivation scheme (add an xpub from a secure/hardware wallet)
* Set up LN with the connection string:  
 `type=lnd-rest;server=https://127.0.0.1:8080/;macaroonfilepath=/home/btcpay/admin.macaroon;allowinsecure=true`

* Find more detailed info on https://docs.btcpayserver.org/btcpay-basics/gettingstarted

---

### Getting help

* see the original guide this is based on: https://gist.github.com/normandmickey/3f10fc077d15345fb469034e3697d0d0  

* Shared experiences: 
https://github.com/rootzoll/raspiblitz/issues/214

- if `Nginx` breaks:
`sudo nginx -t`
is a very useful debug tool. Runs a test and gets detailed info on which line is problematic.

* Join the BTCPay Server Community Chat on https://chat.btcpayserver.org/
