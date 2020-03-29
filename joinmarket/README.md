<p align="left">
  <img width="150"  src="../images/RaspiBlitz_Logo_Berry.png">
  <img width="100" >
  <img width="100" src="../images/joinmarket_logo.png">

</p>

## JoinMarket on the RaspiBlitz
A long standing coinjoin implementation with decentralised coordination and incentive structure.

Tested on:
* RPi4 4GB with RaspiBlitz v1.4
* Odroid HC1 with RaspiBlitz v1.3

Check the current offers in the order book: https://joinmarket.me/ob/  

One can coinjoin any amount within the offer limits by default with 5-7 random participants at a time. The taker fees are maximised, then the offers within the limits are randomly chosen to participate. Most parameters can be easily customized.

### Installation

Now you can use the automated install [script](https://github.com/rootzoll/raspiblitz/blob/v1.5/home.admin/config.scripts/bonus.joinmarket.sh) which will be the part of the RaspiBlitz v1.5 release and can be installed form SERVICES menu.

What the script does:

* sets up a separate user: `joinmarket` with sudo access. Uses the PASSWORD_B as the user password
* the data directory is on the disk at `/mnt/hdd/app-data/.joinmarket`, symlinked to `/home/joinmarket/.joinmarket` and will be kept during the SD-card updates
* if joinmarket was set up already using a previous version of this tutorial the the wallet(s) will be copied to the new data directory automatically
* will be compatible with GUI being worked on here: https://github.com/openoms/joininbox


To install JoinMarket on RaspiBlitz v1.4 (earlier versions are not supported):

```
#download:
https://raw.githubusercontent.com/rootzoll/raspiblitz/v1.5/home.admin/config.scripts/bonus.joinmarket.sh
#run:
sudo bash bonus.joinmarket.sh on
```

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

### Send payments with a coinjoin with the `sendpayment.py`

You can pay or withdraw to an external address with (or without) a CoinJoin using the `sendpayment.py`.

* Described in: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/USAGE.md#try-out-a-coinjoin-using-sendpaymentpy

### Tumbler script

The Tumbler does series of CoinJoins with various amounts and timing between them to break the link between different addresses.
The Yield Generator only mixes the coins slowly but close to free (it is even possible to earn some fees).
With the Tumbler the CoinJoin process is faster but the miner and maker fees are all paid by the taker running the Tumbler.

* See: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/tumblerguide.md

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

* Start:  
`$ tmux`

* Work in the terminal as described above.  
Find a basic introduction at https://www.ocf.berkeley.edu/~ckuehl/tmux/
* If the terminal is disconnected the processes in tmux keep running (as it is running on the Blitz) and can be returned to
* when logged in after a disconnection run:  
`$ tmux a`  
    to pick up where left off

### Remote connection with ssh -X

h/t @coconutanna on the #joinmarket Freenode IRC channel

Use the JoinMarket QT GUI on a desktop, connecting remotely to the node.
It needs Xserver running locally so making it work on Mac and Windows requires some more input.

Try the remote QT GUI connection on Linux:

```
ssh -X joinmarket@RASPIBLITZ_IP joinmarket-clientserver/jmvenv/bin/python joinmarket-clientserver/scripts/joinmarket-qt.py
```

The password is the PASSWORD_B

Successfully tested to open the JoinMarket QT GUI remotely on a desktop running:

* Debian Buster
* Manjaro

Requires more testing:
* Mac needs either X11.app or starting ssh from an xterm.

* Windows requires Xming or similar.

* See the walkthrough for the JoinMarket-Qt GUI to send payments with coinjoin or run multiple coinjoins (**tumbler**): <https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/JOINMARKET-QT-GUIDE.md>

* Video demonstration of using the JoinMarket-Qt GUI by @AdamISZ: <https://youtu.be/hwmvZVQ4C4M>

See this review thread about the GUI option: https://twitter.com/zndtoshi/status/1191799199119134720

### Resources

* Notes on usage:
<https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/USAGE.md>

* Latest codebase:  
<https://github.com/JoinMarket-Org/joinmarket-clientserver>

* Discuss JoinMarket usage on the RaspiBlitz in:
<https://github.com/rootzoll/raspiblitz/issues/842>

* More links and info in 6102bitcoin/CoinJoin-Research:  
https://github.com/6102bitcoin/CoinJoin-Research/blob/master/CoinJoin_Implementations/11_JoinMarket-JoinMarket-Org/summary.md

* Check the guide for the RaspiBolt by @kristapsk:  
https://github.com/kristapsk/raspibolt-extras/blob/master/joinmarket.md

### Forums

* Keybase: https://keybase.io/team/raspiblitz#joinmarket  
* Telegram: https://t.me/joinmarketorg  
* IRC: #joinmarket on Freenode  
* Reddit: https://www.reddit.com/r/joinmarket/  
