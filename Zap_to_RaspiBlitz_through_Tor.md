## Connect Zap over Tor to the RaspiBlitz
Confirmed to work with the mainnet Zap version >0.4.075.3 on iOS TestFlight

### Create the Hidden Service:
* In the RaspiBlitz terminal:  

    `$ sudo nano /etc/tor/torrc`

* paste on the end of the file
    ```
    HiddenServiceDir /mnt/hdd/tor/lnd_REST/
    HiddenServiceVersion 3
    HiddenServicePort 8080 127.0.0.1:8080
    ```

    Save (Ctrl+O, ENTER) and exit (Ctrl+X)

    If you want to use a different port:
    ```
    HiddenServicePort THIS_CAN_BE_ANY_PORT 127.0.0.1:8080
    ```

* Restart Tor:  

    `$ sudo systemctl restart tor`
    
* Take note of the .onion address into a word processor (like notepad)

    `$ sudo cat /mnt/hdd/tor/lnd_REST/hostname`

### Install lndconnect 

* Install Go and lndconnect manually:

    ```
    # check if  Go is installed (should be v1.11 or higher):  
    go version 
    # If need to install Go, run these:
    wget https://storage.googleapis.com/golang/go1.13.linux-armv6l.tar.gz
    sudo tar -C /usr/local -xzf go1.13.linux-armv6l.tar.gz
    sudo rm *.gz
    sudo mkdir /usr/local/gocode
    sudo chmod 777 /usr/local/gocode
    export GOROOT=/usr/local/go
    export PATH=$PATH:$GOROOT/bin
    export GOPATH=/usr/local/gocode
    export PATH=$PATH:$GOPATH/bin

    # Install lndconnect:
    go get -d github.com/LN-Zap/lndconnect
    cd $GOPATH/src/github.com/LN-Zap/lndconnect
    make
    ```

### Generate the lndconnect string
* Run lndconnect with the .onion address filled in:  
`lndconnect --host=HIDDEN_SERVICE_ADDRESS.onion --port=8080 --nocert`

* Alternatively run lndconnect with the -j option to display the text string:  
`lndconnect --host=HIDDEN_SERVICE_ADDRESS.onion --port=8080 --nocert -j`

    * The correct string format is:
    ```
    lndconnect://YOUR_HIDDEN_SERVICE_ADDRESS.onion:8080?macaroon=<base64adminmacaroon>
    ```

### Connect Zap through Tor
* Scan the QR code with your Tor enabled Zap  

    or
* Share the string to your phone in an encrypted chat message to yourself and paste the string into Zap 

* Enjoy your private and encrypted remote connection!

<div style="text-align:center"><img src="images/zap_on_tor.jpg" width="350//></div>