<p align="left">
  <img width="100" src="../images/joinmarket_logo.png">
</p>

# Connect JoinMarket running on a Linux desktop to a remote node

In order to use the JoinMarketQT GUI (and other scripts) it needs to connect to a Bitcoin Core node.  
A pruned node with the wallet enabled will do and txindex is not required.

In this guide will show how to connect to a RaspiBlitz.

The benefit is that there is no need to run another Bitcoin node on the desktop and still can use the JoinMarket-QT GUI and other scripts.

Tested with:
* Joinmarket 0.6.1
* Ubuntu 18.04 desktop
* RaspiBlitz 1.3 and 1.4

## LAN connection

### In the node terminal

* Activate the Bitcoin Core wallet of the RaspiBlitz:  
    `$ /home/admin/config.scripts/network.wallet.sh on`

#### Allow remote RPC connections on the LAN
This can be skipped if you connect through Tor (see [below](#tor-connection))

1) #### Edit the bitcoin.conf:  
    `$ sudo nano /mnt/hdd/bitcoin/bitcoin.conf`

    Add the values:  
    * `rpcallowip=JOINMARKET_IP` or `RANGE` 
      * either specify the LAN IP of the computer with JoinMarket
      * or use a range like: `192.168.1.0/24` - edit to your local subnet - the first 3 numbes of the LAN IP address, the example used here is: 192.168.1.x  
    * `rpcbind=LAN_IP_OF_THE_NODE` 
      * use the local IP of the bitcoin node in the example: `192.168.1.4`
    * can keep the other `rpcallowip` and `rpcbind` entires especially for the localhost: `127.0.0.1`

    Example: 
    ```bash
    rpcallowip=192.168.1.0/24
    rpcbind=192.168.1.4
    ```
2) #### Restart Bitcoin Core:  
    `$ sudo systemctl restart bitcoind`

3) #### The firewall needs to be opened to allow the RPC connection from LAN
    (edit to your local subnet):  
    `sudo ufw allow from 192.168.1.0/24 to any port 8332`  
    `ufw enable`

### On the Linux desktop

1) #### Install Joinmarket from the source code:  

    ```bash
    git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git
    cd joinmarket-clientserver
    # latest release: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases
    git reset --hard v0.7.0

    ./install.sh --with-qt
    ```

2) #### Activate the python virtual environment:  
    `$ source jmvenv/bin/activate`

3) #### Start the JoinMarket-QT GUI (or an other script) to generate the config file.  
    `(jmvenv) $ cd scripts`  
    `(jmvenv) $ python joinmarket-qt.py`

4) #### Edit the joinmarket.cfg:  
    `$ nano ~/.joinmarket/joinmarket.cfg` 

    Fill in the values which are in CAPITALs:

    ```
    [BLOCKCHAIN]
    #options: bitcoin-rpc, regtest
    blockchain_source = bitcoin-rpc
    network = mainnet
    rpc_host = LAN_IP_OF_THE_REMOTE_NODE
    rpc_port = 8332
    rpc_user = RPC_USERNAME_OF_THE_REMOTE_NODE (AS IN BITCOIN.CONF)
    rpc_password = RPC_PASSWORD_OF_THE_REMOTE_NODE (AS IN BITCOIN.CONF)
    ```

5) #### Copy, generate or restore a JoinMarket wallet  
    
    If you want use the wallet used on your node already copy it over with scp (fill in the parts written in CAPITALs):  
    ```
    $ scp admin@REMOTE_NODE_IP:~/.joimarket/wallets/WALLET.jmdat ~/.joimarket/wallets/
    ```  
    You can use the `Wallet` menu of JoinMarketQT to generate or restore a wallet.

5) #### Start the JoinMarket-QT GUI (or an other script) with:  
    `(jmvenv) $ python joinmarket-qt.py`

## Tor connection

### On the node - activate Tor and create a Hidden Service
#### Create a Hidden Service to forward the bitcoin RPC port

* On a RaspiBlitz you can use the built-in script:  
    `$ /home/admin/config.scripts/internet.hiddenservice.sh bitcoinrpc 8332 8332`

1) #### Open the Tor configuration file:  
    `$ sudo nano /etc/tor/torrc`

2) #### Insert the lines:
    ```bash
    # Hidden Service v3 for bitcoinrpc
    HiddenServiceDir /mnt/hdd/tor/bitcoinrpc
    HiddenServiceVersion 3
    HiddenServicePort 8332 127.0.0.1:8332
    ```
