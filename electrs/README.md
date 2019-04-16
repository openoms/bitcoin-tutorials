## RaspiBlitz: install the Electrum Server in Rust (electrs)
Based on https://github.com/romanz/electrs/blob/master/doc/usage.md
Some shared experiences here: https://github.com/rootzoll/raspiblitz/issues/123

Tested on the
* Odroid HC1 and XU4 (~18 hours)
* Raspberry Pi 3 B+ (~ two days to build the database from scratch)

Requires 47 Gb diskpace (March 2019).

The install instructions adapted to the RaspiBlitz are in this script, take a look: [electrs_install_on_RaspiBlitz.sh](electrs_install_on_RaspiBlitz.sh)

To download and run on the RaspiBlitz::  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrs_install_on_RaspiBlitz.sh && bash electrs_install_on_RaspiBlitz.sh`  

---

## RaspiBlitz: Set up the Electrs systemd service and connect over SSL 

For the SSL certificate to be obtained successfully a **dynamic DNS** and **port forwarding is necessary**.

The script sets up the automatic start of electrs, Nginx and certbot.

Assumes that electrs was installed already with the [latter script](https://github.com/openoms/bitcoin-tutorials/blob/master/electrs/.README.md#raspiblitz-install-the-electrum-server-in-rust-electrs).

Can be used as a secure backend of:

    Eclair Mobile Bitcoin and Ligthtning wallet
    Electrum wallet

Take a look: [electrs_automation_for_Eclair.sh](electrs_automation_for_Eclair.sh)

To download and run on the RaspiBlitz:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrs_automation_for_Eclair.sh && bash electrs_automation_for_Eclair.sh`

For the certificate to be obtained successfully a **dynamic DNS** and **port forwarding is necessary**.  
Forward the port 80 to the IP of your RaspiBlitz for certbot.  
Forward the port 50002 to be able to access electrs from the outside of your LAN.

---

## Linux desktop: Install, configure and run the Electrum wallet
The instruction are in the script: [electrum_install_config_and_run.sh](electrum_install_config_and_run.sh)

To download and run on the Linux desktop:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrum_install_config_and_run.sh && bash electrum_install_config_and_run.sh`  

