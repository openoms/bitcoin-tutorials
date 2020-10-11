## Create a Tor Hidden Service
A simple example of creating and using a Tor Hidden Service.

Using ThunderHub as an example.

* Install Tor:
```
$ sudo apt install tor
```
* Edit the config file:
```
$ sudo nano /etc/tor/torrc
```
* add:  
```
HiddenServiceDir /var/lib/tor/thunderhub/
HiddenServicePort 80 127.0.0.1:3010
```
* restart Tor:
```
sudo systemctl restart tor
```

* note the Hidden Service address:
```
sudo cat /var/lib/tor/thunderhub/hostname
```
* Connect over the Tor Browser.



#### Notes:
The SSL stripping attack is not applicable when the traffic does not leave the Tor network so usinga  self-hosted Hidden Service in the Tor Browser is not at risk. 

Always make sure that the clearnet site you open in the Tor Browser uses SSL encryption (HTTPS).