3) #### Restart Tor:   
    `$ sudo systemctl restart tor` 

4) #### Take note of the Tor Hidden Service address:  
    `$ sudo cat /mnt/hdd/tor/bitcoinrpc/hostname`

### On the Linux desktop - use `torify`

1) #### Install JoinMarket and copy, generate or restore a JoinMarket wallet as decribed [above](#copy-generate-or-restore-a-JoinMarket-wallet) for the LAN connection.

2) #### Install Tor (if not running already):  
    `$ sudo apt update`  
    `$ sudo apt install tor`

3) #### Edit the joinmarket.cfg:  
    `$ nano ./scripts/joinmarket.cfg` 

    Fill in the values in CAPITALs:

    ```
    [BLOCKCHAIN]
    #options: bitcoin-rpc, regtest
    blockchain_source = bitcoin-rpc
    network = mainnet
    rpc_host = HIDDEN_SERVICE_ADDRESS_FOR_BITCOINRPC.onion
    rpc_port = 8332
    rpc_user = RPC_USERNAME_OF_THE_REMOTE_NODE (AS IN BITCOIN.CONF)
    rpc_password = RPC_PASSWORD_OF_THE_REMOTE_NODE (AS IN BITCOIN.CONF)
    ```
* To make JoinMarket communicate through Tor to the peers comment out the clearnet communication channels (place a `#` on the front of the line - means it won`t be used by the script):

    ```
    #host = irc.cyberguerrilla.org

    ...

    [MESSAGING:server2]
    #host = irc.darkscience.net
    ```
* Uncomment (remove the `#` from front of) the entries related to Tor:
    ```
    ...
    [MESSAGING:server1]
    ...
    #for tor
    host = darksci3bfoka7tw.onion
    socks5 = true
    ...
    [MESSAGING:server2]
    ...
    #for tor
    host = ncwkrwxpq2ikcngxq3dy2xctuheniggtqeibvgofixpzvrwpa77tozqd.onion
    port = 6667
    usessl = false
    socks5 = true
    ```

4) ####  activate the python virtual environment:  
    `$ source jmvenv/bin/activate`

5) #### Start the JoinMarket-QT GUI (or other scripts) with:  
    `(jmvenv) $ cd scripts`  
    `(jmvenv) $ torify python joinmarket-qt.py`

## JoinMarket-QT icon/shortcut on the Linux desktop

The following instructions by @k3tan172 will create an icon for easy access.
Tested on Ubuntu.

1) #### Create an environment script

    ```$ sudo nano ~/joinmarket.sh```

    In the blank file, copy the following:

    ```
    #!/bin/bash

    cd ~/joinmarket-clientserver && source jmvenv/bin/activate && cd scripts
    python joinmarket-qt.py
    ```

    Save the file and make it executable by running the following command:

    ```$ sudo chmod a+x ~/joinmarket.sh```

2) #### Download the icon and place it into the pixmaps folder:

    ``` 
    $ sudo wget -P /usr/share/pixmaps https://raw.githubusercontent.com/openoms/bitcoin-tutorials/master/images/joinmarket_logo.png
    ```

3) #### Create desktop file

    ```$ sudo nano ~/JoinMarket.desktop```

    In the blank file, copy the following:

    ```
    !/usr/bin/env xdg-open
    [Desktop Entry]
    Version=1.0
    Type=Application
    Terminal=false
    Name[en_AU]=JoinMarket
    Exec=/home/$USER/joinmarket.sh
    Name=JoinMarket
    Icon=joinmarket_logo
    ```

    Update the ```Exec=``` line with your username

4) #### Install the desktop file

    ```$ sudo desktop-file-install ~/JoinMarket.desktop```

    Open up Applications and search for JoinMarket - test to see if it works.

---

## Resources:

* Walkthrough for running Joinmarket-Qt to do coinjoins (single or tumbler):  
<https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/JOINMARKET-QT-GUIDE.md>

* [JoinMarket on the RaspiBlitz guide](README.md)

* Video demonstration of using the JoinMarket-Qt GUI by @AdamISZ:  
<https://youtu.be/hwmvZVQ4C4M>

* Video about how to setup and use JoinMarket on the Ubuntu Node Box by @k3tan172:  
<https://www.youtube.com/watch?v=zTCC86IUzWo>
