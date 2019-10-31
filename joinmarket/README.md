## JoinMarket on the RaspiBlitz

Testing on a RPi4 4GB with RaspiBlitz v1.3

The current fees and available liquidity can be seen in the JoinMarket order book on https://joinmarket.me/ob/.  
When installed can also check:  
`$ python ~/joinmarket-clientserver/scripts/obwatch/ob-watcher.py `

### Prerequisite

* Need to activate the wallet of bitcoind
    
    `$ sudo nano /mnt/hdd/bitcoin/bitcoin.conf`
    
    ```
    disablewallet=0
    ```
    `$ sudo systemctl restart bitcoind`

### Installation

* Run in the RaspiBlitz terminal:

    ```bash
    $ git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git
    $ cd joinmarket-clientserver
    # latest release: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases
    $ git reset --hard v0.5.5
    $ ./install.sh
    # (follow instructions on screen; provide sudo password when prompted)
    # do not install QT-dependencies - running headless on the RPi
    ```

* Activate the virtual environment to see the prompt: `(jmvenv) $`  
This needs to be done at every new login.

    ```bash
    $ cd joinmarket-clientserver
    $ source jmvenv/bin/activate
    $ cd scripts
    ```

### Generate a wallet
* Using the JoinMarket wallet: https://github.com/JoinMarket-Org/joinmarket/wiki/Using-the-JoinMarket-internal-wallet

    `(jmvenv) $ python wallet-tool.py generate`  
    ```
    Created a new `joinmarket.cfg`. Please review and adopt the settings and restart joinmarket.
    ```
    * JoinMarket uses a hot wallet sitting on your Raspberry Pi. Keep it safe.
    * Backup your seed and store safely. Best to not keep the seed and the passphrase together.
    * The wallet encryption password will be needed every time when there is interaction with the wallet. Store it somewhere accessible, best if encrypted.

* Fill in the PasswordB to the `joinmarket.cfg`  
 (as in `/mnt/hdd/bitcoin/bitcoin.conf`)  

    `$ nano joinmarket.cfg`  

    ```
    [BLOCKCHAIN]
    rpc_user = raspibolt
    rpc_password = PasswordB-as-in-bitcoin.conf
    rpc_host = localhost #default usually correct 
    rpc_port = 8332 # default for mainnet
    ```
* Display the addresses to fund (look in mixdepth 0):  

    `(jmvenv) $ python wallet-tool.py wallet.jmdat`  

    and run again after the first time

### Send payments through coinjoins with `sendpayment.py`

* Described in: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/USAGE.md#try-out-a-coinjoin-using-sendpaymentpy

### Run a Yield Generator
* Read the basics: https://github.com/JoinMarket-Org/joinmarket/wiki/Running-a-Yield-Generator  

* Edit the settings:  
    `$ nano yield-generator-basic.py`

    ```
    """THESE SETTINGS CAN SIMPLY BE EDITED BY HAND IN THIS FILE:
    """
    txfee = 100
    cjfee_a = 500
    cjfee_r = '0.00002'
    ordertype = 'swreloffer' #'swreloffer' or 'swabsoffer'
    nickserv_password = ''
    max_minsize = 1000
    gaplimit = 6
    ```

    * `txfee` is the maker's contribution to the miner fees (still paid by the taker). To reduce the minimum offer amount for `swreloffer` set it to 0.
    * `cjfee_a` is the fixed coinjoin fee to be earned
    * `cjfee_r = '0.00002'` is the relative fee depending on the used amount
    * to use an absolute fee swap `swreloffer` to `swabsoffer`

* Once set up run: 

    `(jmvenv) $ python yield-generator-basic.py wallet.jmdat`

### Check the transaction history
* use the wallet tool:  
    `(jmvenv) $ python wallet-tool.py wallet.jmdat history`

* View the log of the transactions of the Yield Generator:  
    `$ cat ~/joinmarket-clientserver/scripts/logs/yigen-statement.csv`
* Monitor continously with:  
    `$ tail -f -n 100 ~/joinmarket-clientserver/scripts/logs/yigen-statement.csv`

### Keep the offers running in the background with [Tmux](https://github.com/tmux/tmux#welcome-to-tmux)

* Install on the RaspiBlitz:  
`$ sudo apt install tmux`
* Start:  
`$ tmux`
* Work in the terminal as described above.  
Find a basic introduction at https://www.ocf.berkeley.edu/~ckuehl/tmux/
* If the terminal is disconnected the processes in tmux keep running (as it is running on the Blitz) and can be returned to
* when logged in after a disconnection run:  
`$ tmux a`  
to pick up where left off

### Resources:
* Latest codebase: https://github.com/JoinMarket-Org/joinmarket-clientserver
* Installation instructions: https://github.com/JoinMarket-Org/joinmarket-clientserver#quickstart---recommended-installation-method-linux-only

* Video demonstration: https://youtu.be/hwmvZVQ4C4M

* Tmux  will be included in the next release of the RaspiBlitz: https://github.com/rootzoll/raspiblitz/issues/793

* Discuss JoinMarket usage on the RaspiBlitz in https://github.com/rootzoll/raspiblitz/issues/842
