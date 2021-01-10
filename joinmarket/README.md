<p align="left">
  <img width="100" src="../images/joinmarket_logo.png">
  <img width="100">
  <img width="150"  src="../images/RaspiBlitz_Logo_Berry.png">
</p>

## JoinMarket on the RaspiBlitz
A long standing coinjoin implementation with decentralised coordination and incentive structure.

Tested on:
* RPi4 4GB with RaspiBlitz v1.4
* Odroid HC1 with RaspiBlitz v1.3

Check the current offers in a public book: https://nixbitcoin.org/obwatcher/ or [run your own](#run-the-order-book-locally).

One can coinjoin any amount within the offer limits by default with 5-7 random participants at a time. The taker fees are maximised, then the offers within the limits are randomly chosen to participate. Most parameters can be easily customized.

### JoininBox
Check out the [JoininBox project](https://github.com/openoms/joininbox) for a terminal based menu and helper UI for JoinMarket. 
Running on the RaspiBlitz or remotely connected to a full node.

### Installation
Now you can use the automated install [script](https://github.com/rootzoll/raspiblitz/blob/v1.5/home.admin/config.scripts/bonus.joinmarket.sh) which will be the part of the RaspiBlitz v1.5 release and can be installed from the SERVICES menu.

What the script does:

* sets up a separate user: `joinmarket` with sudo access. Uses the PASSWORD_B as the user password
* the data directory is on the disk at `/mnt/hdd/app-data/.joinmarket`, symlinked to `/home/joinmarket/.joinmarket` and will be kept during the SD-card updates
* if joinmarket was set up already using a previous version of this tutorial the the wallet(s) will be copied to the new data directory automatically
* will be compatible with GUI being worked on here: https://github.com/openoms/joininbox

To install JoinMarket on RaspiBlitz v1.4 (earlier versions are not supported):

```
#download:
wget https://raw.githubusercontent.com/rootzoll/raspiblitz/v1.5/home.admin/config.scripts/bonus.joinmarket.sh
#run:
sudo bash bonus.joinmarket.sh on
```
Start by logging in with the `joinmarket` user:  
`sudo su - joinmarket`

* Can also [use the JoinMarket-QT GUI](https://github.com/openoms/bitcoin-tutorials/tree/master/joinmarket#joinmarketqt-gui-on-the-desktop) to generate a wallet.

### Generate a wallet
* Using the JoinMarket wallet: https://github.com/JoinMarket-Org/joinmarket/wiki/Using-the-JoinMarket-internal-wallet

    `(jmvenv) $ python wallet-tool.py generate`  
    * JoinMarket uses a hot wallet sitting on your Raspberry Pi. Keep it safe.
    * Backup your seed and store safely. Best to not keep the seed and the passphrase together.
    * The wallet encryption password will be needed every time when there is interaction with the wallet. Store it somewhere accessible, best if encrypted.

* Display the addresses of the mixdepth zero to fund:  

    `(jmvenv) $ python wallet-tool.py -m 0 wallet.jmdat`  
    
    Will display after the first run:
    
    ```
    [INFO]  Detected new wallet, performing initial import
    restart Bitcoin Core with -rescan or use `bitcoin-cli rescanblockchain` if you're recovering an existing wallet from backup seed
    Otherwise just restart this joinmarket application.
    ```
    
    Run again to see the addresses of the mixdepth zero (fund the first one):
    
    `(jmvenv) $ python wallet-tool.py -m 0 wallet.jmdat`  

### Send payments with or without a coinjoin
You can pay or withdraw to an external address with (or without) a CoinJoin using the `sendpayment.py`.

* Example:  
    `(jmvenv)$ python sendpayment.py -N5 -m1 WALLET.jmdat 100000000 mprGzBA9rQk82Ly41TsmpQGa8UPpZb2w8c`

    Sends 1BTC (100 million satoshis) from mixing depth 1 (the second!), mixing with five other parties.  
* The most importan options (see all with --help):    
    ```
    -N MAKERCOUNT, --makercount=MAKERCOUNT
                        how many makers to coinjoin with, default random from 5 to 7

    -m MIXDEPTH, --mixdepth=MIXDEPTH
                        mixing depth to spend from, default=0 (choose one from 0 to 4)
    ```

* Described in: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/USAGE.md#try-out-a-coinjoin-using-sendpaymentpy

* Can also [use the JoinMarket-QT GUI](https://github.com/openoms/bitcoin-tutorials/tree/master/joinmarket#joinmarketqt-gui-on-the-desktop) to send payments.

### Fee settings
* Edit the joinmarket.cfg:  
`$ sudo nano /home/joinmarket/.joinmarket/joinmarket.cfg`
    
* Miner fee:  
Look for: `tx_fees = 3` and change to `tx_fees = 3000` to pay 3 sats/byte (+/-20%) mining fee for transactions.  
Note that in times of high mempool usage it can take a long time to have transactions confirmed with this low fee.   
Alternatively use `tx_fee = 10` to aim confirmation within 10 blocks.  
    
* Maker (coinjoin) fees: 
  * Set `#max_cj_fee_abs = x` to `max_cj_fee_abs = 2000` to pay max 2000 sats per maker when coinjoining (more restrictive for higher amounts)
  * Set  `#max_cj_fee_rel = x` to `max_cj_fee_rel = 0.001` to pay max 0.1% per relative offer when coinjoining.  
  These settings might make it difficult to find counterparties to coinjoin with, see the [offerbook](https://joinmarket.me/ob) for the market and increase the limits if the offers are scarce or running into errors.
* press CTRL + o, ENTER to save and CTRL + x to exit. 

### Coin control
* List all UTXO-s in the WALLET with:  
    `(jmvenv)$ python wallet-tool.py WALLET.jmdat`
* Pick a mixdepth (-m[0-4]) to transfer from:
* Run the `wallet-tool.py` with the `freeze` method:  
    `(jmvenv)$ python wallet-tool.py -m0 WALLET.jmdat freeze`
* The script will ask which UTXO to freeze or unfreeze - you can keep pressing the numbers to choose.
* Once done use `-1` to exit.
* Sweep the mixdepth with `-N 0` to send the NOT FROZEN UTXO-s without a coinjoin:  
    `(jmvenv)$ python sendpayment.py -N 0 WALLET.jmdat 0 DESTINATION_BITCOIN_ADDRESS`

* Can also [use the JoinMarket-QT GUI](https://github.com/openoms/bitcoin-tutorials/tree/master/joinmarket#joinmarketqt-gui-on-the-desktop) for coin control.

### Tumbler script
The Tumbler does series of CoinJoins with various amounts and timing between them to break the link between different addresses.
The Yield Generator only mixes the coins slowly but close to free (it is even possible to earn some fees).
With the Tumbler the CoinJoin process is faster but the miner and maker fees are all paid by the taker running the Tumbler.

* See: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/tumblerguide.md

* Can also [use the JoinMarket-QT GUI](https://github.com/openoms/bitcoin-tutorials/tree/master/joinmarket#joinmarketqt-gui-on-the-desktop) to run the Tumbler.

### Yield Generator
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
    * `txfee` is the maker's contribution to the miner fee. To reduce the minimum offer amount for `swreloffer` set it to 0.    
    * `minsize` specifies the minimum offer size in satoshis (this is the minimum size the UTXO will end up to be after participating in coinjoin)


* Once set up run:

    `(jmvenv) $ python yg-privacyenhanced.py wallet.jmdat`

### PayJoin
Send or receive a payment using PayJoin between two JoinMarket wallets.

* see the how-to: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/PAYJOIN.md#doing-a-payjoin-payment

* Video demonstration:  https://asciinema.org/a/221153?speed=2

### Transaction history
* use the wallet tool:  
    `(jmvenv) $ python wallet-tool.py wallet.jmdat history`

    add `-v 4` to the end of the command for a more detailed list.

* View the log of the transactions of the Yield Generator:  
    `$ cat ~/.joinmarket/logs/yigen-statement.csv`

* Display as a table in the terminal:  
    `$ column -s, -t < ~/.joinmarket/logs/yigen-statement.csv | less -#2 -N -S`  
    press `q` to exit

* Monitor continously with:  
    `$ tail -f -n 100 ~/.joinmarket/logs/yigen-statement.csv`

### Running in the background with [Tmux](https://github.com/tmux/tmux#welcome-to-tmux)
* Start:  
`$ sudo su joinmarket`  
`$ tmux`

* Work in the terminal as described above.  
Find a basic introduction to Tmux at https://www.ocf.berkeley.edu/~ckuehl/tmux/
* To detach the Tmux session (and keep the processes running in the background) press `CTRL` + `b`, then `d`.
* If the terminal is disconnected the processes in Tmux keep running (as it is running on the Blitz) and can be returned to
* when logged in after a disconnection run:  
`$ tmux a`  
    to pick up where left off

### JoinMarketQT GUI on the desktop
The graphical interface can run on the desktop relayed from the node via an encrypted ssh tunnel.  
h/t @coconutanna on the #joinmarket Freenode IRC channel

#### Linux desktop
* Tested on:
  * Debian Buster
  * Manjaro  
* Use the line in the desktop terminal to connect:  
 `$ ssh -X joinmarket@RASPIBLITZ_IP joinmarket-clientserver/jmvenv/bin/python joinmarket-clientserver/scripts/joinmarket-qt.py`
  
* Use the PASSWORD_B to log in.

#### Mac
* install [XQuartz](https://www.xquartz.org/)
* Enter the command as above in a Mac terminal, XQuartz will load and show QT GUI.  
    Thanks to [@k3tan172](https://github.com/rootzoll/raspiblitz/issues/842#issuecomment-605904574)

#### Windows
* Download, install and run XMing with the default settings - <https://xming.en.softonic.com/>
* Open Putty and fill in:
  * `Host Name`: `RASPIBLITZ_LAN_IP`
  * `Port`: `22`
* Under `Connection`: 
  * `Data` -> `Auto-login username`: `joinmarket`
* Under `SSH`
  * `X11` -> `[x] Enable X11 forwarding`
* These settings can be saved in `Session` -> `Load. save or delete stored session` -> `Save`
* `Open` the connection
* Use the `PASSWORD_B` to log in
* In the terminal type:  
  `python joinmarket-qt.py`
* The QT GUI will appear on the windows desktop running from your RaspiBlitz.  
    Thanks for the initial demo by [Hamish MacEwan](https://twitter.com/HamishMacEwan)

See the walkthrough for the JoinMarket-Qt GUI to send payments with coinjoin or run multiple coinjoins (**tumbler**): <https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/JOINMARKET-QT-GUIDE.md>

Video demonstration of using the JoinMarket-Qt GUI by @AdamISZ: <https://youtu.be/hwmvZVQ4C4M>

See this review thread about the GUI option: https://twitter.com/zndtoshi/status/1191799199119134720

### Run the Order Book locally
The order book is usually available at <https://joinmarket.me/ob>. The page being down does not affect the functionality of JoinMarket. Communication between the nodes is encrypted and passing through IRC servers.

* Any JoinMarket instance can build and serve the order book itself:  
run in Tmux (as described above) to keep running when the terminal is closed.
    ```
    (jmvenv)$ cd ~/joinmarket-clientserver/scripts/obwatch
    (jmvenv)$ python ob-watcher.py
    ```
* Create a .onion service:  
use the RaspiBlitz script `internet.hiddenservice.sh`
    ```
    $ /home/admin/config.scripts/internet.hiddenservice.sh ob-watcher 80 62601
    ```
* visit the displayed `.onion` hidden service address in the Tor Browser for the local order book.

* (optional) to have the graphs show install matplotlib in the virtual environment:
    ```
    (jmvenv)$ pip install matplotlib
    ```

General docs on the order book (including how to run without Bitcoin Core): <https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/orderbook.md>
### Export a private key of an individual UTXO-s to Electrum Wallet (advanced)

<https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/USAGE.md#recovering-private-keys>

* Example syntax to obtain the private keys (WIF format):  
using the derivation path (m/...) as specified in the `wallet-tool.py` output; note the need to use double quotes around it.

    ```
    (jmvenv)$ python wallet-tool.py -H "m/49'/0'/4'/0/0" wallet.jmdat dumpprivkey
    Enter wallet decryption passphrase: 
    L1YPrEGNMwwfnvzBfAiPiPC4zb5s6Urpqnk88zNHgsYLHrq2Umss
    ```

* Open Electrum Wallet and start to create a new wallet.
* Select `Import Bitcoin Addresses or private keys`
* paste the private key you want to use as:  
`p2wpkh-p2sh:WIF_FORMAT_PRIV_KEY`

### Resources

* Notes on usage:  
<https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/USAGE.md>
<https://github.com/JoinMarket-Org/joinmarket/wiki>

* Latest codebase:  
<https://github.com/JoinMarket-Org/joinmarket-clientserver>

* Bitcoin privacy wiki:  
<https://en.bitcoin.it/Privacy>

* More links and info in 6102bitcoin/CoinJoin-Research:  
<https://github.com/6102bitcoin/CoinJoin-Research/blob/master/CoinJoin_Implementations/11_JoinMarket-JoinMarket-Org/summary.md>

* Check the guide for the RaspiBolt by @kristapsk:  
<https://github.com/kristapsk/raspibolt-extras/blob/master/joinmarket.md>

* Default joinmarket.cfg settings: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/jmclient/jmclient/configure.py#L94

### Forums

* IRC: #joinmarket on Freenode <https://webchat.freenode.net/?channels=%23joinmarket>
* IRC on tor: `#joinmarket` on the networks [AgoraIRC](https://anarplex.net/agorairc/) and [Darkscience](https://www.darkscience.net/). These channels are bridged to the above freenode channel.
* Reddit: <https://www.reddit.com/r/joinmarket/>
* Telegram: <https://t.me/joinmarketorg>
* Keybase: <https://keybase.io/team/raspiblitz#joinmarket>
* Bitcointalk thread: https://bitcointalk.org/index.php?topic=919116.msg10096563
* Twitter: https://twitter.com/joinmarket
