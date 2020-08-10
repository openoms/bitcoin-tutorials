# CoinJoin comparison
  
Implementations are discussed in a temporal order.  
If you find a factual error please suggest to correct it.  
Aiming to avoid including personal opinions, if so feel free to raise an issue.  
  
---  
  
## JoinMarket 
### Stack:  
bitcoind RPC - JoinMarket CLI / JoinMarketQT GUI on desktop / JoininBox menu on server   
### Code  
Size :  
Number of contributors:  
Programming language: Python3  
  
### CJ implementation:  
#### Pool size:   
Variable depending on Offer Book (produced by the Makers - communicated via IRC bots)  
#### Fees:  
Coordinator Fees:  
variable (according to Makers setting)  
Miner fees:  
depends on the number of inputs and outputs  
variable (sat/byte randomised around the coordinator/taker setting)  
  
#### Remix:  
Can be triggered on demand (Taker) or remixed for free (liquidity market - Maker)  
  
### Architecture (with default settings):  
Coordination is decentralised P2P through encrypted IRC  
own full node backend only  
Tor is available (not enforced)  
CJ participants are randomised 7-9  
Coordinator fees are variable and randomised around the Taker's setting  
variable and randomised contribution to onchain fees by the makers  
Wallets are separated to 5 accounts (mixdepths)  
The UTXOS only progress between mixdepths as part of a CJ (the unmixed change is left behind in the   same mixdepth)  
Can only spend from one mixdepth at a time (no consolidation between accounts) 
#### Autolabeling to:  
New address (deposit) ,  
change-out (unmixed i. last CJ),   
non-CJ-out (change of a non-CJ txn),   
reused (more than one UTXO/txn on the same address)  
CJ-out  
  
### Postmix:  
coin control with auto-labeling (freeze method)  
Send with a CJ - can be an arbitrary amount  
Payjoin - cross implementation with BTCPayServer and WasabiWallet  
### Good practice:  
Sweep mixdepths occasionally  
use the Tumbler script (first and last txns are sweeping - no unmixed change)  
Alternate being a Taker (tumbler, sendpayment) and Maker (yield gen)  
Break down large amounts between multiple wallets (watch the offerbook)
  
---  
  
## Wasabi Wallet  
Stack:  
Neutrino and/or bitcoind - Wasabi Wallet on desktop  
  
### Code:  
Size:  
Language: C#  
Number of contributors:  
  
### CJ implementation:  
#### Pool size:   
fixed ~ 10M sats  
#### Fees:
Coordinator fee:
0.003% / anonymity set (calculated as the number of participants in the CJ txn)
Miner fees:  
variable sat/byte according to blockspace market - shared between participants  
#### Remix:   
Paid per round. Triggered by number of participants (100) or time (2h)  
  
### Architecture:  
Tor only   
Central coordinator  
Backend is P2P client-side filtering (Neutrino) with option to connect own full node  
blocks queried from random peers / own node  
Coordinator fees are paid in the mix to a variable fee adress by all participants  
Miner fees shared by all participants  
High number of CJ partcipants  
### Postmix:  
Coin-control and labeling (auto and manual)  
single account for Pre, postmix and unmixed change  
HWW support for non-CJ wallets  
Payjoin - able to send cross implementation to BTCPay and JM  
  
### Good practice:  
make multiple rounds (at least two - can change green checkmark to 101)  
do not consolidate unmixed change with CJ outputs   
avoid consolidating high number of mixed UTXO-s  
[developer recommendations](https://docs.wasabiwallet.io/using-wasabi/10Commandments.html#_6-never-merge-mixed-and-unmixed-coins-and-avoid-large-merges-of-mixed-coins)
---  
  
## Samourai Wallet Whirlpool 
  
### Stack:   
bitcoind RPC - Dojo (+indexer, Docker) + Whirlpool (SW/ WhirlpoolGUI (Desktop)/WhirpoolCLI) + SW   (Android)  
### Code:  
Size:  
Language:  
NodeJS and Rust (for Indexer/ Electrs) + Docker  
Number of contributors:  
Number of external dependencies:  
  
### CJ implementation: 
#### Pool size:   
fixed 1M / 5M / 50M sats  
#### Fees:  
Coordinator Fees:  
Preset per entry to pool (5% of pool size)  
Miner fees:  
Tx0 - variable sat/byte according to mempool  
Whirpool entry - set for every UTXO according to mempool - can set priority  
#### Remix:  
Entry is paid, triggers if another new entrant is present  
Remix is free and participation is randomised  
  
### Architecture:  
Central coordinator  
own backend not enforced - Dojo with Full bitcoin node is available  
Tor only  
5 participants (2 always new entries)  
Coordinator fees are paid outside of mix on entry  
Miner fees paid by new entrants  
1495 possible interpretations per mix. Remix time is variable and cannot be controlled.  
Premix, postmix and unmixed change is separated to different accounts  
  
### Post Mix:  
Coin control  
Pay with a simulated or real 2 partcipant CJ - Stonewall/Stonewall2  
P2EP between SW-s  
  
### Good practice suggestions:  
Keep remixing (for free)
avoid consolidating large number of UTXOs   
never consolidate between accounts (warnings are issued)  
  
---  
  
## Resources  
BitcoinQandA  
Bitcoin-only CJ research  
JM docs  
Wasabi Docs  
Samourai Docs  