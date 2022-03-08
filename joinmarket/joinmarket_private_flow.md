# A private flow through JoinMarket

Guidance to get started with sending bitcoin through the JoinMarket wallet following basic good practices.

## Common definitions
### Mixdepth
* one of the accounts in the joinmarket wallet
* abbreviated to m0 / m1 / m2 / m3 / m4
* all are derived from the same BIP32 compatible HD seed

### Sweep
* sending one or multiple utxos without creating change.
* can be achieved by sending all utxos from a mixdepth or freezing any which should be sent.
* the amount is not fixed and fees come of the sum of the inputs.

### Status labels
* applied automatically by JoinMarket via a simple transaction analyses

#### `deposit`: output of a simple transaction to new address
#### `cj-out`: one of the equal amount outputs
#### `change-out`: one of the unique amount outputs from a cj
#### `non-cj-change`: output of a transaction without equal amounts
#### `reused`: a utxo on an address which has been used previously

### Orderbook
* Any platform collecting the public orders of the peers
* General docs on the order book (including how to run without Bitcoin Core): https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/orderbook.md
* a public example: <https://nixbitcoin.org/orderbook>
### Minimum size to coinjoin
* the default is 100k sats (+/-10%) so that is a safe choice.
* on the example below offers start at 6 peers offering min 27300 sats.

### Maximum size to coinjoin
* the max amount offered is limited by the wallet of each Maker
* it is the highest amount in one single mixdepth (-0-10%)
* multiple bitcoin amounts are offered by several (10+) peers
* on the example below 21 peers offer 19+ BTC
### Screenshots taken from <https://nixbitcoin.org/orderbook> in March 2022.
* Click the top of the line to order by it's attribute
<p align="left">
  <img width="147" src="../images/joinmarket_minsize.png">
  <img width="100">
  <img width="150"  src="../images/joinmarket_maxsize.png">
</p>

## The flow of funds

Guidance is provided in the behaviour of the Tumbler script which could be used for the quickest result.
Discussed in:
* https://gist.github.com/chris-belcher/7e92810f07328fdfdef2ce444aad0968
* https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/tumblerguide.md
* https://joinmarket.me/blog/blog/the-445-btc-gridchain-case/

### Deposit
* send to m0 - could be any of the accounts, but selected the first for simplicity
* deposit a single or multiple coins from a single funding source at a time
* select the newly deposited coin(s) with freeze/unfreeze if there are others in the account

### Sweep
* start with detaching the deposited coins from their history
* can send to the same account (could be any, but keep it simple)
* there is no change created, so there is need to separate the `cj-out` from the `change-out`

### Send or participate in multiple coinjoins
* alternate being a Taker and a Maker for the best results
* stretch out in time
* the Taker acts as the coinjoin coordinator
    * has the most privacy benefits
    * pays the fees (miner and coinjoin fees)

#### The Taker role
* send coinjoins to the next mixdepth (acting as a Taker)
* when sending can merge multiple coins in the coinjoin by sending custom amounts or sweeping

#### The Maker role
* activate the Yield Generator (Maker / Earn)
* to get selected more often it is best to have a a sizeable Fidelity Bond. See:
    * https://nixbitcoin.org/orderbook/fidelitybonds
    * https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/fidelity-bonds.md
* as a Maker the coins will circle through the accounts automatically:  
... m0 -> m1 -> m2 -> m3 -> m4 -> m0 -> m1 -> m2 -> m3 -> m4 ...
* only the `cj-out`  propagates to the next account
* the `change-out` stays behind in the same acount where the funding utxo was

### Leaving the JoinMarket wallet

* the more coinjoins the coins were through the better
* consider that the privacy benefit from coinjoins breaks down with time as the peers are gradually exposed or clustered
* if deposited only to m0 and followed the steps above all coins in m4 must have been through at least 5 coinjoins
* in a long running, active Maker wallet some funds could have made multiple circles - there is no indication of this by default
* can only send (merge coins) from one account at a time
* leave to multiple separate destinations (separate wallets with different purposes - not to be merged later)
* avoid sending out the whole amount which entered the wallet a few transactions ago all at once
* pay with Payjoin to BIP78 compatible wallets to obfuscate the amount sent <https://en.bitcoin.it/wiki/PayJoin_adoption>
* fund lightning nodes or send to cold storage with a coinjoin
  * best is to sweep whole accounts or coins and not leave change behind
  * don't merge a change from a previous transactions when sending to a new destinations

## More Reading
* https://github.com/JoinMarket-Org/joinmarket-clientserver/tree/master/docs
* https://en.bitcoin.it/Privacy

## Questions and discussions:
* IRC through Matrix: https://matrix.to/#/#joinmarket:libera.chat
* Telegram: https://t.me/joinmarket.org
