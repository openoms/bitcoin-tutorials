## Install the Electrum Server in Rust (electrs) on the RaspiBlitz
Based on https://github.com/romanz/electrs/blob/master/doc/usage.md 

Tested on the
* Odroid HC1 and XU4 (~18 hours)
* Raspberry Pi 3 B+ (very long time to build the database from scratch)

On an Odroid HC1 with SSD it takes ~40 minutes to build the code from source.
Building the electrs database (need to be done once) takes ~18 hours and requires ~50 Gb diskpace.

Possible, but not recommended to use on a computer with less than 2 Gb RAM.

The install instructions adapted to the RaspiBlitz are in this script, take a look: https://github.com/openoms/bitcoin-tutorials/blob/master/electrs/electrs_install_on_RaspiBlitz.sh

Download this script to your RaspiBlitz:  
`wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrs_install_on_RaspiBlitz.sh`  
make it executable:  
`sudo chmod +x electrs_install_on_RaspiBlitz.sh`  
and run:  
`./electrs_install_on_RaspiBlitz.sh`

---

## Install, configure and run the Electrum wallet on your Linux desktop
The instruction are in this script: https://github.com/openoms/bitcoin-tutorials/blob/master/electrs/electrum_install_config_and_run.sh

Download this script to your linux desktop:  
`wget https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/electrs/electrum_install_config_and_run.sh`  
make it executable:  
`sudo chmod +x electrum_install_config_and_run.sh`  
and run:  
`./electrum_install_config_and_run.sh`

