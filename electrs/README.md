## Install the Electrum Server in Rust (electrs) on the RaspiBlitz
Based on https://github.com/romanz/electrs/blob/master/doc/usage.md
Some shared experiences here: https://github.com/rootzoll/raspiblitz/issues/123

Tested on the
* Odroid HC1 and XU4 (~18 hours)
* Raspberry Pi 3 B+ (~ two days to build the database from scratch)

Requires 47 Gb diskpace (March 2019).

The install instructions adapted to the RaspiBlitz are in this script, take a look: [electrs_install_on_RaspiBlitz.sh](electrs_install_on_RaspiBlitz.sh)

Download this script to your RaspiBlitz, make it executable and run:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrs_install_on_RaspiBlitz.sh && sudo chmod +x electrs_install_on_RaspiBlitz.sh && ./electrs_install_on_RaspiBlitz.sh`  

---

## Set up the Electrum Server in Rust on the RaspiBlitz to be used with Eclair
Sets up the automatic start of electrs and nginx and certbot.

Take a look: [electrs_automation_for_Eclair.sh](electrs_automation_for_Eclair.sh)

To download this script, make executable and run:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrs_automation_for_Eclair.sh && sudo chmod +x electrs_automation_for_Eclair.sh && ./electrs_automation_for_Eclair.sh`

For the certificate to be obtained successfully a dynamic DNS and port forwarding is needed
Need to forward port 80 to the IP of your RaspiBlitz for certbot
Forward port 50002 to be able to access you electrs from outside of your LAN

---

## Install, configure and run the Electrum wallet on your Linux desktop
The instruction are in the script: [electrum_install_config_and_run.sh](electrum_install_config_and_run.sh)

Download this script to your linux desktop, make it executable and run:  
`$ wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrum_install_config_and_run.sh && sudo chmod +x electrum_install_config_and_run.sh && ./electrum_install_config_and_run.sh`  

