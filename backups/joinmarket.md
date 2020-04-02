## JoinMarket single seed multi-location backup scheme
Documentation on JoinMarket wallet recovery: <https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/USAGE.md#recover>  
When the wallet is restored connected to a bitcoin node with which it was not previously used, will need to rescan the blockhain to register the transactions and look up the wallet balance. Having the wallet birthday helps to do the rescan only from when the wallet was created, but it is not absolutely necessary.

---
### Components grouped together by the requirement for a full restore
#### Full backup 1
* Seed (12 words)
* Passphrase (BIP39)
#### Full backup 2 
* Wallet file (.jmdat)
* Encryption passphrase

---
### Packages for a 2-of-3 setup
#### Location 1
- Seed (12 words)
- Wallet file (.jmdat)
- First tx blockheight (optional)

#### Location 2 
- Passphrase (BIP39)
- Encryption passphrase 
- First tx blockheight (optional)

#### Location 3
- Seed (12 words)
- Encryption passphrase
- First tx blockheight (optional)