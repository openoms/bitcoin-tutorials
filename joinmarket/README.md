<p align="left">
  <img width="150"  src="../images/RaspiBlitz_Logo_Berry.png">
  <img width="100" >
  <img width="100" src="../images/joinmarket_logo.png">

</p>

## JoinMarket on the RaspiBlitz
A long standing coinjoin implementation with decentralised coordination and incentive structure.

Tested on:
* RPi4 4GB with RaspiBlitz v1.3
* Odroid HC1 with RaspiBlitz v1.3

Check the current offers in the order book: https://joinmarket.me/ob/  

One can coinjoin any amount within the offer limits by default with 5-7 random participants at a time. The taker fees are maximised, then the offers within the limits are randomly chosen to participate. Most parameters can be easily customized.

See this review thread about the GUI option: https://twitter.com/zndtoshi/status/1191799199119134720

### Prerequisite

Activate the wallet of bitcoind
* Edit the bitcoin.conf:  
`$ sudo nano /mnt/hdd/bitcoin/bitcoin.conf`
    
* Change the disablewallet option to 0:
    ```
    disablewallet=0
    ```
* Restart bitcoind:  
`$ sudo systemctl restart bitcoind`

### Installation

* Run in the RaspiBlitz terminal:

    ```
    git clone https://github.com/JoinMarket-Org/joinmarket-clientserver.git
    cd joinmarket-clientserver
    # latest release: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases
    git reset --hard v0.6.1
    ./install.sh --without-qt
    ```

* Activate the virtual environment to see the prompt: `(jmvenv) $`  
This needs to be done at every new login.

    ```
    $ cd joinmarket-clientserver
    $ source jmvenv/bin/activate
    $ cd scripts
    ```
    **Hint:** the commands can be run as one line if joined by `&&`
    (meaning continue to run if successful):

    ```
    $ cd joinmarket-clientserver && source jmvenv/bin/activate && cd scripts
    ```
    The previously run commands can be easly searched from the prompt by pressing
    `CTRL+R` thanks to the [command line fuzzy finder](https://github.com/junegunn/fzf)
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
    ```
    Press `CTRL+O` and `ENTER` to save and `CRTL+X` to exit.
* Run again to generate the wallet after setting up the `joinmarket.cfg`

    `(jmvenv) $ python wallet-tool.py generate`  

* Display the addresses to fund (look in mixdepth 0):  

    `(jmvenv) $ python wallet-tool.py wallet.jmdat`  
    
    Will display after the first run:
    
    ```
    [INFO]  Detected new wallet, performing initial import
    restart Bitcoin Core with -rescan or use `bitcoin-cli rescanblockchain` if you're recovering an existing wallet from backup seed
    Otherwise just restart this joinmarket application.
    ```
    
    Run again after the first time to see the addresses:
    
    `(jmvenv) $ python wallet-tool.py wallet.jmdat`  

### Send payments with a coinjoin with the `sendpayment.py`

* Described in: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/USAGE.md#try-out-a-coinjoin-using-sendpaymentpy

* See the walkthrough for the JoinMarket-Qt GUI to send payments with coinjoin or run multiple coinjoins (**tumbler**): <https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/JOINMARKET-QT-GUIDE.md>

* Video demonstration of using the JoinMarket-Qt GUI: <https://youtu.be/hwmvZVQ4C4M>

### Run a Yield Generator
* Read the basics: https://github.com/JoinMarket-Org/joinmarket/wiki/Running-a-Yield-Generator  

* Edit the settings:  
    `$ nano yg-privacyenhanced.py`

    ```
    """THESE SETTINGS CAN SIMPLY BE EDITED BY HAND IN THIS FILE:
    """
    
    ordertype = 'swreloffer'  # [string, 'swreloffer' or 'swabsoffer'] / which fee type to actually use
    cjfee_a = 500             # [satoshis, any integer] / absolute offer fee you wish to receive for coinjoins (cj)
    cjfee_r = '0.00003'       # [percent, any str between 0-1] / relative offer fee you wish to receive based on a cj's amount
    cjfee_factor = 0.1        # [percent, 0-1] / variance around the average fee. Ex: 200 fee, 0.2 var = fee is btw 160-240
    txfee = 000               # [satoshis, any integer] / the average transaction fee you're adding to coinjoin transactions
    txfee_factor = 0.3        # [percent, 0-1] / variance around the average fee. Ex: 1000 fee, 0.2 var = fee is btw 800-1200
    minsize = 500000         # [satoshis, any integer] / minimum size of your cj offer. Lower cj amounts will be disregarded
    size_factor = 0.1         # [percent, 0-1] / variance around all offer sizes. Ex: 500k minsize, 0.1 var = 450k-550k
    gaplimit = 6

    # end of settings customization
    ```
    * `ordertype` sets either a relative (`swreloffer`) or an absolute (`swabsoffer`) coinjoin fee model
    * `cjfee_a` is the fixed coinjoin fee to be earned when using `swabsoffer`
    * `cjfee_r` is the relative fee when using `swreloffer`. Specified as the fraction of the used amount.
    * `txfee` is the maker's contribution to the miner fees (still paid by the taker). To reduce the minimum offer amount for `swreloffer` set it to 0.    
    * `minsize` specifies the minimum offer size in satoshis (this is the minimum size the UTXO will end up to be after participating in coinjoin)


* Once set up run:

    `(jmvenv) $ python yg-privacyenhanced.py wallet.jmdat`

### Check the transaction history

* use the wallet tool:  
    `(jmvenv) $ python wallet-tool.py wallet.jmdat history`

    add `-v 4` to the end of the command for a more detailed list.

* View the log of the transactions of the Yield Generator:  
    `$ cat ~/joinmarket-clientserver/scripts/logs/yigen-statement.csv`
    

* Display as a table in the terminal:  
    `$ column -s, -t < ~/joinmarket-clientserver/scripts/logs/yigen-statement.csv | less -#2 -N -S`  
    press `q` to exit

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

### Make JoinMarket communicate on Tor

* Activate Tor in the SERVICE menu of the RaspiBlitz if not running already
* Edit the joinmarket.cfg:  
    `$ nano joinmarket.cfg` 
* Comment out the clearnet communication channels (place a `#` on the front of the line - means it won`t be used by the script):

    ```
    [MESSAGING:server1]
    #host = irc.cyberguerrilla.org

    ...

    [MESSAGING:server2]
    #host = irc.darkscience.net
    ```
* Uncomment (remove the `#` from front of) the entries related to Tor:
    ```
    #for tor
    host = epynixtbonxn4odv34z4eqnlamnpuwfz6uwmsamcqd62si7cbix5hqad.onion
    socks5 = true
    
    ...

    #for tor
    host = darksci3bfoka7tw.onion
    socks5 = true
    ```

### Resources:
* Latest codebase:  
<https://github.com/JoinMarket-Org/joinmarket-clientserver>

* Installation instructions:  
<https://github.com/JoinMarket-Org/joinmarket-clientserver#quickstart---recommended-installation-method-linux-only>

* Discuss JoinMarket usage on the RaspiBlitz in  
<https://github.com/rootzoll/raspiblitz/issues/842>

* More links and info in 6102bitcoin/CoinJoin-Research:  
https://github.com/6102bitcoin/CoinJoin-Research/blob/master/CoinJoin_Implementations/11_JoinMarket-JoinMarket-Org/summary.md

* Check the guide for the RaspiBolt by @kristapsk:  
https://github.com/kristapsk/raspibolt-extras/blob/master/joinmarket.md

* Tmux  will be included in the next release of the RaspiBlitz:  
<https://github.com/rootzoll/raspiblitz/issues/793>
