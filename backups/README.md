# Single seed multi-location backup schemes

The aim is to create 3 packages of cryptographically secure
backups where the funds cannot be recovered from any single package,
but can be recovered with the combination of any two.  
Can be thought of as a physical 2-of-3 multisig solution.

## [ColdCard](coldcard.md)
## [JoinMarket](joinmarket.md)
## [LND](lnd.md)
## [Samourai Wallet](samouraiwallet.md)
---
### Electrum Wallet seed as a passphrase
A well proven way to generate random 12 word list is to create a new wallet seed in [Electrum Wallet](https://electrum.org/#download).  
To use Electrum boot [Tails](https://tails.boum.org/) (ideally offline) or [download and verify the wallet](https://electrum.org/#download) on an existing system.  

Follow steps 1-5 in this [guide](https://bitcoinelectrum.com/creating-an-electrum-wallet/) to get the seed. The wallet file is not needed, only write down the words and store accordingly. The 12 words are to be used as a passphrase, encryption passphrase, cypher phrase or wallet unlock password. Do not reuse passphrases for more than one purpose and label the backups clearly.

The [Electrum word list](https://github.com/spesmilo/electrum/blob/master/electrum/wordlist/english.txt) is based on the same 2048 words as the the [BIP39 word list](https://github.com/bitcoin/bips/blob/master/bip-0039/english.txt) which the ColdCard firmware contains so the keyboard entry is facilitated by the menu.

An Electrum Wallet seed provides [135 bits of entropy](https://electrum.readthedocs.io/en/latest/seedphrase.html#security-implications) which is stronger than a [12 word BIP39 seed](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki).
