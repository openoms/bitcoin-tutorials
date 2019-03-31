
### Connect the Zeus Lightning Wallet on Android to the RaspiBlitz over Tor

This guide is heavily based on: https://github.com/seth586/guides/blob/master/FreeNAS/wallets/zeusln.md.

Tested on the RaspiBlitz v1.1 with Tor installed already.

Have a look at the proposal of @seth586 about connecting light wallets through Tor: https://medium.com/@seth586/neutrino-can-be-dangerous-so-lets-grow-bitcoins-immunity-with-a-bip-bolt-2135956f147


Download the Zeus app, APKs available here: https://github.com/ZeusLN/zeus/releases, 
on Google Play and soon on F-Droid.

Log in to your RaspiBlitz through shh.

Edit `torrc` with `sudo nano /etc/tor/torrc` and add the following lines (`myandroid` can be unique):
```
HiddenServiceDir /mnt/hdd/tor/lnd_api/
HiddenServiceVersion 2
HiddenServiceAuthorizeClient stealth myandroid
HiddenServicePort 8080 127.0.0.1:8080
HiddenServicePort 10009 127.0.0.1:10009
```
Save (Ctrl+O, ENTER) and exit (Ctrl+X)

Restart Tor 
```
$ sudo systemctl restart tor
```

View the private credentials of your new hidden service. The first part is the onion address, the second part is the secret.
```
$ sudo cat /mnt/hdd/tor/lnd_api/hostname
z1234567890abc.onion AbyZXCfghtG+E0r84y/nR # client: myandroid
```

Download Orbot for Android. https://guardianproject.info/apps/orbot/

Open orbot. Click the `⋮`, select `hidden services ˃`, select `Client cookies`.

Press the + button on the lower right. Type in the the onion address and secret cookie you revealed with `sudo cat /mnt/hdd/tor/lnd_api/hostname`.

Go back to orbot's main screen, and select the gear icon under `tor enabled apps`. Add `Zeus`, then press back. Click `stop` on the big onion logo. Exit orbot and reopen it. Turn on `VPN Mode`. Start your connection to the tor network by clicking on the big onion (if it has not automatically connected already)


make sure go is installed (should be v1.11 or higher) :  
`$ go version` 

if need to install Go run:

```
$ wget https://storage.googleapis.com/golang/go${goVersion}.linux-armv6l.tar.gz
$ sudo tar -C /usr/local -xzf go${goVersion}.linux-armv6l.tar.gz
$ sudo rm *.gz
$ sudo mkdir /usr/local/gocode
$ sudo chmod 777 /usr/local/gocode
```

Download and compile [lndconnect](https://github.com/LN-Zap/lndconnect):
```
$ cd ~
$ go get -d github.com/LN-Zap/lndconnect
$ cd ~/go/src/github.com/LN-Zap/lndconnect
$ make install
```
Generate the LND connect URI QR code:  
```
$ cd ~/go/bin
$ ./lndconnect --lnddir=/home/admin/.lnd --image --host=z1234567890abc.onion --port=8080
```
The file `lndconnect-qr.png` will be generated.   
  
In a Linux terminal run:  
`$ scp admin@[YOUR.RASIBLITZ.IP]:~/go/bin/lndconnect-qr.png ~/`  
and open the png from your home directory.  

On Windows use WinSCP to download the image to your PC and open it.

Scan the QR Code with the ZeusLN app to be connected to your node through Tor!
