## Connect Zap over Tor to the RaspiBlitz
Confirmed to work with the mainnet Zap version >0.4.075.3 on iOS TestFlight

### Create the Hidden Service:
* In the RaspiBlitz terminal:  
`sudo nano /etc/tor/torrc`

* paste on the end of the file
    ```
    HiddenServiceDir /mnt/hdd/tor/lnd_REST/
    HiddenServiceVersion 3
    HiddenServicePort 8080 127.0.0.1:8080
    ```
    If you want to you a different port:
    ```
    HiddenServicePort THIS_CAN_BE_ANY_PORT 127.0.0.1:8080
    ```
* Take note of the .onion address into a word processor (like notepad)  
`sudo cat /mnt/hdd/tor/lnd_REST/hostname`

### Install lndconnect 

* Can install from the RaspiBlitz MOBILE menu by attempting to connect Zap in the traditional way.

* For Raspiblitz 1.3 add Go to the PATH by pasting this to the terminal (even if Go is installed already):
    ```
    export GOROOT=/usr/local/go
    export PATH=$PATH:$GOROOT/bin
    export GOPATH=/usr/local/gocode
    export PATH=$PATH:$GOPATH/bin
    sudo bash -c "echo 'PATH=\$PATH:/usr/local/gocode/bin/' >> /etc/profile"
    ```

* Alternatively install Go and lndconnect manually:
    ```
    # check if  Go is installed (should be v1.11 or higher):  
    go version 
    # If need to install Go, run these:
    wget https://storage.googleapis.com/golang/go1.13.linux-armv6l.tar.gz
    sudo tar -C /usr/local -xzf go1.11.linux-armv6l.tar.gz
    sudo rm *.gz
    sudo mkdir /usr/local/gocode
    sudo chmod 777 /usr/local/gocode
    export GOROOT=/usr/local/go
    export PATH=$PATH:$GOROOT/bin
    export GOPATH=/usr/local/gocode
    export PATH=$PATH:$GOPATH/bin

    # Install lndconnect:
    cd /tmp
    wget https://github.com/LN-Zap/lndconnect/releases/download/v0.1.0/lndconnect-linux-armv7-v0.1.0.tar.gz
    sudo tar -xvf lndconnect-linux-armv7-v0.1.0.tar.gz --strip=1 -C /usr/local/bin
    ```

### Generate the lndconnect string
* Run lndconnect with the -j option to display the text string:  
`lndconnect -j`

* Edit the string in a word processor:
    * change the IP address to the .onion address noted previously  
    * change the port 10009 to 8080 (or your custom port set in the torrc)
    * delete the part startig with `cert=` until the `macaroon=` entry

    * ends up in the format:

    ```
    lndconnect://YOUR_HIDDEN_SERVICE_ADDRESS.onion:8080?macaroon=<base64adminmacaroon>
    ```

### Connect Zap through Tor
* Share the string to your phone in an encrypted chat message to yourself (for example).

* Paste the string into the Tor enabled Zap 
* Enjoy your private and encrypted remote connection!

<p align="center">
<img src="images/zap_on_tor.jpg" alt="drawing" width="350/>
</p>