## Create a Tor Hidden Service
A simple example of creating and using a Tor Hidden Service.

Using ThunderHub as an example, use anyother name to be change the directory name.

* Install Tor:
```
$ sudo apt install tor
```
* Edit the config file:
```
$ sudo nano /etc/tor/torrc
```
* add for a v3 onion address:  
```
HiddenServiceDir /var/lib/tor/thunderhub/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:3010
```
* add for a v2 onion address:  
```
HiddenServiceDir /var/lib/tor/thunderhub/
HiddenServiceVersion 2
HiddenServicePort 80 127.0.0.1:3010
```
* restart Tor:
```
sudo systemctl restart tor
```
* list the files in the directory
```
$ sudo ls -la /var/lib/tor/thunderhub/
total 12
drwx------ 1 debian-tor debian-tor 136 Jan 30 07:09 .
drwx------ 1 debian-tor debian-tor 826 Jan 31 00:00 ..
drwx------ 1 debian-tor debian-tor   0 Feb 11  2020 authorized_clients
-rw------- 1 debian-tor debian-tor  63 Jan 30 07:09 hostname
-rwx------ 1 debian-tor debian-tor  64 Feb 11  2020 hs_ed25519_public_key
-rwx------ 1 debian-tor debian-tor  96 Feb 11  2020 hs_ed25519_secret_key
```
* note the Hidden Service address:
```
sudo cat /var/lib/tor/thunderhub/hostname
```
* Connect over the Tor Browser.



#### Notes:
The SSL stripping attack is not applicable when the traffic does not leave the Tor network so usinga  self-hosted Hidden Service in the Tor Browser is not at risk. 

Always make sure that the clearnet site you open in the Tor Browser uses SSL encryption (HTTPS).
