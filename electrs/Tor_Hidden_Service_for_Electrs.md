## Configure a Tor Hidden Service for Electrs

Tor needs to be active on the RaspiBlitz to use this method.  
No port forwarding or dynamicDNS required.

### On the RaspiBlitz terminal: 

* Open the Tor configuration file:  
`$ sudo nano /mnt/hdd/tor/torrc`

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

## On a Linux PC:

* Start electrum with the Tor Browser open (proxy on port 9150):  
`$ electrum --oneserver --server Tor_address.onion:50001:t --proxy socks5:127.0.0.1:9150`

* With Tor installed and running (proxy on port 9050):   
`$ electrum --oneserver --server Tor_address.onion:50001:t --proxy socks5:127.0.0.1:9050`

## Windows instructions:  
http://docs.electrum.org/en/latest/tor.html#windows 



## Based on:  
https://github.com/romanz/electrs/blob/master/doc/usage.md#tor-hidden-service