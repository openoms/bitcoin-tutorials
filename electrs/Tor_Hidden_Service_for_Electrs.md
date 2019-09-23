## Configure a Tor Hidden Service for Electrs

Tor needs to be active on the RaspiBlitz to use this method.  
No port forwarding or dynamicDNS required.

### Activate the Hidden Service in  the RaspiBlitz terminal 

* Open the Tor configuration file:  
`$ sudo nano /etc/tor/torrc`

* Insert the lines:
    ```
    # Hidden Service for Electrum Server
    HiddenServiceDir /mnt/hdd/tor/electrs
    HiddenServiceVersion 3
    HiddenServicePort 50001 127.0.0.1:50001
    ```
* Restart Tor:   
`$ sudo systemctl restart tor`  
`$ sudo systemctl restart tor@default` 

* Take note of the Tor address:  
`$ sudo cat /mnt/hdd/tor/electrs/hostname`

## Connect the Electrum wallet
### On a Linux PC

Consider using an USB bootable [Tails](https://tails.boum.org/) - a Linux based operating system which runs all communication through Tor and has the Electrum wallet built in.

* Start electrum with the Tor Browser open (proxy on port 9150):  
`$ electrum --oneserver --server Tor_address.onion:50001:t --proxy socks5:127.0.0.1:9150`

* With Tor installed and running (proxy on port 9050):   
`$ electrum --oneserver --server Tor_address.onion:50001:t --proxy socks5:127.0.0.1:9050`

### Windows instructions:  
http://docs.electrum.org/en/latest/tor.html#windows 

---

Check for the blue dot when finished:

![electrum behind Tor](/electrs/images/electrum_tor.png)


## Based on:  
https://github.com/romanz/electrs/blob/master/doc/usage.md#tor-hidden-service